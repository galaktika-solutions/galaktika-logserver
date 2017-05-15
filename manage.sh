#!/bin/bash
set -e

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print() {
  echo "$1" >&2
}
print_() {
  echo -n "$1" >&2
}
print_red() {
  tput setaf 1; print "$1"; tput sgr0
}
print_red_() {
  tput setaf 1; print_ "$1"; tput sgr0
}
print_green() {
  tput setaf 2; print "$1"; tput sgr0
}
print_green_() {
  tput setaf 2; print_ "$1"; tput sgr0
}

file_env() {
  local varname="$1"
  local pattern="s/^$varname=(.*)$/\1/p"
  local val
  val=$(sed -nr "$pattern" "$project_root/.env")
  export "$varname"="$val"
}

printhelp() {
  print ""
  print "Usage: manage.sh [COMMAND] [OPTIONS]"
  print ""
  print "Commands:"
  print_green "    help"
  print "        Print this short manual"
  print_green "    gencert"
  print "        Generate certificates"
  print "        Uses env var HOST defined in .env as common name."
  print "        Requires openssl to be installed."
  print_green "    deploy"
  print "        Depending on the value of MODE,"
  print "        it builds and pushes docker images to registry (MODE=push)"
  print "        it pulls images from the registry (MODE=pull)"
}

push() {
  file_env REGISTRY_URL
  file_env COMPOSE_PROJECT_NAME
  file_env IMAGENAME_PREFIX
  file_env IMAGES
  imgname_prefix="$1"
  if [ -z "$imgname_prefix" ]; then
    print_red "Image name prefix was not given."
    print_ "Is it OK to use "
    print_green_ "$IMAGENAME_PREFIX"
    read -p " ? (yN): " yn
    if [[ $(echo ${yn,} | cut -c 1) = 'y' ]]; then
      imgname_prefix="$IMAGENAME_PREFIX"
      print
    else
      exit 1
    fi
  fi

  # build production docker-compose.yml
  print "building prod/docker-compose.yml"
  input="$project_root/docker-compose.yml"
  output="$project_root/prod/docker-compose.yml"
  cat "$input" | \
    grep -v '# dev only' | \
    sed -r 's|^(.*)# (.*)# prod only|\1\2|' |
    sed -r 's|[[:space:]]*$||'> "$output"

  timestamp=$(date -u +"%Y-%m-%d-%H-%M-%Z")
  images="$IMAGES"
  for service in $images; do
    local_name="$COMPOSE_PROJECT_NAME-$service"
    img="$REGISTRY_URL/$imgname_prefix-$COMPOSE_PROJECT_NAME-$service"
    latest="$img:latest"
    timestamped="$img:$timestamp"

    if ! docker image pull "$latest"; then
      docker image build \
        -t "$local_name" \
        -f "$project_root/docker/$service/Dockerfile" \
        "$project_root/docker/$service/"
    else
      docker image build \
        -t "$local_name" \
        -f "$project_root/docker/$service/Dockerfile" \
        --cache-from "$latest" \
        "$project_root/docker/$service/"
    fi

    print "... tagging $local_name -> $latest"
    docker image tag $local_name $latest
    print "... tagging $local_name -> $timestamped"
    docker image tag $local_name $timestamped
    print "... pushing $latest"
    docker image push $latest
    print "... pushing $timestamped"
    docker image push $timestamped
    print "... untagging $timestamped"
    docker image rm $timestamped
  done

  # now the source
  local_name="$COMPOSE_PROJECT_NAME-src"
  img="$REGISTRY_URL/$imgname_prefix-$COMPOSE_PROJECT_NAME-src"
  latest="$img:latest"
  timestamped="$img:$timestamp"

  if ! docker image pull $latest; then
    docker image build -t "$local_name" "$project_root/docker/src"
  fi
  print "... creating a temporary container to run rsync"
  cmd="rsync --delete-excluded --checksum --recursive --links --perms \
       --del --owner --group --chmod=D777,F666 \
       --exclude-from /new_src/rsync-exclude /new_src/ /src/"
  cid=$(docker container create -v "$project_root:/new_src" $local_name $cmd)
  print "... running rsync"
  docker container start -a $cid
  print "... commit changes"
  docker container commit $cid $local_name
  print "... remove the temporary container"
  docker container rm -v $cid
  print "... tagging $local_name -> $latest"
  docker image tag $local_name $latest
  print "... tagging $local_name -> $timestamped"
  docker image tag $local_name $timestamped
  print "... pushing $latest"
  docker image push $latest
  print "... pushing $timestamped"
  docker image push $timestamped
  print "... removing $timestamped"
  docker image rm $timestamped
}

pull() {
  file_env REGISTRY_URL
  file_env COMPOSE_PROJECT_NAME
  file_env IMAGENAME_PREFIX
  second_run=''
  if [ -f "$project_root/x" ]; then
    second_run='true'
    rm "$project_root/x"
  fi

  images="$IMAGES src"
  for service in $images; do
    local_name="$COMPOSE_PROJECT_NAME-$service"
    img="$REGISTRY_URL/$IMAGENAME_PREFIX-$COMPOSE_PROJECT_NAME-$service"
    docker pull "$img"
    docker tag "$img" "$local_name"
  done

  # copy necessary code
  print "... creating a temporary container to copy from"
  cid=$(docker container create $COMPOSE_PROJECT_NAME-src)
  docker cp "$cid:/src/manage.sh" "$project_root/"
  docker cp "$cid:/src/prod/docker-compose.yml" \
            "$project_root/docker-compose.yml"
  docker container rm -v $cid
  mkdir -p "$project_root/backups"
  chmod +x "$project_root/manage.sh"

  if [ -z "$second_run" ]; then
    touch "$project_root/x"
    exec "$project_root/manage.sh" deploy
  fi
}

deploy() {
  file_env MODE
  case "$MODE" in
    push)
      push "$@"
      ;;
    pull)
      pull
      ;;
    *)
      print_red "MODE not set. Set it in .env"
      exit 1
      ;;
  esac
}


#######################
# Handle command line #
#######################
if [ -z $1 ]; then
  print_red "No command given"
  printhelp
  exit 1
fi

case "$1" in
  help)
    printhelp
    ;;
  gencert)
    gencert
    ;;
  deploy)
    shift
    deploy "$@"
    ;;
  *)
    print_red "Unknown command: $1"
    printhelp
    exit 1
    ;;
esac
