{
  description = "A Nix-flake-based Python 3.8 development environment";

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
      pkgs = import nixpkgs { inherit system; };
      pythonPackages = pkgs.python38Packages;
      venvDir = "./.venv";
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
        inherit venvDir;
        packages = packages;
        postShellHook = postShellHook;
      };
    });
}
