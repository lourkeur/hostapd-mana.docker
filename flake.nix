# The flake file is the entry point for nix commands
{
  description = "hostapd-mana in a container";

  # Inputs are how Nix can use code from outside the flake during evaluation.
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.flake-compat.url = "github:edolstra/flake-compat";
  inputs.flake-compat.flake = false;
  inputs.hercules-ci-effects.url = "github:hercules-ci/hercules-ci-effects";
  inputs.nix2container.url = "github:nlewo/nix2container";
  inputs.nixpkgs.url = "nixpkgs/nixos-22.11";

  # Outputs are the public-facing interface to the flake.
  outputs = inputs @ {self, ...}:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} ({withSystem, ...}: {
      imports = [
        inputs.hercules-ci-effects.flakeModule
      ];

      systems = ["x86_64-linux" "aarch64-linux"];

      perSystem = {
        self',
        inputs',
        pkgs,
        ...
      }: {
        packages.default = pkgs.callPackage nix/package.nix {
          inherit (inputs'.nix2container.packages) nix2container;
        };
        formatter = pkgs.alejandra;
      };

      hercules-ci.flake-update.enable = true;
      hercules-ci.flake-update.when.dayOfWeek = "Sat";

      flake.effects = withSystem "x86_64-linux" (
        {
          self',
          inputs',
          pkgs,
          hci-effects,
          system,
          ...
        }: let
          inherit (inputs'.nix2container.packages) skopeo-nix2container;
        in {
          publishContainer.x86_64 = let
            image = self'.packages.default;
          in
            hci-effects.mkEffect {
              inputs = [skopeo-nix2container];
              secretsMap.password = "ghcr-publish-token";
              effectScript = ''
                readSecretString password .token | skopeo login ghcr.io -u lourkeur --password-stdin
                skopeo --insecure-policy copy nix:${image} docker://ghcr.io/lourkeur/hostapd-mana.docker:latest-${system}
              '';
            };
          publishContainer.aarch64 = let
            image = self.packages.aarch64-linux.default;
          in
            hci-effects.mkEffect {
              inputs = [skopeo-nix2container];
              secretsMap.password = "ghcr-publish-token";
              effectScript = ''
                readSecretString password .token | skopeo login ghcr.io -u lourkeur --password-stdin
                skopeo --insecure-policy copy nix:${image} docker://ghcr.io/lourkeur/hostapd-mana.docker:latest-aarch64-linux
              '';
            };
        }
      );
    });
}
