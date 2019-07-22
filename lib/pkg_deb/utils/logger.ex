defmodule PkgDeb.Utils.Logger do
  def debug(string), do: Mix.shell().info([:green, "* [deb] ", :reset, string])
  def error(string), do: Mix.raise(string)
end
