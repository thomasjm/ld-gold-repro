{ callPackage
, gcc
, runCommand

, symbols
}:

let
  extraArgs = ''${if symbols then "-g" else ""}'';

in

{
  packages.codedown-screenshotter.components.exes.codedown-screenshotter.configureFlags = [
    ''--ghc-options="-pgml g++ ${extraArgs} -optl-Wl,--allow-multiple-definition -optl-Wl,--whole-archive -optl-Wl,-Bstatic -optl-Wl,-Bdynamic -optl-Wl,--no-whole-archive"''
  ];
  packages.codedown-screenshotter.components.exes.codedown-screenshotter.libs = [
    # (snappy.override { static = true; })
    # (callPackage ./nix/static_libsodium.nix {})
    # (callPackage ./nix/static_zeromq.nix {})
    # (leveldb.override { static = true; })
  ];
  packages.codedown-screenshotter.components.exes.codedown-screenshotter.build-tools = [gcc];
}
