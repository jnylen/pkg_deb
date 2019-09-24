defmodule PkgDeb.Format.Data do
  @moduledoc """
  This module houses the logic required to build the data payload portion of the
  debian package.
  """
  alias PkgDeb.Format.Generators.{Upstart, Systemd, Sysvinit}

  def build({release, dir}, config) do
    data_dir = make_data_dir(dir, config)
    copy_release(data_dir, config, release)
    copy_additional_files(data_dir, config.additional_files)
    remove_targz_file(data_dir, config)
    PkgCore.File.remove_fs_metadata(data_dir)
    Upstart.build(data_dir, config)
    Systemd.build(data_dir, config)
    Sysvinit.build(data_dir, config)

    config =
      Map.put_new(
        config,
        :installed_size,
        PkgCore.File.get_dir_size(data_dir)
      )

    System.cmd("chmod", ["-R", "og-w", data_dir])

    PkgCore.Compression.compress(
      data_dir,
      Path.join([data_dir, "..", "data.tar.gz"]),
      owner: config.owner
    )

    PkgCore.File.remove_tmp(data_dir)

    {release, dir, config}
  end

  # We don't use/need the .tar.gz file built by Distillery Packager, so
  # remove it from the data dir to reduce filesize.
  defp remove_targz_file(data_dir, config) do
    [data_dir, config.base_path, config.name, "#{config.name}-#{config.version}.tar.gz"]
    |> Path.join()
    |> File.rm()
  end

  defp make_data_dir(dir, config) do
    PkgCore.Logger.debug("pkg_deb", "building debian data directory..")
    data_dir = Path.join([dir, "data"])
    :ok = File.mkdir_p(data_dir)
    :ok = File.mkdir_p(Path.join([data_dir, config.base_path, config.name]))

    data_dir
  end

  defp copy_release(data_dir, config, release) do
    dest = Path.join([data_dir, config.base_path, config.name])
    src = src_path(release)

    PkgCore.Logger.debug("pkg_deb", "copying #{src} into #{dest} directory..")
    {:ok, _} = File.cp_r(src, dest)

    dest
  end

  def copy_additional_files(data_dir, [{src, dst} | tail]) do
    rel_dst = Path.join(data_dir, Path.relative(dst))

    rel_src =
      [
        PkgCore.Config.rel_dest_path(),
        "pkg_deb",
        "additional_files",
        src
      ]
      |> List.flatten()
      |> Path.join()

    case File.mkdir_p(rel_dst) do
      :ok -> PkgCore.Logger.debug("pkg_deb", "created #{rel_dst} directory for additional files")
      _ -> nil
    end

    case File.cp_r(rel_src, rel_dst) do
      {:ok, _} -> PkgCore.Logger.debug("pkg_deb", "copied #{rel_src} into #{rel_dst} directory")
      _ -> PkgCore.Logger.error("pkg_deb", "copy #{rel_src} into #{rel_dst} directory failed")
    end

    copy_additional_files(data_dir, tail)
  end

  def copy_additional_files(data_dir, [_ | tail]) do
    PkgCore.Logger.error("pkg_deb", "copy of a file in the additional file list has been skipped,
          invalid convention format")
    copy_additional_files(data_dir, tail)
  end

  def copy_additional_files(_, _), do: nil

  defp src_path(%{test_mode: true} = config) do
    Path.join([PkgCore.Config.rel_dest_path(), config.name])
  end

  defp src_path(config) do
    config.path
  end
end
