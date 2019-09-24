defmodule PkgDeb do
  @moduledoc """
  Documentation for PkgDeb.
  """

  alias PkgDeb.Format.{Control, Data, Package}

  @doc """
  Receives an Mix.Release struct and creates a .deb file.
  """
  def create(%Mix.Release{} = release, config) when is_list(config) do
    {:ok, package_config} = PkgDeb.Format.Config.build_config(release, config)

    PkgCore.Logger.debug("pkg_deb", "building .deb package..")

    release
    |> init_dir()
    |> Data.build(package_config)
    |> Control.build()
    |> Package.build()
    |> remove_dir()

    release
  end

  def create(release, _), do: release

  def create_deb(release, config), do: create(release, config)

  defp remove_dir({_, deb_root, _}) do
    deb_root
    |> File.rm_rf()
  end

  defp init_dir(release) do
    deb_root = Path.join([release.path, "..", "..", "..", "deb"])

    :ok = File.mkdir_p(deb_root)

    :ok = File.write(Path.join(deb_root, "debian-binary"), "2.0\n")

    {release, deb_root}
  end
end
