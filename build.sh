#!/usr/bin/env bash
source activate env
set -euxo pipefail
LOG=$(basename $PWD).log

echo "REQUIREMENTS" >> $LOG
pip install -r $(find . -iname requirements-dev.txt) | tee -a $LOG
echo "INSTALL" >> $LOG
pip install . | tee -a $LOG
