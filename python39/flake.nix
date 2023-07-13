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
      pkgs = import nixpkgs { inherit system; };
      pythonPackages = pkgs.python39Packages;
      venvDir = "./.venv";
      packages = with pythonPackages; [
        python
        poetry
        venvShellHook
      ];
      postShellHook = ''
        PYTHONPATH="$(pwd)/${venvDir}/${pythonPackages.python.sitePackages}/:$PYTHONPATH"
      '';
    in
    {
      devShells.default = pkgs.mkShell {
        inherit venvDir;
        buildInputs = pkgs.lib.optionals pkgs.stdenv.isDarwin [ pkgs.openssl ];
        packages = packages;
        postShellHook = postShellHook;
      };
    });
}
