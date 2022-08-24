# The flake file is the entry point for nix commands
{
  description = "hostapd-mana in a container";

  # Inputs are how Nix can use code from outside the flake during evaluation.
  inputs.fup.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.3.1";
  inputs.flake-compat.url = "github:edolstra/flake-compat";
  inputs.flake-compat.flake = false;
  inputs.nix2container.url = "github:nlewo/nix2container";

  # Outputs are the public-facing interface to the flake.
  outputs = inputs @ {
    self,
    nixpkgs,
    fup,
    ...
  }:
    fup.lib.mkFlake {
      inherit self inputs;

      supportedSystems = ["x86_64-linux" "aarch64-linux"];

      outputsBuilder = channels:
        with channels.nixpkgs; {
          packages.default = callPackage nix/package.nix {
            inherit (inputs.nix2container.packages.${system}) nix2container;
          };
          formatter = alejandra;
        };
    };
}
