#!/bin/bash
# Copyright
#
#
# Apache 2.0.
#
#
#
# JSALT 2019, Latané Bulloc
# JHU 2020, Paola Garcia



. ./cmd.sh
. ./path.sh
set -e

stage=1
config_file=default_config.sh

. parse_options.sh || exit 1;
. $config_file


ovl_out_dir=exp/overlap_models/test_raw_DIHARD-MAY27
vb_suff=VB
ovl_suff=OVLassign

score_dir=exp/diarization/$nnet_name/$be_diar_name # exp/diarization/2a.1.voxceleb_div2/lda120_plda_voxceleb_ami_VB/
echo $score_dir
# Retrieves all dsets which we want to perform resegmentation on
# We first get all dsets which would have a corresponding VB reseg
# Can perform filtering with inverse grep if needed

dsets_path=$score_dir
# dsets=`find $dsets_path  -maxdepth 1 -name "*paola" \
#  | xargs -l basename \
#  | sort \
#  | grep -v VB \
#  | grep -v sri \
#	`

#dev datasets
#dsets_spkdiar_dev_evad=(jsalt19_spkdiar_ami_dev_{U01,U06})
#dsets_spkdiar_dev_evad=(dev_beamformit_dereverb_stats_seg_paola)
dsets_spkdiar_dev_evad=(dev)
#dsets_spkdiar_dev_evad=(jsalt19_spkdiar_ami{,_enhanced}_dev_{U01,U06})

#eval datasets
#dsets_spkdiar_eval_evad=(eval_beamformit_dereverb_stats_seg_paola)
dsets_spkdiar_eval_evad=(eval)
#dsets_spkdiar_eval_evad=($(echo ${dsets_spkdiar_dev_evad[@]} | sed 's@_dev@_eval@g'))

dsets_dev=(${dsets_spkdiar_dev_evad[@]})
dsets_eval=(${dsets_spkdiar_eval_evad[@]})

# consists of all DIAR datasets
dsets="${dsets_dev[@]} ${dsets_eval[@]}"


if [ $stage -le 1 ]; then

	for dset in $dsets; do

#    	if [[ "$dset" =~ .*ami.* ]];then
      		corp=dihard
#	else echo "dset -- $dset -- unable to be parsed"; exit 1;
#	fi

echo THIS IS DSET $dset
	if [[ "$dset" =~ dev* ]];then
      		part=dev
    	elif [[ "$dset" =~ eval* ]];then
      		part=eval
		else echo "dset -- $dset -- unable to be parsed"; exit 1;
		fi
echo WHAT IS THE PART $part
		# TESTING(FIXME) need to add the rest of the mics
                # probably for later to have a better idea of the mics
    	if [[ "$dset" =~ ${part}_CH1 ]];then
                echo IM HERE AT U01
      		mic="CH1"
    	elif [[ "$dset" =~ ${part}_CH2  ]];then
      		mic='CH2'
    	elif [[ "$dset" =~ ${part}_CH3  ]];then
      		mic='CH3'
    	elif [[ "$dset" =~ ${part}_CH4  ]];then
      		mic='CH4'
    	elif [[ "$dset" =~ ${part}_CH5  ]];then
      		mic='CH5'
    	elif [[ "$dset" =~ ${part}_CH6  ]];then
      		mic='CH6'
    	elif [[ "$dset" =~ ${part}_CH7  ]];then
      		mic='CH7'
    	elif [[ "$dset" =~ ${part}_CH8  ]];then
      		mic='CH8'
		else mic='';
		fi

echo THIS IS OUR MIC $mic

		#dset_vb=${corp}_${vb_suff}_4spk/${dset}
		#if [ ! -d ${dsets_path}_${dset_vb} ]; then
	#		echo ${dsets_path}_${dset_vb}
#		echo Paola
#			continue
#        	fi

		# This is the dir that the overlap assignment will use
		output_dir=${dsets_path}_${dset}_${ovl_suff}_ovl
		#output_dir=${dsets_path}_${dset_vb}_${ovl_suff}_4spk #the BEST system
		echo $output_dir
		mkdir -p $output_dir

		#TESTING(FXIME)-clear dir before starting
		rm -rf $output_dir/tmp
		rm -rf $output_dir/*.log
		rm -rf $output_dir/result.*
		rm -rf $output_dir/rttm

		# get rttm from BEFORE VB reseg
               # cp AMI-data-to-compute/$dset/rttm_all $output_dir/vad.rttm  #BEST FOR ARRAYS!
                cat /export/b04/leibny/VBx-May2020/VBx/out_dir_${part}/*.rttm | awk '{print $1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"_"$2" "$9" "$10}' > $output_dir/vad.rttm
		#cp exp/diarization/2a.1.voxceleb_div2/lda120_plda_voxceleb_ami_VB_4spk/${part}_beamformit_dereverb_stats_seg/plda_scores_tbest/rttm $output_dir/vad.rttm
		#cp $dsets_path"_"$dset/plda_scores_tbest/rttm $output_dir/rttm_in #This one comes from Desh
		#overlap_rttm=${ovl_out_dir}/diar_overlap_${part}_$corp${mic}.rttm  # THIS ONE is perfectly correct since I am computing them by hand.
		overlap_rttm=${ovl_out_dir}/diar_overlap_${dset}_${corp}.rttm  # THIS ONE is perfectly correct since I am computing them by hand.
		cat ${ovl_out_dir}/overlap_${part}_${corp}_${part}.txt \
                | awk '{ print "SPEAKER",$1,"1",$2,($3-$2),"<NA> <NA>","overlap","<NA>" }' \
                       > ${ovl_out_dir}/diar_overlap_${dset}_${corp}.rttm

                cp $overlap_rttm  $output_dir/overlap.rttm

		# The data dir should contain a utt2spk and utt2num_frames used in VB
		data_dir=DIHARD/dihard_2019_${dset}
  		echo $output_dir
		cp $data_dir/utt2spk $output_dir/
		cp $data_dir/utt2num_frames $output_dir/

		# We need the q matrix for each utterance from VB resegmentation
                ## WE NEED TO MAKE SURE THAT ALL THE MARTICES MATCH
		mkdir -p $output_dir/q_mats
		mkdir -p $output_dir/tmp
		#echo  $dsets_path"_"$dset_vb/tmp/*.npy
		echo  exp/diarization/2a.1.voxceleb_div2/lda120_plda_voxceleb_ami_VB/${part}_beamformit_dereverb_stats_seg/plda_scores_tbest/tmp/*.npy
		#cp /export/b04/leibny/VBx-May2020/VBx/out_dir_${part}_q/*.npy $output_dir/q_mats
		cp  exp/diarization/2a.1.voxceleb_div2/_VB_4spk/${part}/plda_scores_tbest/tmp/*q_out.npy   $output_dir/q_mats
		#cp exp/diarization/2a.1.voxceleb_div2/lda120_plda_voxceleb_ami_VB_4spk/${part}_beamformit_dereverb_stats_seg/plda_scores_tbest/tmp/*.npy $output_dir/q_mats


		# TESTING(FIXME) - this env activation should be placed more strategiclaly
		#source activate pyannote

		# Usage: diar_ovl_assignment.py [-h] <overlap_dir>
		# At this point, the output dir should contain the q matrix from VB reseg
		# an overlap rttm, and a vad rttm
		/home/janto/usr/local/anaconda3.5/envs/pyannote/bin/python local/diar_ovl_assignment.py $output_dir
		cat $output_dir/tmp/*.rttm > $output_dir/rttm

	done
fi


exit

# retrieves all which don't already have VB performed
# PROBABLY WE NEED THIS INFO
#ovl_dsets=`find $score_dir  -maxdepth 1 -name "jsalt19_spkdiar*" \
#  | xargs -l basename \
#  | sort \
#  | grep "$ovl_suff" \
#  `

if [ $stage -le 2 ]; then

  for name in $ovl_dsets
  do

    if [[ "$name" =~ .dev.* ]];then
      dev_eval=dev
    elif [[ "$name" =~ .eval.* ]];then
      dev_eval=eval
    else
      echo "Dataset dev/eval not found"
      exit 1
    fi

    echo $name

    # TESTING(FIXME)
    # we can skip those rttms which have already been evaluated
    if [ -s $score_dir/$name/result.pyannote-der ];then
      continue
    fi



    # Compute the DER after VB resegmentation wtih
    # PYANNOTE
    # "Usage: $0 <dataset> <dev/eval> <score-dir>"
    echo "Starting Pyannote rttm evaluation for $name ... "
    $train_cmd $score_dir/${name}/pyannote.log \
        local/pyannote_score_diar.sh $name $dev_eval $score_dir/${name}

    ln -frs $score_dir/${name} $score_dir/${name}/plda_scores_tbest

  done

fi


