{
  description = "Email Newsletter sample from Zero to Production in Rust";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    flake-parts,
    devshell,
    gitignore,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem = {
        config,
        inputs',
        pkgs,
        lib,
        system,
        ...
      }: let
        inherit (pkgs) stdenv;

        rustc = pkgs.rustc;
        cargo = pkgs.cargo;
        #gcc = pkgs.gcc13;
        zld = pkgs.zld;
        #libiconv = pkgs.libiconv;

      in {
        # define a devshell
        devShells.default = inputs'.devshell.legacyPackages.mkShell {
          # setup some environment variables
          env = with lib;
            mkMerge [
              [
                # Configure nix to use nixpkgs
                {
                  name = "NIX_PATH";
                  value = "nixpkgs=${toString pkgs.path}";
                }
              ]
            ];

          # add package dependencies
          packages = with lib;
            mkMerge [
              [
                rustc
                cargo
                #gcc
                zld
                #libiconv
              ]
            ];
        };

        # define flake output packages
        packages = let
          # useful for filtering src trees based on gitignore
          inherit (gitignore.lib) gitignoreSource;

          # common properties across the derivations
          version = "0.0.1";
          src = gitignoreSource ./.;
        in {
           # TBD
        };
      };
    };
}
