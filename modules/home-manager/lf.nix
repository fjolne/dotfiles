{ pkgs, ... }:

let
  lfCopy = pkgs.writeShellScript "lf-copy" ''
    set -eu

    mode="$1"
    path="$2"

    case "$mode" in
      relative)
        path="$(${pkgs.coreutils}/bin/realpath --relative-to="''${LF_LAUNCH_DIR:-$PWD}" -- "$path")"
        ;;
      absolute)
        path="$(${pkgs.coreutils}/bin/realpath -- "$path")"
        ;;
      contents)
        ;;
      *)
        printf 'unknown copy mode: %s\n' "$mode" >&2
        exit 2
        ;;
    esac

    if [ "$mode" = contents ]; then
      encoded="$(${pkgs.coreutils}/bin/base64 --wrap=0 -- "$path")"
    else
      encoded="$(printf '%s' "$path" | ${pkgs.coreutils}/bin/base64 --wrap=0)"
    fi

    if [ -n "''${TMUX:-}" ]; then
      printf '\033Ptmux;\033\033]52;c;%s\007\033\\' "$encoded" > /dev/tty
    else
      printf '\033]52;c;%s\007' "$encoded" > /dev/tty
    fi
  '';
in
{
  programs.lf = {
    enable = true;
    package = pkgs.writeShellScriptBin "lf" ''
      export LF_LAUNCH_DIR="$PWD"
      exec ${pkgs.lf}/bin/lf "$@"
    '';
    keybindings = {
      "<a-y>" = "$" + "${lfCopy} relative \"$f\"";
      I = "$bat -p --paging=always $f";
      "<a-Y>" = "$" + "${lfCopy} absolute \"$f\"";
      Y = "$" + "${lfCopy} contents \"$f\"";
      j = "$jq . $f | $PAGER";
      J = "$jq . $f | bat -p --paging=always -l json";
    };
    previewer.source = pkgs.writeShellScript "pv.sh" ''bat -pp --color always "$@"'';
  };
}
