{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkOption types;
  cfg = config.services.tribler;
in {
  imports = [
  ];

  options.services.tribler = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the Tribler bittorrent client.
      '';
    };
  };

  config = {
    systemd.services.tribler = mkIf cfg.enable {
      description = "The Tribler bittorrent client.";
      path = [ pkgs.tribler ];
      script = ''
        
      '';
    };
  };
}
