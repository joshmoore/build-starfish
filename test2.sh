#!/usr/bin/env bash
source activate env
set -euxo pipefail

mkdir /tmp/in /tmp/out

starfish build --fov-count=2 --hybridization-dimensions='{"z": 3}' /tmp
validate-sptx --experiment-json /tmp/experiment.json
