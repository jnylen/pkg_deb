# PkgDeb

`pkg_deb` is a .deb file packager for `Mix Release`.

This is currently just a fork of `distillery_packager` for **Mix Release** so the code is quite messy but works.

## Installation

The package can be installed by adding `pkg_deb` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pkg_deb, "~> 0.3.0"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/pkg_deb](https://hexdocs.pm/pkg_deb).

## Usage

Inside of your mix.exs file add:

```elixir
  defp deb_config() do
    [
      vendor: "Your Name",
      maintainers: ["Your Name <your@email.com>"],
      homepage: "https://yourdomain.com",
      base_path: "/opt",
      external_dependencies: [],
      owner: [user: "youruser", group: "youruser"],
      description: "yourdescription"
    ]
  end
```

And to the steps inside of `releases` add:

```elixir
steps: [:assemble, &PkgDeb.create(&1, deb_config())],
```

## Thanks

Thanks to `distillery_packager` for their package that this is based of.
