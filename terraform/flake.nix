{
  description =
    "A Nix-flake-based development environment for Terraform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    }:

    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          terraform
          tflint
        ];

        shellHook = with pkgs; ''
          env CHECKPOINT_DISABLE=1 ${terraform}/bin/terraform --version
        '';
      };
    });
}
