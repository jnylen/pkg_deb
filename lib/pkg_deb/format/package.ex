defmodule PkgDeb.Format.Package do
  @moduledoc """
  This module is used to produce the final debian package file, using the "ar"
  compression tool.
  """
  alias PkgDeb.Utils.Config, as: ConfigUtil

  def build({release, dir, config}) do
    PkgDeb.Utils.Logger.debug("building deb file")

    :ok = File.mkdir_p(ConfigUtil.rel_dest_path())

    out =
      Path.join([
        ConfigUtil.rel_dest_path(),
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

    PkgDeb.Utils.Logger.debug("successfully built #{out}")

    {release, dir, config}
  end

  def filename(config) do
    "#{config.sanitized_name}_#{config.version}_#{config.arch}.deb"
  end
end
