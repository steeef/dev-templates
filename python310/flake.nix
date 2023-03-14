{
  description = "A Nix-flake-based Python 3.10 development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    }:

    flake-utils.lib.eachDefaultSystem (system:
    let
      overlays = [
        (self: super: {
          python = super.python310;
        })
      ];

      pkgs = import nixpkgs { inherit overlays system; };
    in
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [ python virtualenv ] ++
          (with pkgs.python310Packages; [ pip ]);

        shellHook = ''
          ${pkgs.python}/bin/python --version
        '';
      };
    });
}
