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

# We are not going to use enhancement

be_dihard_dir=exp/be_diar/$nnet_name/$be_diar_dihard_name
#be_dihard_enh_dir=exp/be_diar/$nnet_name/${be_diar_dihard_name}_enhanced
score_dihard_dir=exp/diarization/$nnet_name/$be_diar_dihard_name
#score_dihard_enh_dir=exp/diarization/$nnet_name/${be_diar_dihard_name}_enhanced

VB_dir=exp/VB
VB_models_dir=$VB_dir/models
VB_suff="VB"          # this the suffix added to the VB directories
max_iters=1           # VB resegmentation paramter: max iterations

num_components=1024   # the number of UBM components (used for VB resegmentation)
ivector_dim=400       # the dimension of i-vector (used for VB resegmentation)


#dev datasets
#dsets_spkdiar_dev_evad=(jsalt19_spkdiar_dihard_dev_{U01,U06})
#dsets_spkdiar_dev_evad=(dev_beamformit_dereverb_stats_seg_paola)
dsets_spkdiar_dev_evad=(dev)
#dsets_spkdiar_dev_evad=(jsalt19_spkdiar_dihard{,_enhanced}_dev_{U01,U06})

#eval datasets
dsets_spkdiar_eval_evad=(eval)
#dsets_spkdiar_eval_evad=($(echo ${dsets_spkdiar_dev_evad[@]} | sed 's@_dev@_eval@g'))

dsets_dev=(${dsets_spkdiar_dev_evad[@]})
dsets_eval=(${dsets_spkdiar_eval_evad[@]})

# consists of all DIAR datasets
dsets_test="${dsets_dev[@]} ${dsets_eval[@]}"

# # retrieves all which don't already have VB performed
# # can perform additional filtering as needed
# dsets_path=$score_dir
# dsets_test=`find $dsets_path  -maxdepth 1 -name "jsalt19_spkdiar*" \
#   | xargs -l basename \
#   | sort \
#   | grep -v VB \
#   | grep -v sri \
#   | grep -v gtvad \
#   | grep -v dev \
#   `


if [ $stage -le 1 ]; then

  for name in $dsets_test
    do

    # # append VB suffix to the data dir, then output to that location
    # output_dir=$score_dir/${name}_${VB_suff}
    # init_rttm_file=$score_dir/$name/plda_scores_tbest/rttm

    # # choose to overwrite a file if VB has already been performed ?
    # if [ -f $output_dir/rttm ]; then
    #   continue
    # fi
    # mkdir -p $output_dir || exit 1;


    # jobs differ because of the limited number of utterances and
    # speakers for dihard - there are just two speakers, so it refuses to split
    # into more than 2
    num_utt=$(wc -l DIHARD/dihard_2019_$name/utt2spk | cut -d " " -f 1)
    #nj=$(($num_utt < 40 ? 2:40))
    nj=2

#	if [[ "$name" =~ .*_dihard_.* ]];then
	    be_dir_i=$be_dihard_dir
	    score_dir_i=$score_dihard_dir
	    trained_dir=jsalt19_spkdiar_ami_train
#	else
#	    echo "$name not found"
#	    exit 1

#	fi

    output_rttm_dir=${score_dir_i}_VB_4spk/$name/plda_scores_tbest
    mkdir -p $output_rttm_dir || exit 1;
    #init_rttm_file=DIHARD-data-to-compute/${name}/rttm_all # copied from /export/c01/draj/kaldi_chime6_jhu/egs/chime6/s5_track2/exp/{dev,eva}l_beamformit_dereverb_stats_max_seg_diarization/rttm data-to-compute-mfccs/{dev,eval}_beamformit_dereverb_stats_seg/rttm
    init_rttm_file=exp/diarization/2a.1.voxceleb_div2/lda120_plda_voxceleb_${name}_OVLassign_ovl/vad.rttm # copied from /export/c01/draj/kaldi_chime6_jhu/egs/chime6/s5_track2/exp/{dev,eva}l_beamformit_dereverb_stats_max_seg_diarization/rttm data-to-compute-mfccs/{dev,eval}_beamformit_dereverb_stats_seg/rttm
    echo initial file $init_rttm_file
    echo data dir DIHARD-data-to-compute-mfccs/$name

    # VB resegmentation. In this script, I use the x-vector result to
    # initialize the VB system. You can also use i-vector result or random
    # initize the VB system. The following script uses kaldi_io.
    # You could use `sh ../../../tools/extras/install_kaldi_io.sh` to install it
    # Usage: diarization/VB_resegmentation.sh <data_dir> <init_rttm_filename> <output_dir> <dubm_model> <ie_model>
    # FOR THIS ONE WE ADDED 4 SPEAKERS AS IT IS FOR CHIME6!!!
    VB/diarization/VB_resegmentation.sh --nj $nj --cmd "$train_cmd --mem 10G" \
      --max-iters $max_iters --initialize 1 \
      DIHARD/dihard_2019_$name $init_rttm_file $output_rttm_dir \
      $VB_models_dir/$trained_dir/diag_ubm_$num_components/final.dubm \
      $VB_models_dir/$trained_dir/extractor_diag_c${num_components}_i${ivector_dim}/final.ie || exit 1;

      #--max-iters $max_iters --initialize 1  --max-speakers 4\ # from

  done
fi

#wait


#exit

# # retrieves all which don't already have VB performed
# dsets_path=exp/diarization/2a.1.voxceleb_div2/lda120_plda_voxceleb
# vb_dsets=`find $dsets_path  -maxdepth 1 -name "jsalt19_spkdiar*" \
#   | xargs -l basename \
#   | sort \
#   | grep "$VB_suff" \
#   `



if [ $stage -le 2 ]; then

  for name in $dsets_test
  do
    echo $name

    if [[ "$name" =~ "dev_beamformit_dereverb_stats_seg_paola" ]];then
      dev_eval=dev
    elif [[ "$name" =~ "eval_beamformit_dereverb_stats_seg_paola" ]];then
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
    $train_cmd exp/diarization/2a.1.voxceleb_div2/lda120_plda_voxceleb_dihard_VB/${name}/pyannote.log \
        local/pyannote_score_diar_chime6.sh $name $dev_eval exp/diarization/2a.1.voxceleb_div2/lda120_plda_voxceleb_dihard_VB/${name}

#    ln -frs $score_dir/${name} $score_dir/${name}/plda_scores_tbest

  done

fi





