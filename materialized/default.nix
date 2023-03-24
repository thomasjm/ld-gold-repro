{
  extras = hackage:
    { packages = { ld-gold-repro = ./ld-gold-repro.nix; }; };
  resolver = "lts-20.1";
  modules = [
    ({ lib, ... }:
      { packages = {}; })
    { packages = {}; }
    ({ lib, ... }:
      { planned = lib.mkOverride 900 true; })
    ];
  }