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
      overlays = [
        (self: super: {
          python = super.python38;
        })
      ];
      inherit (poetry2nix.legacyPackages.${system}) mkPoetryApplication;
      pkgs = import nixpkgs { inherit overlays system; };
    in
    {
      packages = {
        myapp = mkPoetryApplication { projectDir = self; };
        default = self.packages.${system}.myapp;
      };
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [ poetry2nix.packages.${system}.poetry ];

        shellHook = ''
          ${pkgs.python}/bin/python --version
          ${pkgs.poetry}/bin/poetry --version
        '';
      };
    });
}
