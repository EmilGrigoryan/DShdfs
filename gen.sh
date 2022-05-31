#!/bin/bash
# generator of test data with following format:
# metricId, timestamp, value

echo "Starting data generator"

# declare default amount of test data
iter=100000
# if there's 1st cmd arg, let i = 1st arg
test -n "$1" && iter=$1

# make output directory & clear it
mkdir -p input
rm -rf input/*

# declare initial time
timestamp=$(( RANDOM * RANDOM /10))

# generate data starting from initial time
echo "Progress:"
prevProgress=0
for j in {1..100000}
do
    progress=$((100*j/iter))
    if [[ $prevProgress -ne $progress ]] && [[ $(($progress % 10)) -eq 0 ]]; then
        echo "$progress%"
        prevProgress=$progress
    fi
    metricId=$(( RANDOM % 5 + 1))
    value=$(( RANDOM % 200 /5 *5 ))
    echo "$metricId, $timestamp, $value" >> "input/test.txt"
    timestamp=$((timestamp + RANDOM))
done
echo "Ending data generator"
exit 1
