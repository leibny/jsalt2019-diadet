#!/bin/bash
# Copyright
#            
#
# Apache 2.0.
#
#
#
# JSALT 2019, Latané Bullock


. ./cmd.sh
. ./path.sh


source activate pyannote
$pyannote_cmd exp/overlap/pyannote.log \
	python3 local/generate_overlap.py AMI.SpeakerDiarization.MixHeadset exp/overlap/oracle
	

# if [ $stage -le 1 ]; then
# 	for PROTOCOL in AMI.SpeakerDiarization.MixHeadset
# 	do
		
# 	source activate pyannote
# 	$pyannote_cmd exp/overlap/pyannote.log \
# 		python3 local/generate_overlap.py $PROTOCOL exp/overlap/oracle
# 		# python3 local/generate_overlap.py AMI.SpeakerDiarization.MixHeadset exp/overlap/oracle
	
# 	done

# fi



