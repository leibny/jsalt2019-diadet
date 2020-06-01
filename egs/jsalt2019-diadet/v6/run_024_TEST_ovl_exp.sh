#!/bin/bash
# Copyright 2017-2018  David Snyder
#           2017-2018  Matthew Maciejewski
#           2019 Latané Bullock, Paola Garcia (JSALT 2019) 
#
# Apache 2.0.
#
# This script performs VB resegmentation with a UBM and i-vector 
# extractor as trained in run_026_train_ubm_ive_reseg.sh
# Stages 2 and 3 evaluate the output RTTMs

. ./cmd.sh
. ./path.sh
set -e

stage=1
config_file=default_config.sh

. parse_options.sh || exit 1;
. $config_file


# change score_dir according to desired PLDA-type 
# e.g. be_diar_name or be_diar_babytrain_name or be_diar_chime5_name
score_dir=exp/diarization/overlap_exp_herve_old


# retrieves all which don't already have VB performed 
# can perform additional filtering as needed
# dsets_path=$score_dir
# dsets_test=`find $dsets_path  -maxdepth 1 -name "jsalt19_spkdiar*" \
#   | xargs -l basename \
#   | sort \
#   | grep -v VB \
#   | grep -v sri \
#   | grep -v gtvad \
#   | grep -v dev \
#   `

dsets_test="jsalt19_spkdiar_ami_dev_Mix-Headset jsalt19_spkdiar_ami_eval_Mix-Headset"


if [ $stage -le 1 ]; then

  for name in $dsets_test
    do

    if [[ "$name" =~ .*_dev.* ]];then
        dev_eval=dev
      elif [[ "$name" =~ .*_eval.* ]];then
        dev_eval=eval
      else
        echo "Dataset dev/eval not found"
        exit 1
      fi

    # eval best with pyannote
    $train_cmd $score_dir/$name/pyannote.log \
        local/pyannote_score_diar.sh $name $dev_eval $score_dir/$name 
  done
fi
