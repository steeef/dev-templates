{
  description = "A Nix-flake-based Python 3.11 development environment";

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
      pkgs = import nixpkgs { inherit system; };
      pythonPackages = pkgs.python311Packages;
      venvDir = "./.venv";
      buildInputs = with pkgs; [
        openssl
      ];
      packages = with pythonPackages; [
        python
        venvShellHook
      ];
      postShellHook = ''
        PYTHONPATH="$(pwd)/${venvDir}/${pythonPackages.python.sitePackages}/:$PYTHONPATH"

      '';
    in
    {
      devShells.default = pkgs.mkShell {
        buildInputs = buildInputs;
        inherit venvDir;
        packages = packages;
        postShellHook = postShellHook;
      };
    });
}
