# I dockerized hostapd-mana
[![built with Nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

`hostapd-mana.docker` is a
single-command,
self-contained,
least-privileged way 
to run the excellent [hostapd-mana](https://github.com/sensepost/hostapd-mana)
pentesting tool.

## Requirements
Bare-metal Linux.
Docker, Podman, whichever you prefer.
Both x86 and aarch64 are supported.
Yes, you can run it on your Raspberry Pi!

## Installation
```sh
sudo docker run --cap-add net_admin --cap-add net_raw --network=host -ti ghcr.io/lourkeur/hostapd-mana.docker
```

## Usage
Busybox and Nano
are included.
Refer to [the Hostapd Wiki](https://github.com/sensepost/hostapd-mana/wiki)
as you would prior.
