#!/bin/env sh
set -euo pipefail

#/ Usage:
#/ Description: install TPT's beamer theme on a POSIX-compliant machine
#/ Options:
#/   --global: Installs for all user (needs root rights)
#/   --help: Display this help message
usage() { grep '^#/' "$0" | cut -c4- ; exit 0 ; }

readonly LOG_FILE="/tmp/install-telecom-beamer.log"
info()    { echo "[INFO]    $*" | tee -a "$LOG_FILE" >&2 ; }
warning() { echo "[WARNING] $*" | tee -a "$LOG_FILE" >&2 ; }
error()   { echo "[ERROR]   $*" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo "[FATAL]   $*" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }
check_rights()  { 
  if [ "$(id -u)" -ne 0 ];
  then
    error "Not sufficient rights to $1"
    exit 2
  fi
}

TEXMFLOCAL="$HOME/texmf"
PACKAGE="$TEXMFLOCAL/tex/latex/beamerx/"
FONTS="$TEXMFLOCAL/fonts/truetype/"
PERMS="Dg+s,ug+w,o-w,+X,+r"

ensure_tree_exists() {
  mkdir -p "$PACKAGE" "$FONTS"
}

install_in_tree() {
  info "Installing source files in $PACKAGE"
  rsync --recursive --exclude-from=install/.exclude --delete-excluded --chmod="$PERMS" source/ "$PACKAGE/"
  info "Installing font files in $FONTS"
  rsync --recursive --update --chmod="$PERMS" fonts/ "$FONTS/"
}

update_database() {
  info "Updating database…"
  texhash || mktexlsr || warning "Couldn't update database."
}

cleanup() {
  case "$?" in
    1)
      fatal "Install could not complete."
      ;;
    2)
      warning "Install has completed, with errors."
      ;;
    *)
      info "Install has completed."
      ;;
  esac
}
trap cleanup EXIT

#Parsing options
expr "$*" : ".*--help" > /dev/null && usage
expr "$*" : ".*--global" > /dev/null && TEXMFLOCAL="$(kpsewhich -var-value TEXMFLOCAL)" && check_rights "access $TEXMFLOCAL"

#Install process
ensure_tree_exists
install_in_tree
update_database

