{
  description =
    "Ready-made templates for easily creating flake-driven environments";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flake-utils, nixpkgs }:
    {
      templates = rec {
        go = {
          path = ./go;
          description = "Go (Golang) development environment";
        };

        hashi = {
          path = ./hashi;
          description = "HashiCorp DevOps tools development environment";
        };

        kubectl124 = {
          path = ./kubectl124;
          description = "Kubernetes 1.24 development environment";
        };

        nix = {
          path = ./nix;
          description = "Nix development environment";
        };

        node = {
          path = ./node;
          description = "Node.js development environment";
        };

        python38 = {
          path = ./python38;
          description = "Python 3.8 development environment";
        };

        python39 = {
          path = ./python39;
          description = "Python 3.9 development environment";
        };

        python310 = {
          path = ./python310;
          description = "Python 3.10 development environment";
        };

        python311 = {
          path = ./python311;
          description = "Python 3.11 development environment";
        };

        ruby = {
          path = ./ruby;
          description = "Ruby development environment";
        };

        rust = {
          path = ./rust;
          description = "Rust development environment";
        };

        rust-toolchain = {
          path = ./rust-toolchain;
          description = "Rust development environment with Rust version defined by a rust-toolchain.toml file";
        };

        terraform = {
          path = ./terraform;
          description = "HashiCorp Terraform development environment";
        };

        # Aliases
        rt = rust-toolchain;
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        inherit (pkgs) mkShell writeScriptBin;
        exec = pkg: "${pkgs.${pkg}}/bin/${pkg}";

        format = writeScriptBin "format" ''
          ${exec "nixpkgs-fmt"} **/*.nix
        '';

        dvt = writeScriptBin "dvt" ''
          if [ -z $1 ]; then
            echo "no template specified"
            exit 1
          fi

          TEMPLATE=$1

          ${exec "nix"} \
            --experimental-features 'nix-command flakes' \
            flake init \
            --template \
            "github:the-nix-way/dev-templates#''${TEMPLATE}"
        '';

        update = writeScriptBin "update" ''
          for dir in `ls -d */`; do # Iterate through all the templates
            (
              cd $dir
              ${exec "nix"} flake update # Update flake.lock
              ${exec "direnv"} reload    # Make sure things work after the update
            )
          done
        '';
      in
      {
        devShells = {
          default = mkShell {
            packages = [ format update ];
          };
        };

        packages = rec {
          default = dvt;

          inherit dvt;
        };
      });
}
