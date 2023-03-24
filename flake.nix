{
  description = "ld.gold repro";

  inputs.gitignore = {
    url = "github:hercules-ci/gitignore.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # inputs.haskellNix.url = "github:input-output-hk/haskell.nix/5240aebeac56bb9c6f1313814c761f9b0abd6fe5"; # Broken commit
  inputs.haskellNix.url = "github:input-output-hk/haskell.nix/4875959faf4e774496a22c431d176ac14a66244b"; # Before broken commit

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/09e8ac77744dd036e58ab2284e6f5c03a6d6ed41";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, gitignore, nixpkgs, flake-utils, haskellNix }:
    # flake-utils.lib.eachDefaultSystem (system:
    # flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (system:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        nixpkgsNoOverlays = import nixpkgs { inherit system; };

        overlays = [
          haskellNix.overlay
          (final: prev: {
            inherit (gitignore.lib) gitignoreSource;
          })
        ];

        pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };

        base = (import ./. { inherit nixpkgsNoOverlays; nixpkgs = pkgs; });
        baseStatic = (import ./. { inherit nixpkgsNoOverlays; nixpkgs = pkgs; static = true; });

      in rec {
        packages = (rec {
          # Materialization
          calculateMaterializedSha = base.stack-nix.passthru.calculateMaterializedSha;
          generateMaterialized = base.stack-nix.passthru.generateMaterialized;
          checkMaterialization = let
            baseCheckMaterialization = (import ./. { inherit nixpkgsNoOverlays; nixpkgs = pkgs; static = true; checkMaterialization = true; });
          in baseCheckMaterialization.ld-gold-repro.components.library;

          ld-gold-repro = base.ld-gold-repro.components.exes.ld-gold-repro;
          ld-gold-repro-static = baseStatic.ld-gold-repro.components.exes.ld-gold-repro;

          default = ld-gold-repro-static;
        });
      });
}
