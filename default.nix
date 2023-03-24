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

  staticOptions = import ./static.nix {
    inherit (pkgs) callPackage gcc runCommand;
    inherit symbols;
  };

  pinnedNixpkgsCheckout = nixpkgs.path;

  baseModules = ({
      # Profiling settings (applied to everything)
      enableProfiling = profile;
      enableLibraryProfiling = profile;

      # Closure size
      # Necessary to prevent gcc runtime dependency blowing it up; see
      # https://github.com/input-output-hk/haskell.nix/issues/829
      # Need to watch out for this when turning symbols on
      packages.codedown-screenshotter.components.exes.codedown-screenshotter.dontStrip = symbols;

      packages.codedown-screenshotter.components.exes.codedown-screenshotter.postInstall = optionalString compress ''
        ${upx}/bin/upx $out/bin/codedown-screenshotter
      '';

      packages.process.components.library.preConfigure = ''${nixpkgs.autoconf}/bin/autoreconf -i'';

      # Don't use GMP
      packages.ghc-bignum.components.library.configureFlags = [''-f native -f -gmp''];
      packages.cryptonite.configureFlags = [''-f -integer-gmp''];
    }
  );

  modules = baseModules;

in

pkgs.haskell-nix.stackProject {
  inherit src;

  stack-sha256 = "129kff5k32qahlmh7fknkrmrq01pw12qpnh37slirh134489abip";
  materialized = ./materialized;
  inherit checkMaterialization;

  modules = [
    (recursiveUpdate modules (if static then staticOptions else {}))
  ];
}
