#!/bin/sh

set -ex

if [ -f "/opt/conda/etc/profile.d/conda.sh" ]; then
    . /opt/conda/etc/profile.d/conda.sh
    if [ -d "/home/jovyan/.conda/envs/Anaconda" ]; then
        conda activate Anaconda
    fi
fi

python -m pip --no-cache-dir install amplpy --upgrade
python -m amplpy.modules install --no-cache-dir base --upgrade
python -m amplpy.modules run amplkey activate || true
python -m amplpy.modules run ampl -vvq
python -m amplpy.modules run amplkey show license 
