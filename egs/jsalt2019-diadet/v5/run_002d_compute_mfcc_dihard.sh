#!/bin/bash
# Copyright
#                2018   Johns Hopkins University (Author: Jesus Villalba)
#                2017   David Snyder
#                2017   Johns Hopkins University (Author: Daniel Garcia-Romero)
#                2017   Johns Hopkins University (Author: Daniel Povey)
# Apache 2.0.
#

. ./cmd.sh
. ./path.sh
set -e
nodes=fs01 #by default it puts mfcc in /export/fs01/jsalt19
storage_name=$(date +'%m_%d_%H_%M')
mfccdir=`pwd`/mfcc
vaddir=`pwd`/mfcc  # energy VAD
vaddir_gt=`pwd`/vad_gt  # ground truth VAD

stage=1
config_file=default_config.sh

. parse_options.sh || exit 1;
. $config_file

# Make filterbanks and compute the energy-based VAD for each dataset

if [ $stage -le 1 ]; then
    # Prepare to distribute data over multiple machines
    if [[ $(hostname -f) == *.clsp.jhu.edu ]] && [ ! -d $mfccdir/storage ]; then
	dir_name=$USER/hyp-data/dihard3/v4/$storage_name/mfcc/storage
	if [ "$nodes" == "b0" ];then
	    utils/create_split_dir.pl \
			    utils/create_split_dir.pl \
		/export/b{04,05,06,07}/$dir_name $mfccdir/storage
	elif [ "$nodes" == "b1" ];then
	    utils/create_split_dir.pl \
		/export/b{14,15,16,17}/$dir_name $mfccdir/storage
	else
	    utils/create_split_dir.pl \
		/export/fs01/jsalt19/$dir_name $mfccdir/storage
	fi
    fi
fi



#Spk diarization test data
if [ $stage -le 7 ] ;then
    #for name in {dev,eval}_{CH1,CH2,CH3,CH4,CH5,CH6,CH7,CH8}
    for name in {dev,eval}
    do
        echo Paola
	num_utt=$(wc -l DIHARD/dihard_2019_$name/utt2spk | cut -d " " -f 1)
	nj=$(($num_utt < 40 ? 1:40))
	steps/make_mfcc.sh --write-utt2num-frames true --mfcc-config conf/mfcc_16k.conf --nj $nj --cmd "$train_cmd" \
			   DIHARD/dihard_2019_${name} exp/make_mfcc $mfccdir
	utils/fix_data_dir.sh DIHARD/dihard_2019_$name

    done
fi


