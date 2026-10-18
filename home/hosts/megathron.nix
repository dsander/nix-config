{ ... }:

{
  # Zed must not open the RTX 5080 while it is available for VM passthrough.
  home.file.".local/bin/zeditor" = {
    source = ../config/zed/zeditor-intel;
    executable = true;
  };

  home.file.".local/share/applications/dev.zed.Zed.desktop".source =
    ../config/zed/dev.zed.Zed.desktop;

  # Keep KWin on the Intel iGPU so it does not hold the RTX 5080.
  home.file.".config/plasma-workspace/env/10-intel-gpu.sh".source =
    ../config/plasma/10-intel-gpu.sh;

  home.file.".config/systemd/user/plasma-kwin_wayland.service.d/10-intel-egl.conf".source =
    ../config/plasma/kwin-intel-egl.conf;

  home.file.".local/bin/winvm" = {
    source = ../config/winvm;
    executable = true;
  };
}
