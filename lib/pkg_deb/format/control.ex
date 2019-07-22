defmodule PkgDeb.Format.Control do
  @moduledoc """
  This module houses the logic required to build the control file and include
  custom control data such as pre/post install hooks.
  """
  alias PkgDeb.Format.Generators.Control
  alias PkgDeb.Utils.Compression

  # - Add ability to create pre-inst / post-inst hooks [WIP]
  def build({release, deb_root, config}) do
    control_dir = Path.join([deb_root, "control"])

    PkgDeb.Utils.Logger.debug("building debian control directory")
    :ok = File.mkdir_p(control_dir)

    Control.build(config, control_dir)
    add_custom_hooks(config, control_dir)
    add_conffiles_file(config, control_dir)
    System.cmd("chmod", ["-R", "og-w", control_dir])

    Compression.compress(
      control_dir,
      Path.join([control_dir, "..", "control.tar.gz"]),
      owner: %{user: "root", group: "root"}
    )

    PkgDeb.Utils.File.remove_tmp(control_dir)

    {release, deb_root, config}
  end

  defp add_conffiles_file(config, control_dir) do
    config_files =
      config
      |> Map.get(:config_files, [])
      |> Enum.map_join(&(&1 <> "\n"))

    :ok =
      [control_dir, "conffiles"]
      |> Path.join()
      |> File.write(config_files)
  end

  defp add_custom_hooks(config, control_dir) do
    for {type, path} <- config.maintainer_scripts do
      script =
        [File.cwd!(), path]
        |> Path.join()

      true = File.exists?(script)

      filename =
        case type do
          :pre_install -> "preinst"
          :post_install -> "postinst"
          :pre_uninstall -> "prerm"
          :post_uninstall -> "postrm"
          _ -> Atom.to_string(type)
        end

      filename =
        [control_dir, filename]
        |> Path.join()

      File.cp(script, filename)
    end
  end
end
