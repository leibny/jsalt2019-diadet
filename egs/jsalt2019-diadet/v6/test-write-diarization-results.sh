#!/bin/bash

# TESTING(FIXME)-script can be deleted


. ./cmd.sh
. ./path.sh
set -e

stage=1
config_file=default_config.sh

. parse_options.sh || exit 1;
. $config_file

xvector_dir=exp/xvectors_diar/$nnet_name

be_dir=exp/be_diar/$nnet_name/$be_diar_name
score_dir=exp/diarization/$nnet_name/$be_diar_name



rm -f exp/'results.txt'
for filename in exp/diarization/2a.1.voxceleb_div2/*/*/plda_scores_tbest/result.pyannote-der; do

    if [[ "$filename" =~ jsalt19_spkdet.* ]];then 
        continue; 
    fi

    if [ -s $filename ];then
        echo -n $filename | sed 's/exp\/diarization\///g' | sed 's/jsalt19_spkdiar_//g' | sed 's/\/plda_scores_tbest\/result.pyannote-der//g' | sed 's/\//,/g' >> exp/results.txt
	awk '/TOTAL/ { printf ",%.2f,%.2f,%.2f,%.2f,", $2,$11,$9,$13}' $filename >> exp/results.txt
        echo >> exp/results.txt

    fi

done


python3 test-write-diarization-results.py 