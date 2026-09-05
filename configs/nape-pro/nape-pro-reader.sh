#!/bin/bash
while true; do
  cats=""
  for dev in /dev/nape-pro-vendor /dev/nape-pro-doh; do
    if [ -e "$dev" ]; then
      cat "$dev" > /dev/null &
      cats="$cats $!"
    fi
  done
  [ -n "$cats" ] && wait $cats
  sleep 2
done