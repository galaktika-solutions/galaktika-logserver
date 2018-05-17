#!/bin/bash
set -e

err() {
  echo "$(echo "$1" | tr -s " ")" >&2
  exit 1
}

isset() {
  if [ ! -z ${!1+x} ]; then
    return 0
  fi
  return 1
}

# ask_user <prompt> [y|n|l] [opt1 [opt2 [opt3...]]]
# y: yes/no question, default: yes
# n: yes/no question, default: no
# l: choose one from the given options
# without params: gives back what the user typed
ask_user() {
  local prompt="$1" i r; shift
  case "$1" in
    y|n)
      while true; do
        read -p "$prompt" -r r
        case "${r^^}" in
          Y|YES) echo "y"; break;;
          N|NO)  echo "n"; break;;
          "")    echo "$1"; break;;
          *)     continue;;
        esac
      done;;
    l)
      shift; echo >&2; echo "$prompt" >&2; echo >&2;
      if [ "$#" = 0 ]; then err "Nothing to chose from... exiting"; fi
      i=0; for o in "$@"; do echo -e "$i\t$o" >&2; i=$((i+1)); done; echo >&2
      while true; do
        read -p "Enter a number in range 0-$(($# - 1)): " -r r
        i=0; for o in "$@"; do
          if [ "$r" = "$i" ]; then echo "$o"; return; fi; i=$((i+1))
        done
      done;;
    *)
      read -p "$prompt" -r r
      echo "$r";;
  esac
}

# proc_file [options] orig_file [destination]
# options:
#   -r user[:group[:hexperms]]  required owner/permissions for orig_file
#   -c user[:group[:hexperms]]  change owner/permissions for destination
#      if destination is omitted, the orig_file will be affected
#   -s VARIABLE[-|:[default]]     ${VARIABLE} will be replaced by value
#      if VARIABLE is unset, the behaviour depends on the option given after
#      the variable name:
#        - no option: an error will occur
#        - "-" (ex. MY_VARIABLE-): the line will be deleted
#        - ":[DEFAULT]" (ex. MY_VARIABLE:foo): the default will be substituted
#          note: default can be empty. ex. "MY_VARIABLE:"
proc_file() {
  local substitutes=()
  local dest_file
  local dest_user
  local dest_group
  local req_user
  local req_group
  local req_perms
  local dest_perms
  local orig_file

  while [ "$#" -gt 0 ]
  do
    case "$1" in
      -r)
        if [ -z "$2" ]; then
          err '-r requires a parameter: USER[:GROUP[:HEXPERMS]]'
        fi
        req_user=$(echo "$2" | cut -d : -f 1)
        req_group=$(echo "$2" | cut -sd : -f 2)
        req_perms=$(echo "$2" | cut -sd : -f 3)
        shift; shift
        ;;
      -c)
        if [ -z "$2" ]; then
          err '-c requires a parameter: USER[:GROUP[:HEXPERMS]]'
        fi
        dest_user=$(echo "$2" | cut -d : -f 1)
        dest_group=$(echo "$2" | cut -sd : -f 2)
        dest_perms=$(echo "$2" | cut -sd : -f 3)
        shift; shift
        ;;
      -s)
        if [ -z "$2" ]; then
          err '-s requires a parameter: VARIABLE[-|:[DEFAULT]]'
        fi
        substitutes+=($2)
        shift; shift
        ;;
      -*)
        err "Invalid option: $1"
        ;;
      *)
        break
        ;;
    esac
  done

  # orig_file check
  if [ ! -f "$1" ]; then
    err "orig_file $1 does not exist"
  fi
  orig_file="$1"

  if [ -n "$2" ]; then
    dest_file="$2"
  fi

  # check required owner
  if [ -n "${req_user}" ]; then
    if [ "$(stat -c '%u' "$orig_file")" != "$req_user" ] && \
       [ "$(stat -c '%U' "$orig_file")" != "$req_user" ]; then
      err "owner of file $orig_file should be $req_user"
    fi
  fi

  # check required group
  if [ -n "$req_group" ]; then
    if [ "$(stat -c '%g' "$orig_file")" != "$req_group" ] && \
       [ "$(stat -c '%G' "$orig_file")" != "$req_group" ]; then
      err "group of file $orig_file should be $req_group"
    fi
  fi

  # check required perms
  if [ -n "$req_perms" ]; then
    local real
    local needed="0$req_perms"
    real="0$(stat -c %a "$orig_file")"
    local diff=$(( ($needed ^ $real) & $real ))
    if [ $diff -ne 0 ]; then
      err "permissions of file $orig_file should be more restrictive than $req_perms"
    fi
  fi

  # copy and modify owner/perms
  if [ -n "$dest_file" ]; then
    cp -p "$orig_file" "$dest_file"
  fi

  if [ -z "$dest_file" ]; then
    dest_file="$orig_file"
  fi

  if [ -n "$dest_user" ]; then
    chown "$dest_user" "$dest_file"
  fi
  if [ -n "$dest_group" ]; then
    chown :"$dest_group" "$dest_file"
  fi
  if [ -n "$dest_perms" ]; then
    chmod "$dest_perms" "$dest_file"
  fi

  # substitute
  for var in "${substitutes[@]}"
  do
    unset default
    local var_name="$var"
    local del_line=''

    # search for a colon first, if there is not any, search for - (delete line)
    if [ "$(echo "$var" | cut -d ':' -s -f 2- | wc -c)" -gt 0 ]; then
      local default
      var_name=$(echo "$var" | cut -d ':' -f 1)
      default=$(echo "$var" | cut -d ':' -f 2-)
    elif [ ${var: -1} = '-' ]; then
      del_line=true
      var_name=${var:0:-1}
    fi

    local escaped
    if ! isset "$var_name"; then
      if [ -n "$del_line" ]; then
        sed -i "/${var_name}/ d" "$dest_file"
      elif isset default; then
        escaped=$(echo "${default}" | sed -e 's/[\/&]/\\&/g')
        sed -i "s/\${$var_name}/${escaped}/g" "$dest_file"
      else
        err "variable $var_name is unset and no default or - option given"
      fi
    else
      escaped=$(echo "${!var_name}" | sed -e 's/[\/&]/\\&/g')
      sed -i "s/\${$var_name}/${escaped}/g" "$dest_file"
    fi
  done
}

# runsql <command> <db=postgres> <host=localhost> <dbuser=postgres>
runsql() {
  db="$2"; if [ -z "$db" ]; then db=postgres; fi
  host="$3"; if [ -z "$host" ]; then host=localhost; fi
  user="$4"; if [ -z "$user" ]; then user=postgres; fi
  psql -v ON_ERROR_STOP=1 -h "$host" -U "$user" -d "$db" -c "$1"
}

wait_for_db() {
  while ! PGPASSWORD="$(readvar DB_PASSWORD)" runsql 'select 1;' django postgres django &> /dev/null; do
    echo "postgres not ready yet..."; sleep 1
  done
  echo "postgres ready"; return 0
}

readvar() {
  envfile="$2"; if ! [ -f "$envfile" ]; then envfile='/.env'; fi
  num="$(sed -nr "/^$1=/ p" "$envfile" | wc -l)"
  if [ "$num" -eq 0 ]; then
    if [ "$#" -eq 2 ]; then echo $2; return 0; fi
    err "variable not defined in $envfile: $1"
  fi
  if [ "$num" -gt 1 ]; then
    err "multiple definition of variable in $envfile: $1"
  fi
  sed -nr "s/^$1=(.*)$/\1/ p" "$envfile"; return 0
}

check_file() {
  if [ "$(readvar INSECURE_FILES_ALLOWED false)" = 'false' ]; then
    proc_file -r "$1" "$2"
  fi
}
