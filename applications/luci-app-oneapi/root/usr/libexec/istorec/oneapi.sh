#!/bin/sh
# Author Xiaobao(xiaobao@linkease.com)

ACTION=${1}
shift 1

do_install() {
  local port=`uci get oneapi.@main[0].port 2>/dev/null`
  local image_name=`uci get oneapi.@main[0].image_name 2>/dev/null`
  local config=`uci get oneapi.@main[0].config_path 2>/dev/null`

  if [ -z "$config" ]; then
    echo "config path is empty!"
    exit 1
  fi

  [ -z "$image_name" ] && image_name="ghcr.io/martialbe/one-api:dev"
  echo "docker pull ${image_name}"
  docker pull ${image_name}
  docker rm -f oneapi

  [ -z "$port" ] && port=3000

  local cmd="docker run --restart=unless-stopped -d -v \"$config:/data\" "

  cmd="$cmd\
  --dns=172.17.0.1 \
  -p $port:3000 "

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  cmd="$cmd --name oneapi \"$image_name\""

  echo "$cmd"
  eval "$cmd"
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the oneapi"
  echo "      upgrade                Upgrade the oneapi"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the oneapi"
  echo "      status                 oneapi status"
  echo "      port                   oneapi port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f oneapi
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} oneapi
  ;;
  "status")
    docker ps --all -f 'name=oneapi' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=oneapi' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*->3000/tcp' | sed 's/0.0.0.0:\([0-9]*\)->.*/\1/'
  ;;
  *)
    usage
    exit 1
  ;;
esac
