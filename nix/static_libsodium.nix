{ pkgsCross }:

(pkgsCross.musl64.libsodium.override { }).overrideAttrs (oldAttrs: {
  NIX_CFLAGS_COMPILE = "-static";
  configureFlags = (oldAttrs.configureFlags or []) ++ [
    "--enable-static"
    "--disable-shared"
  ];
})
