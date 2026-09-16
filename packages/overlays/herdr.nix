# herdr from our fork : https://github.com/dsander/herdr/tree/add-last-tab-command
final: prev: {
  herdr = prev.herdr.overrideAttrs (finalAttrs: prevAttrs: {
    version = "0.9.0";

    src = final.fetchFromGitHub {
      owner = "dsander";
      repo = "herdr";
      rev = "bbafe648f8c563cdd73de1e88db8b32897103b6a";
      hash = "sha256-HGliiOwCAxy1720OVoop6sRNjF9ijRsoeEJCF71Atpw=";
    };

    cargoDeps = final.rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) pname version src;
      hash = "sha256-CW/SF/cAPDv47gS5B7XbVZEE6LC9F1a2I1TLTJ4AWdw=";
    };
  });
}
