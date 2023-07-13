{ config, pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "dokku-app-local-ip" ''
      ssh $1 docker inspect --format \'{{ .NetworkSettings.IPAddress }}\' $2.web.1
    '')

    (pkgs.writeShellScriptBin "dokku-ssh-tunnel" ''
      ssh -v -N -L localhost:$\{3-37129\}:$(dokku-app-local-ip $1 $2):$\{3-37129\} $1
    '')
  ];

}
