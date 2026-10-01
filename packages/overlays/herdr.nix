# herdr from our fork : https://github.com/dsander/herdr/tree/add-last-tab-command
#
{ herdrFlake }:
final: prev: {
  herdr = prev.herdr.overrideAttrs (finalAttrs: _: {
    version = (builtins.fromTOML (builtins.readFile "${herdrFlake}/Cargo.toml")).package.version;

    src = herdrFlake.outPath;

    cargoDeps = final.rustPlatform.importCargoLock {
      lockFile = "${herdrFlake}/Cargo.lock";
    };

    zigDeps = final.zig_0_16.fetchDeps {
      inherit (finalAttrs) pname version;
      src = "${finalAttrs.src}/vendor/libghostty-vt";
      fetchAll = true;
      hash = "sha256-Cy0DdSvce+fhOFIfxHMQGF2b2j16UkS27UpGbfC42XI=";
    };
  });
}
