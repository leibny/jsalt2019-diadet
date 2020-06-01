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
score_dir=exp/diarization/overlap_exp_herve_new_oracleASS

VB_dir=exp/VB
VB_models_dir=$VB_dir/models
VB_suff="VB"          # this the suffix added to the VB directories
max_iters=1           # VB resegmentation paramter: max iterations
loop_prob=0.95           # VB resegmentation paramter: loop probability

num_components=1024   # the number of UBM components (used for VB resegmentation)
ivector_dim=400       # the dimension of i-vector (used for VB resegmentation)


# retrieves all which don't already have VB performed 
# can perform additional filtering as needed
# dsets_path=$score_dir
# dsets=`find $dsets_path  -maxdepth 1 -name "jsalt19_spkdiar*" \
#   | xargs -l basename \
#   | sort \
#   | grep -v VB \
#   | grep -v sri \
#   | grep -v gtvad \
#   | grep -v dev \
#   `

dsets="jsalt19_spkdiar_ami_dev_Mix-Headset jsalt19_spkdiar_ami_eval_Mix-Headset"


if [ $stage -le 1 ]; then

  for name in $dsets
    do

    # append VB suffix to the data dir, then output to that location
    output_dir=$score_dir/${name}_${VB_suff}
    # init_rttm_file=$score_dir/$name/plda_scores_tbest/rttm
    init_rttm_file=$score_dir/$name/rttm

    # choose to overwrite a file if VB has already been performed ?
    # if [ -f $output_dir/rttm ]; then
    #   continue
    # fi 
    mkdir -p $output_dir || exit 1; 


    # #jobs differ because of the limited number of utterances and 
    # speakers for chime5 - there are just two speakers, so it refuses to split
    # into more than 2
    num_utt=$(wc -l data/$name/utt2spk | cut -d " " -f 1)
	  nj=$(($num_utt < 40 ? 2:40))

    # TODO: turn this into switch?
    trained_dir=jsalt19_spkdiar_ami_train


    # VB resegmentation. In this script, I use the x-vector result to 
    # initialize the VB system. You can also use i-vector result or random 
    # initize the VB system. The following script uses kaldi_io. 
    # You could use `sh ../../../tools/extras/install_kaldi_io.sh` to install it
    # Usage: diarization/VB_resegmentation.sh <data_dir> <init_rttm_filename> <output_dir> <dubm_model> <ie_model>
    VB/diarization/VB_resegmentation.sh --nj $nj --cmd "$train_cmd --mem 10G" \
      --max-iters $max_iters --initialize 1 \
      --loopProb $loop_prob \
      data/$name $init_rttm_file $output_dir \
      $VB_models_dir/$trained_dir/diag_ubm_$num_components/final.dubm $VB_models_dir/$trained_dir/extractor_diag_c${num_components}_i${ivector_dim}/final.ie || exit 1; 
  done
fi

wait


# # retrieves all which don't already have VB performed 
# vb_dsets=`find $dsets_path  -maxdepth 1 -name "jsalt19_spkdiar*" \
#   | xargs -l basename \
#   | sort \
#   | grep "$VB_suff" \
#   `
# retrieves all which don't already have VB performed 
vb_dsets="jsalt19_spkdiar_ami_dev_Mix-Headset_VB jsalt19_spkdiar_ami_eval_Mix-Headset_VB"

if [ $stage -le 2 ]; then
  
  for name in $vb_dsets
  do

    if [[ "$name" =~ .*_dev.* ]];then
      dev_eval=dev
    elif [[ "$name" =~ .*_eval.* ]];then
      dev_eval=eval
    else
      echo "Dataset dev/eval not found"
      exit 1
    fi

    echo $name

    # TESTING(FIXME)
    # we can skip those files which have already been evaluated
    if [ -s $dsets_path/$name/result.pyannote-der ];then
      continue
    fi
    

    # Compute the DER after VB resegmentation wtih 
    # PYANNOTE
    # "Usage: $0 <dataset> <dev/eval> <score-dir>"
    echo "Starting Pyannote rttm evaluation for $name ... "
    $train_cmd $score_dir/${name}/pyannote.log \
        local/pyannote_score_diar.sh $name $dev_eval $score_dir/${name}
  
    # ln -frs $score_dir/${name} $score_dir/${name}/plda_scores_tbest

  done

fi





