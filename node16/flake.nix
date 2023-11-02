{
  description = "A Nix-flake-based Node.js development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
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
        (self: super: rec {
          nodejs = super.nodejs-16_x;
          pnpm = super.nodePackages.pnpm;
          yarn = (super.yarn.override { inherit nodejs; });
        })
      ];
      pkgs = import nixpkgs {
        inherit overlays system;
        config.permittedInsecurePackages = [
          "nodejs-16.20.2"
        ];
      };
    in
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [ node2nix nodejs pnpm yarn ];

        shellHook = ''
          echo "node `${pkgs.nodejs}/bin/node --version`"
        '';
      };
    });
}
