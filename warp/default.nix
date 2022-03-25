{ 
  nixpkgs ? import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/haskell-updates.tar.gz") {},
  haskell-tools ? import (builtins.fetchTarball "https://github.com/danwdart/haskell-tools/archive/master.tar.gz") {},
  compiler ? "ghc922"
} :
let
  gitignore = nixpkgs.nix-gitignore.gitignoreSourcePure [ ../.gitignore ];
  tools = haskell-tools compiler;
  lib = nixpkgs.pkgs.haskell.lib;
  myHaskellPackages = nixpkgs.pkgs.haskell.packages.${compiler}.override {
    overrides = self: super: rec {
      warp = lib.dontHaddock (self.callCabal2nix "warp" (gitignore ./.) {});
      vault = lib.doJailbreak (super.vault);
      hedgehog = lib.doJailbreak super.hedgehog;
      tasty-hedgehog = lib.doJailbreak super.tasty-hedgehog;
      bsb-http-chunked = lib.dontCheck super.bsb-http-chunked;
      network-byte-order = lib.dontCheck (lib.doJailbreak (self.callCabal2nix "network-byte-order" (builtins.fetchGit {
        url = "https://github.com/kazu-yamamoto/network-byte-order.git";
        rev = "3570bb3a1aeae36c241bbad97f0c4d22162a2a65";
      }) {}));
      iproute = lib.doJailbreak (self.callCabal2nix "iproute" (builtins.fetchGit {
        url = "https://github.com/kazu-yamamoto/iproute.git";
        rev = "f387a37e07a4074d8e2b912834d93b6628d0befd";
      }) {});
    };
  };
  shell = myHaskellPackages.shellFor {
    packages = p: [
      p.warp
    ];
    shellHook = ''
      gen-hie > hie.yaml
      for i in $(find -type f); do krank $i; done
    '';
    buildInputs = tools.defaultBuildTools;
    withHoogle = false;
  };
  exe = lib.justStaticExecutables (myHaskellPackages.warp);
in
{
  inherit shell;
  inherit exe;
  inherit myHaskellPackages;
  warp = myHaskellPackages.warp;
}

