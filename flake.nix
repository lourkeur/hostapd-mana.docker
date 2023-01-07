# The flake file is the entry point for nix commands
{
  description = "hostapd-mana in a container";

  # Inputs are how Nix can use code from outside the flake during evaluation.
  inputs.fup.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.3.1";
  inputs.flake-compat.url = "github:edolstra/flake-compat";
  inputs.flake-compat.flake = false;
  inputs.hercules-ci-effects.url = "github:hercules-ci/hercules-ci-effects";
  inputs.nix2container.url = "github:nlewo/nix2container";
  inputs.nixpkgs.url = "nixpkgs/nixos-22.11";

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

      sharedOverlays = [
        inputs.hercules-ci-effects.overlay
      ];

      outputsBuilder = channels: let
        inherit (channels.nixpkgs) alejandra callPackage effects system;
        inherit (inputs.nix2container.packages.${system}) nix2container skopeo-nix2container;
        image = callPackage nix/package.nix {inherit nix2container;};
      in {
        packages.default = image;
        formatter = alejandra;
        effects.publishContainer = effects.mkEffect {
          inputs = [image.copyTo skopeo-nix2container];
          secretsMap.password = "ghcr-publish-token";
          effectScript = ''
            readSecretString password .token | skopeo login ghcr.io -u lourkeur --password-stdin
            copy-to docker://ghcr.io/lourkeur/hostapd-mana.docker:latest-${system}
          '';
        };
      };
    };
}
