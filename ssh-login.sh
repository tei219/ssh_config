#!/bin/bash

pushd $(pwd) >/dev/null
cd $(dirname $0)

srv=$1

if [[ -z $srv ]];then
  echo "missing serve, abort"
  echo "Usage: $0 server"
  exit 0;
fi

if [[ -e ./.expects/$1 ]]; then
  ./.expects/$1
else
  ssh $srv
fi

popd >/dev/null
