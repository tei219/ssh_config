#!/bin/bash

pushd $(pwd) >/dev/null
cd $(dirname $0)

srv=$1
shift
commands=$@

if [[ -z $srv ]]; then
  echo "missing server, abort"
  echo "Usage: $0 defined-server [\"command\"]"
  exit 0
fi

if [[ -e ./.expects/${srv} ]]; then
   cmd=$(cat ./.expects/${srv})
   bash -c "${cmd%\"\"} \"$(echo -E ${commands} | sed 's/["]/\\\"/g' | sed 's/\\\\/\\\\\\/g')\" "
else
  ssh ${srv}
fi

popd >/dev/null
