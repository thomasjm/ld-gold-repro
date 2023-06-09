{
  nixpkgs
, pkgs ? if static then nixpkgs.pkgsCross.musl64 else nixpkgs

, nixpkgsNoOverlays
, pkgsNoOverlays ? if static then nixpkgsNoOverlays.pkgsCross.musl64 else nixpkgsNoOverlays

, static ? false

, symbols ? false

, checkMaterialization ? false

, profile ? false

, compress ? false # (environment == "raw")
}:

with nixpkgs.lib;

let
  gitignoreSource = nixpkgs.gitignoreSource;

  src = gitignoreSource ./.;

  filterSubdir = subDir: pkgs.haskell-nix.haskellLib.cleanSourceWith { inherit src subDir; };

  extraArgs = ''${if symbols then "-g" else ""}'';

  staticOptions = {
    packages.ld-gold-repro.components.exes.ld-gold-repro.configureFlags = [
      ''--ghc-options="-pgml g++ ${extraArgs} -optl-Wl,--allow-multiple-definition -optl-Wl,--whole-archive -optl-Wl,-Bstatic -optl-Wl,-lsnappy -optl-Wl,-Bdynamic -optl-Wl,--no-whole-archive"''
    ];
    packages.ld-gold-repro.components.exes.ld-gold-repro.libs = [
      (pkgs.leveldb.override { static = true; })
      (pkgs.snappy.override { static = true; })
    ];
    packages.ld-gold-repro.components.exes.ld-gold-repro.build-tools = [pkgs.gcc];
  };

  pinnedNixpkgsCheckout = nixpkgs.path;

  modules = ({
      # Profiling settings (applied to everything)
      enableProfiling = profile;
      enableLibraryProfiling = profile;

      # Closure size
      # Necessary to prevent gcc runtime dependency blowing it up; see
      # https://github.com/input-output-hk/haskell.nix/issues/829
      # Need to watch out for this when turning symbols on
      packages.ld-gold-repro.components.exes.ld-gold-repro.dontStrip = symbols;

      # Don't use GMP
      packages.ghc-bignum.components.library.configureFlags = [''-f native -f -gmp''];
      packages.cryptonite.configureFlags = [''-f -integer-gmp''];
    }
  );

in

pkgs.haskell-nix.stackProject {
  inherit src;

  stack-sha256 = "1iri010bnfq0n4i860prr6kifh068jgrp9dbm8jf6qwic9560050";
  materialized = ./materialized;
  inherit checkMaterialization;

  modules = [
    (recursiveUpdate modules (if static then staticOptions else {}))
  ];
}
