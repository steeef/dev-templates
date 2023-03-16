{
  description = "A Nix-flake-based Python 3.8 development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";
    flake-utils.url = "github:numtide/flake-utils";
    mach-nix.url = "github:/DavHau/mach-nix";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , mach-nix
    }:

    flake-utils.lib.eachDefaultSystem (system:
    let
      overlays = [
        (self: super: {
          machNix = mach-nix.defaultPackage.${system};
          python = super.python38;
        })
      ];

      pkgs = import nixpkgs { inherit overlays system; };
    in
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [ python machNix virtualenv ] ++
          (with pkgs.python38Packages; [ pip ]);

        shellHook = ''
          ${pkgs.python}/bin/python --version
          if [ ! -d "./.venv" ]; then
            ${pkgs.python}/bin/python -m venv ./.venv
          fi
          source ./.venv/bin/activate
        '';
      };
    });
}
