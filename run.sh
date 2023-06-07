#!/bin/bash
trap 'kill 0' EXIT
for i in {1..5}
do
    ./build/reno.x86_64 &
done
wait