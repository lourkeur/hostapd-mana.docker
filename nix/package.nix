{
  dockerTools,
  hostapd-mana,
  nix2container,
  nano,
  openssl,
  busybox,
  s6-linux-init,
  writeScriptBin,
}:
nix2container.buildImage {
  name = "hostapd-mana";
  tag = "latest";
  copyToRoot = [
    (writeScriptBin ".entrypoint" (builtins.readFile ../entrypoint.sh))
    openssl
    hostapd-mana
    busybox
    nano
  ];

  maxLayers = 127;

  config.Entrypoint = ["/bin/.entrypoint"];
  config.Volumes."/data" = {};
}
