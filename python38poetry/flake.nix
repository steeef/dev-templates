{
  description = "A Nix-flake-based Python 3.8 poetry-based development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";
    flake-utils.url = "github:numtide/flake-utils";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , poetry2nix
    }:

    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ poetry2nix.overlay ];
      };
      poetryEnv = pkgs.poetry2nix.mkPoetryEnv {
        projectDir = ./.;
        python = pkgs.python38;
        editablePackageSources = {
          pkgSrc = ./.;
        };
      };
    in
    {
      devShells.default = pkgs.mkShell {
        buildInputs = [ poetryEnv pkgs.python38Packages.pip ];
        shellHook = ''
          ${pkgs.poetry}/bin/poetry --version
        '';
      };
    });
}
