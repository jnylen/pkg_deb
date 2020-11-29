defmodule PkgDeb.MixProject do
  use Mix.Project

  @name :pkg_deb
  @version "0.4.0"
  @description """
  Elixir lib for creating Debian packages with Mix Release.
  """
  @deps [
    {:pkg_core, "~> 0.1"},
    {:vex, "~> 0.8"},
    {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
  ]

  @hex_package [
    name: @name,
    files: ["lib", "mix.exs", "README*", "LICENSE*", "templates"],
    maintainers: ["Joakim Nylen <hexpm@joakim.nylen.nu>"],
    licenses: ["MIT"],
    links: %{
      "Github" => "https://github.com/jnylen/pkg_deb",
      "Docs" => "https://hexdocs.pm/pkg_deb/"
    }
  ]

  def project do
    [
      app: @name,
      version: @version,
      elixir: ">= 1.9.0",
      start_permanent: Mix.env() == :prod,
      deps: @deps,
      package: @hex_package,
      description: @description,
      docs: docs()
    ]
  end

  defp docs do
    [
      source_ref: "master",
      main: "PkgDeb",
      canonical: "http://hexdocs.pm/pkg_deb",
      source_url: "https://github.com/jnylen/pkg_deb",
      extras: [
        "README.md"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end
end
