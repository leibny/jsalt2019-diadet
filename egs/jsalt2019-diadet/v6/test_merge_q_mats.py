import numpy as np
import os

base = "exp/diarization/overlap_exp_herve_new_oracleASS/jsalt19_spkdiar_ami_eval_Mix-Headset_VB_OVLassign"

for file in os.listdir(f"{base}/q_mats_oracle"):
    print(file)
    q_oracle = np.load(f"{base}/q_mats_oracle/{file}")
    q_VB = np.load(f"{base}/q_mats_VB/{file}")
    print(q_oracle.shape)
    print(q_VB.shape)
    first_spk_inds = np.argmax(q_VB, axis=1)
    
    for i in range(q_oracle.shape[0]):
        q_oracle[i, first_spk_inds[i]] = 111
        
    with open(f"{base}/q_mats/{file}", 'wb') as fout:
        np.save(fout, q_oracle)