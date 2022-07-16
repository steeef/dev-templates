{
  description = "A Nix-flake-based Rust development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [
          (import rust-overlay)
        ];

        pkgs = import nixpkgs {
          inherit system overlays;
        };

        rust = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

        inherit (pkgs.lib) optionals;
        inherit (pkgs.stdenv) isDarwin;
      in {
        packages.default = rust;

        devShells = {
          default = pkgs.mkShell {
            nativeBuildInputs = [
              rust
              pkgs.pkg-config
            ];

            buildInputs = with pkgs; [
              openssl
              pkgconfig
            ];

            shellHook = ''
              echo "Entering Rust env"
              echo "Running `${rust}/bin/cargo --version`"
            '';
          };
        };
      }
    );
}