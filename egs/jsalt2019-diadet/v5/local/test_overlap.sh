#!/bin/bash
# Copyright 2019 JSALT (Diego Castan)
# Apache 2.0.
#

net=${1:-./weights/0960.pt}
dataset=${2:-AMI.SpeakerDiarization.MixHeadset}
dest_dir=${3:-./}
loadenv=${4:-true}
envname=${5:-'pyannote'}

#if $loadenv ; then
#source activate ${envname}
#fi

export CONDA_ROOT=/home/janto/usr/local/anaconda3.5
. $CONDA_ROOT/etc/profile.d/conda.sh
conda activate pyannote


export CUDA_VISIBLE_DEVICES=$(free-gpu -n 1)
#export CUDA_VISIBLE_DEVICES=$(free-gpu -n $num_gpus)


echo "pyannote-overlap-detection apply --gpu ${net} ${dataset} ${dest_dir}"
pyannote-overlap-detection apply --gpu ${net} ${dataset} ${dest_dir}
