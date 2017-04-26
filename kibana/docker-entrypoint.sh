#!/bin/bash
set -e

proc_file() {
  local substitutes=()

  while [ "$#" -gt 0 ]
  do
    case "$1" in
      -r)
        if [ -z "$2" ]; then
          echoerr '-r requires a parameter: USER[:GROUP[:HEXPERMS]]'
          exit 1
        fi
        local arr=(${2//:/ })
        local req_user=${arr[0]}
        local req_group=${arr[1]}
        local req_perms=${arr[2]}
        shift; shift
        ;;
      -c)
        if [ -z "$2" ]; then
          echoerr '-c requires a parameter: USER[:GROUP[:HEXPERMS]]'
          exit 1
        fi
        local arr=(${2//:/ })
        local dest_user=${arr[0]}
        local dest_group=${arr[1]}
        local dest_perms=${arr[2]}
        shift; shift
        ;;
      -s)
        if [ -z "$2" ]; then
          echoerr '-s requires a parameter: VARIABLE[-|:default]'
          exit 1
        fi
        substitutes+=($2)
        shift; shift
        ;;
      -*)
        echoerr "Invalid option: $1"
        exit 1
        ;;
      *)
        break
        ;;
    esac
  done

  if [ ! -f "$1" ]; then
    echoerr "orig_file $1 does not exist"
    exit 1
  fi
  local orig_file="$1"
  if [ -n "$2" ]; then
    local dest_file="$2"
  fi

  # -c without dest_file is an error
  if [ -n "$dest_user" ] && [ -z "$dest_file" ]; then
    echoerr 'if -c given dest_file is required'
    exit 1
  fi

  # check required owner
  if [ -n "${req_user}" ]; then
    if [ "$(stat -c '%u' "$orig_file")" != "$req_user" ] && \
       [ "$(stat -c '%U' "$orig_file")" != "$req_user" ]; then
      echoerr "owner of file $orig_file should be $req_user"
      exit 1
    fi
  fi

  # check required group
  if [ -n "$req_group" ]; then
    if [ "$(stat -c '%g' "$orig_file")" != "$req_group" ] && \
       [ "$(stat -c '%G' "$orig_file")" != "$req_group" ]; then
      echoerr "owner's group of file $orig_file should be $req_group"
      exit 1
    fi
  fi

  # check required perms
  if [ -n "$req_perms" ]; then
    local real
    local needed="0$req_perms"
    real="0$(stat -c %a "$orig_file")"
    local diff=$(( ($needed ^ $real) & $real ))
    if [ $diff -ne 0 ]; then
      echoerr "permissionss of file $orig_file should be more restrictive than $req_perms"
      exit 1
    fi
  fi

  # copy and modify owner/perms
  if [ -n "$dest_file" ]; then
    cp -p "$orig_file" "$dest_file"

    if [ -n "$dest_user" ]; then
      chown "$dest_user" "$dest_file"
    fi
    if [ -n "$dest_group" ]; then
      chown :"$dest_group" "$dest_file"
    fi
    if [ -n "$dest_perms" ]; then
      chmod "$dest_perms" "$dest_file"
    fi
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
    if [ ! "$(isset $var_name)" ]; then
      if [ -n "$del_line" ]; then
        sed -i "/${var_name}/ d" "$dest_file"
      elif [ "$(isset default)" ]; then
        escaped=$(echo "${default}" | sed -e 's/[\/&]/\\&/g')
        sed -i "s/\${$var_name}/${escaped}/g" "$dest_file"
      else
        echo "variable $var_name is unset and no default or - option given"
        exit 1
      fi
    else
      escaped=$(echo "${!var_name}" | sed -e 's/[\/&]/\\&/g')
      sed -i "s/\${$var_name}/${escaped}/g" "$dest_file"
    fi
  done
}

# set certificate owner

proc_file -c kibana:kibana:600 /tmp/certificate.key /certificate.key
proc_file -c kibana:kibana:600 /tmp/certificate.crt /certificate.crt

# Add kibana as command if needed
if [[ "$1" == -* ]]; then
	set -- kibana "$@"
fi

# Run as user "kibana" if the command is "kibana"
if [ "$1" = 'kibana' ]; then
	if [ "$ELASTICSEARCH_URL" ]; then
		sed -ri "s!^(\#\s*)?(elasticsearch\.url:).*!\2 '$ELASTICSEARCH_URL'!" /etc/kibana/kibana.yml
	fi

	set -- gosu kibana tini -- "$@"
fi

exec "$@"
