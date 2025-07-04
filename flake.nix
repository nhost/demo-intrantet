{
  inputs = {
    nixops.url = "github:nhost/nixops";
    nixpkgs.follows = "nixops/nixpkgs";
    flake-utils.follows = "nixops/flake-utils";
    nix-filter.follows = "nixops/nix-filter";
  };

  outputs = { self, nixops, nixpkgs, flake-utils, nix-filter }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [
          nixops.overlays.default
          (final: prev: { })
        ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        nix-src = nix-filter.lib.filter {
          root = ./.;
          include = with nix-filter.lib;[
            (matchExt "nix")
          ];
        };

        checkDeps = with pkgs; [
          nhost-cli
          bun
          biome
        ];

        buildInputs = [
        ];

        nativeBuildInputs = [
        ];

        nixops-lib = nixops.lib { inherit pkgs; };
      in
      {
        checks = flake-utils.lib.flattenTree {
          nixpkgs-fmt = nixops-lib.nix.check { src = nix-src; };

        };

        devShells = flake-utils.lib.flattenTree rec{
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              postgresql_17
            ] ++ checkDeps ++ buildInputs ++ nativeBuildInputs;
          };

          langlearn = default;
        };
      }
    );
}

