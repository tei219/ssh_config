#!/bin/bash

function list() {
  tree $(dirname $0)
}

function show() {
  for d in $(find -mindepth 1 -type d)
  do
    echo "Host "$(basename ${d})
    if [[ -e ${d}/.config ]]; then
      cat ${d}/.config | sed -e '1s/^\(.*\)$/    User \1/g' | sed -e '2s/^\(.*\)$/    HostName \1/g' | sed -e '3s/^\(.*\)$/    Port \1/g'
    fi
    echo "    StrictHostKeyChecking no"
    via=$(basename $(dirname ${d}))
    if [[ ! "$via" == "." ]]; then
      echo "    ProxyCommand ssh $via nc %h %p"
    fi
    echo ""
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

if [[ "$1" == "" ]]; then
  echo "Usage: $0 hostname connect_user connect_ip [port_number comment ...] (via hostname connect_user connect_ip [ ... ] (via... ))"
  echo " "
  echo "add ssh hosts and updated output .ssh/config "
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

# create directory and .config file for to make ~/.ssh/config
add $*
echo "added."


