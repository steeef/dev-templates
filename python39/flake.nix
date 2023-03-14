{
  description = "A Nix-flake-based Python 3.9 development environment";

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
          python = super.python39;
        })
      ];

      pkgs = import nixpkgs { inherit overlays system; };
    in
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [ python virtualenv ] ++
          (with pkgs.python39Packages; [ pip ]);

        shellHook = ''
          ${pkgs.python}/bin/python --version
        '';
      };
    });
}
