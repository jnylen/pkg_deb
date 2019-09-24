defmodule PkgDeb.Format.Package do
  @moduledoc """
  This module is used to produce the final debian package file, using the "ar"
  compression tool.
  """

  def build({release, dir, config}) do
    PkgCore.Logger.debug("pkg_deb", "building deb file")

    :ok = File.mkdir_p(PkgCore.Config.rel_dest_path())

    out =
      Path.join([
        PkgCore.Config.rel_dest_path(),
        filename(config)
      ])

    File.rm(out)

    args = [
      "-qc",
      out,
      Path.join([dir, "debian-binary"]),
      Path.join([dir, "control.tar.gz"]),
      Path.join([dir, "data.tar.gz"])
    ]

    {_response, 0} = System.cmd("ar", args)

    PkgCore.Logger.debug("deb", "successfully built #{out}")

    {release, dir, config}
  end

  def filename(config) do
    "#{config.sanitized_name}_#{config.version}_#{config.arch}.deb"
  end
end
