# herdr from our fork : https://github.com/dsander/herdr/tree/prefix-key-keybind
final: prev: {
  herdr = prev.herdr.overrideAttrs (finalAttrs: prevAttrs: {
    version = "0.8.2";

    src = final.fetchFromGitHub {
      owner = "dsander";
      repo = "herdr";
      rev = "70f7a870660864b7a87b085552fafd3bd203d9a9";
      hash = "sha256-rP84LXBuPZILJKdBH+TNwNil46/MQ0JVqfAacOPxlYU=";
    };

    cargoDeps = final.rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) pname version src;
      hash = "sha256-4VThqPwYYEsGvaOKjBeL6XAC5bnNWB6oUMWP/uXc/UQ=";
    };
  });
}
