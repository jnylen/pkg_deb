defmodule PkgDeb.Format.Generators.TemplateFinder do
  @moduledoc """
  This module decides whether to use a custom template or to use the default.
  """
  alias PkgDeb.Utils.Config, as: ConfigUtil

  def retrieve(pathname) do
    path = user_provided_path(pathname)

    case File.exists?(path) do
      true ->
        # info "Using user-provided file: #{path |> Path.basename}"
        path

      false ->
        # debug("Using default file: #{path |> Path.basename}"
        #   <> " - didn't find user-provided one")
        default_path(pathname)
    end
  end

  defp user_provided_path(pathname) do
    [
      ConfigUtil.rel_dest_path(),
      "pkg_deb",
      "templates",
      pathname
    ]
    |> List.flatten()
    |> Path.join()
  end

  defp default_path(pathname) do
    [
      ConfigUtil.root(),
      "templates",
      pathname
    ]
    |> List.flatten()
    |> Path.join()
  end
end
