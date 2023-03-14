{
  description =
    "A Nix-flake-based development environment for Kubernetes 1.24";

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
          kubectl =
            let
              urls = {
                "x86_64-darwin" = "darwin/amd64";
                "x86_64-linux" = "linux/amd64";
              };
              shas = {
                "x86_64-darwin" = "323926e73d685f6e84a81ca32db2347e1aa50a3c6489807dcdce1ecf496a38b4";
                "x86_64-linux" = "c8bdf1b12d5ac91d163c07e61b9527ef718bec6a00f4fd4cf071591218f59be5";
              };
            in
            super.stdenv.mkDerivation rec {
              name = "kubectl";
              version = "1.24.11";
              src = super.fetchurl {
                url = "https://dl.k8s.io/release/v${version}/bin/${urls."${super.system}"}/kubectl";
                sha256 = shas."${super.system}";
              };
              dontConfigure = true;
              dontUnpack = true;
              dontBuild = true;
              installPhase = ''
                mkdir -p $out/bin
                cp $src $out/bin/kubectl
                chmod +x $out/bin/kubectl
              '';
            };
        })
      ];
      pkgs = import nixpkgs { inherit overlays system; };
    in
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          kubectl
        ];

        shellHook = with pkgs; ''
          ${kubectl}/bin/kubectl version --client=true
        '';
      };
    });
}
