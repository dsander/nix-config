{ ... }:

{
  # Zed must not open the RTX 5080 while it is available for VM passthrough.
  home.file.".local/bin/zeditor" = {
    source = ../config/zed/zeditor-intel;
    executable = true;
  };

  home.file.".local/share/applications/dev.zed.Zed.desktop".source =
    ../config/zed/dev.zed.Zed.desktop;

  home.file.".local/bin/winvm" = {
    source = ../config/winvm;
    executable = true;
  };
}
