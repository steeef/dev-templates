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
      buildInputs = with pkgs; [
        openssl
      ];
      venvDir = "./.venv";
      packages = with pythonPackages; [
        python
        venvShellHook
      ];
      postShellHook = ''
        PYTHONPATH=\$PWD/\${venvDir}/\${pythonPackages.python.sitePackages}/:\$PYTHONPATH
      '';
    in
    {
      devShells.default = pkgs.mkShell {
        inherit venvDir;
        buildInputs = buildInputs;
        packages = packages;
        postShellHook = postShellHook;
      };
    });
}
