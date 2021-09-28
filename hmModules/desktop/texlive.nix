{ lib, pkgs, ... }:

{
  programs.texlive = {
    enable = true;
    packageSet = pkgs.texlive;
    extraPackages = tpkgs: {
      inherit (tpkgs)
        scheme-medium
        collection-fontsrecommended
        wrapfig
        minted
        fvextra
        upquote
        catchfile
        xstring
        framed
        titling
        paralist
        forest;
    };
  };
}
