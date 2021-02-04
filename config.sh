#!/bin/bash

pushd $(cd $(dirname $0) && pwd) >/dev/null

SSH_VERSION=$(ssh -V 2>&1 | grep OpenSSH | awk '{print $1}' | sed "s/OpenSSH_//" | grep -o "[0-9.]\+" | head -1)

function help() {
  echo "Usage: $0 [add] server_name ssh_settings [via server_name [ssh_settings]]..."
  echo "       $0 list|update"
  echo "       $0 del|exp sever_name"
  echo "       $0 show|check [server_name]"
  echo "       ssh_settings := ssh_user server_ip [ssh_port]"
  echo ""
  echo "generate ~/.ssh/config specified string."
  echo "  list     : show defined server list"
  echo "  show     : show config from defined servers' .config"
  echo "  update   : generate ~/.ssh/config"
  echo "  add      : show defined server list"
  echo "  exp      : create except script"
  echo "  check    : check duplicate entry"
  echo "  del      : delete config"
}

function check() {
  cat ~/.ssh/config | grep ^Host | sort | uniq -c | sort | grep -v "^\s\s*1"
}

function list() {
  #tree -d $(pwd)
  #pwd; find $(dirname $0) -type d | sort | sed '1d;s/^\.//;s/\/\([^/]*\)$/|--\1/;s/\/[^/|]*/| /g'
  pwd; 
  find . -type d -not -path "./.*/*" -not -name ".*" | sort | sed 's/^\.//;s/\/\([^/]*\)$/|--\1/;s/\/[^/|]*/| /g'
}

function show() {
  if [[ "$1" == "" ]]; then
    filter="."
  else
    filter=$1
  fi

  for d in $(find -mindepth 1 -type d)
  do
    if [[ ${d} =~ ${filter} ]]; then
      if [[ -e ${d}/.config ]]; then
        echo "Host "$(basename ${d})
        cat ${d}/.config | sed -e '1s/^\(.*\)$/    User \1/g' | sed -e '2s/^\(.*\)$/    HostName \1/g' | sed -e '3s/^\(.*\)$/    Port \1/g'
        echo "    StrictHostKeyChecking no"
        if [[ $(echo "${SSH_VERSION} >= 5.6" | bc) == 1 ]]; then
          echo "    ControlMaster auto"
          echo "    ControlPath ~/.ssh/mux-%r@%h:%p"
          echo "    ControlPersist 10"
        fi
        via=$(basename $(dirname ${d}))
        if [[ ! "$via" == "." ]]; then
          rc=$(grep ${via} ~/ssh_config/.remote_command | awk '{print $2}')
          if [[ "${rc}" == "" ]]; then
            rc="nc"
          fi
          echo "    ProxyCommand ssh $via ${rc} %h %p"
        fi
        echo ""
      fi
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
        mkdir -p "${viapath}/${h[0]}"
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

function del() {
  if [[ $* =~ "/" ]]; then
    ls $*
  else
    for f in $(find ./ -iname $1 -type d)
    do
      read -p "delete $f ? [y/N]: " yn
      echo $yn
      if [[ $yn == "y" ]]; then
        rm -rf $f
      fi
    done
  fi
  $0 update
}

if [[ "$1" == "" ]] || [[ "$1" == "help" ]]; then
  echo "missing ssh_settings"
  help
  exit 0
fi

if [[ "$1" == "check" ]]; then
  check
  exit 0
fi

if [[ "$1" == "show" ]]; then
  show $2
  exit 0
fi

if [[ "$1" == "list" ]]; then
  list
  exit 0
fi

if [[ "$1" == "update" ]]; then
  mv ~/.ssh/config ~/.ssh/config.$(date +"%y%m%d")
  cat ~/.ssh/prefix > ~/.ssh/config
  show >> ~/.ssh/config
  chmod 600 ~/.ssh/config
  echo "updated."
  exit 0
fi

if [[ "$1" == "exp" ]]; then
  exp $2
  exit 0
fi

if [[ "$1" == "del" ]]; then
  del $2
  exit 0
fi

# create directory and .config file for to generate ~/.ssh/config
if [[ "$1" == "add" ]]; then
  shift;
fi
add $*

popd > /dev/null


