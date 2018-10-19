#!/bin/bash

pushd $(cd $(dirname $0) && pwd) >/dev/null

function help() {
  echo "Usage: $0 [add] server_name ssh_settings [via server_name [ssh_settings]]..."
  echo "       $0 [list | show | update ]"
  echo "       ssh_settings := ssh_user server_ip [ssh_port]"
  echo ""
  echo "generate ~/.ssh/config specified string."
  echo "  list     : show defined server list"
  echo "  show     : show config from defined servers' .config"
  echo "  update   : generate ~/.ssh/config"
  echo "  add      : show defined server list"
  echo "  exp      : create except script"
}

function list() {
  tree -d $(pwd)
}

function show() {
  for d in $(find -mindepth 1 -type d)
  do
    if [[ -e ${d}/.config ]]; then
      echo "Host "$(basename ${d})
      cat ${d}/.config | sed -e '1s/^\(.*\)$/    User \1/g' | sed -e '2s/^\(.*\)$/    HostName \1/g' | sed -e '3s/^\(.*\)$/    Port \1/g'
      echo "    StrictHostKeyChecking no"
      via=$(basename $(dirname ${d}))
      if [[ ! "$via" == "." ]]; then
        echo "    ProxyCommand ssh $via nc %h %p"
      fi
      echo ""
    fi
  done
}

function add() {
  viapath="./"

  echo $* | sed 's/via/\n/g' | tac | while read line
  do
    h=(${line})
    n=${#h[@]}
    if [[ ! -d ${viapath}/${h[0]} ]]; then
      if [[ ${n} -ge 2 ]]; then
        mkdir "${viapath}/${h[0]}"
        viapath="${viapath}/${h[0]}"
        echo ${h[1]} > ${viapath}/.config
        for i in $(seq 2 1 $(( ${n} - 1 )))
        do
          echo ${h[${i}]} >> ${viapath}/.config
          echo "${h} added."
        done
      else
        echo "missing username of '${h[0]}', abort"
        exit 0
      fi
    else
      viapath=${viapath}/${h[0]}
      if [[ -f "${viapath}/.config" ]]; then
        if [[ ${n} -ge 3 ]]; then
          echo ${h[1]} > ${viapath}/.config
          for i in $(seq 2 1 $(( ${n} - 1)))
          do
            echo ${h[${i}]} >> ${viapath}/.config
          done
        fi
      fi
    fi
  done
 }

function exp() {
  buf="$(pwd)/.expects/.auto server $1 passwords "
  path="."
  pswds=""
  p=$(find ./ -type d -name $1)
  if [[ -d $p ]]; then
    ds="${p//\// }"
    for d in $ds
    do
      if [[ "$d" != "." ]]; then
        path="$path/$d"
        user=$(cat ${path}/.config | head -1 | tail -1)
        ip=$(cat ${path}/.config | head -2 | tail -1)
        read -p "[${d}] ${user}@${ip}'s password: " a
        pswds="$pswds$a "
      fi
    done
    pswds=${pswds% *}
    buf="${buf}\"${pswds}\" command \"\""
    echo $buf > $p/.auto
    chmod +x $p/.auto
    unlink .expects/$1 2>/dev/null
    ln -s  $(pwd)/${p/.\//}/.auto .expects/$1
    echo "create $1's script for auto login."
  else
    echo "missing target $1, abort"
  fi
}

if [[ "$1" == "" ]] || [[ "$1" == "help" ]]; then
  echo "missing ssh_settings"
  help
  exit 0
fi

if [[ "$1" == "show" ]]; then
  show
  exit 0
fi

if [[ "$1" == "list" ]]; then
  list
  exit 0
fi

if [[ "$1" == "update" ]]; then
  mv ~/.ssh/config ~/.ssh/config.$(date +"%y%m%d")
  show > ~/.ssh/config
  chmod 600 ~/.ssh/config
  echo "updated."
  exit 0
fi

if [[ "$1" == "exp" ]]; then
  exp $2
  exit 0
fi

# create directory and .config file for to generate ~/.ssh/config
if [[ "$1" == "add" ]]; then
  shift;
fi
add $*

popd > /dev/null

