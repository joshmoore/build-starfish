#!/usr/bin/env bash
source activate env
set -euxo pipefail

mkdir /tmp/in /tmp/out

cd starfish
python examples/get_iss_data.py --d=true /tmp/in /tmp/out
validate-sptx --experiment-json /tmp/out/experiment.json
