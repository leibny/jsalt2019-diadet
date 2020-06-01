#!/usr/bin/env python3
#
#
#
# JSALT 2020 Paola

import numpy as np
import argparse


def get_utt_list(utt2spk_filename):
    with open(utt2spk_filename, 'r') as fh:
        content = fh.readlines()
    utt_list = [line.split()[0] for line in content]
    print("{} utterances in total".format(len(utt_list)))
    return utt_list

def get_utt_list_spk(utt2spk_filename, spk):
    list_spk = []
    with open(utt2spk_filename) as fh:
       	content = fh.readlines()
    for line in content:
       	line = line.strip('\n')
       	line_split = line.split()[0]
        #print(spk)
        #print(line_split)
       	if  spk in line_split:
           list_spk.append(line_split)
        #print(list_spk)
    return list_spk

def get_spk(spk_filename):
    with open(spk_filename) as fh:
        content = fh.readlines()
        speaker=[]
    for line in content:
        line = line.strip('\n')
        speaker.append(line)
        #num_spk += 1
    return speaker


# prepare utt2num_frames dictionary
def get_utt2num_frames(utt2num_frames_filename):
    utt2num_frames = {}
    with open(utt2num_frames_filename, 'r') as fh:
        content = fh.readlines()
    for line in content:
        line = line.strip('\n')
        line_split = line.split()
        utt2num_frames[line_split[0]] = int(line_split[1])
    return utt2num_frames

def rttm2one_hot(uttname, utt2num_frames, full_rttm_filename):
    num_frames = utt2num_frames[uttname]

    # We use 0 to denote silence frames and 1 to denote overlapping frames.
    ref = np.zeros(num_frames)
    speaker_dict = {}
    num_spk = 0

    with open(full_rttm_filename, 'r') as fh:
        content = fh.readlines()
    for line in content:
        line = line.strip('\n')
        line_split = line.split()
        uttname_line = line_split[1]
        if uttname != uttname_line:
            continue
        start_time, duration = int(float(line_split[3]) * 100), int(float(line_split[4]) * 100)
        end_time = start_time + duration
        spkname = line_split[7]
        if spkname not in speaker_dict.keys():
            spk_idx = num_spk + 2
            speaker_dict[spkname] = spk_idx
            num_spk += 1

        for i in range(start_time, end_time):
            if i < 0:
                raise ValueError("Time index less than 0")
            elif i >= num_frames:
                print("Time index exceeds number of frames")
                break
            else:
                if ref[i] == 0:
                    ref[i] = speaker_dict[spkname]
                else:
                    ref[i] = 1 # The overlapping speech is marked as 1.
    return ref.astype(int)

# create output rttm file
def create_rttm_output(uttname, pri_sec, predicted_label, output_dir, channel):
    num_frames = len(predicted_label)

    start_idx = 0
    seg_list = []

    last_label = predicted_label[0]
    for i in range(num_frames):
        if predicted_label[i] == last_label: # The speaker label remains the same.
            continue
        else: # The speaker label is different.
            if last_label != 0: # Ignore the silence.
                seg_list.append([start_idx, i, last_label])
            start_idx = i
            last_label = predicted_label[i]
    if last_label != 0:
        seg_list.append([start_idx, num_frames, last_label])

    with open("{}/tmp/{}_predict_{}.rttm".format(output_dir, uttname, pri_sec), 'w') as fh:
        for i in range(len(seg_list)):
            start_frame = (seg_list[i])[0]
            end_frame = (seg_list[i])[1]
            label = (seg_list[i])[2]
            duration = end_frame - start_frame
            fh.write("SPEAKER {} {} {:.2f} {:.2f} <NA> <NA> {} <NA> <NA>\n".format(uttname, channel, start_frame / 100.0, duration / 100.0, label))
    return 0



def main():
    parser = argparse.ArgumentParser(description='Adding and getting the max and the avg of the matrices')
    parser.add_argument('ovl_dir', type=str, help='Path to the tmp directory where we hve the q matrices')

    args = parser.parse_args()
    print(args)
    speakers=get_spk("{}/spk_file".format(args.ovl_dir))
    print(speakers)
    for spk_mic in speakers:
        utt_list = get_utt_list_spk("{}/utt2spk".format(args.ovl_dir),spk_mic)
        #    utt2num_frames = get_utt2num_frames("{}/utt2num_frames".format(args.ovl_dir))
        count=0
        for utt in utt_list:
            print(utt)
            try:
                if count == 0:
                    q_out= np.load('{}/q_mats/{}_q_out.npy'.format(args.ovl_dir, utt))
                    count += 1
                else:
       	        #n_frames = utt2num_frames[utt]
                # Remember: q is only for voiced frames
                    q_init = np.load('{}/q_mats/{}_q_out.npy'.format(args.ovl_dir, utt))
                    q_init.shape
                    #q_out  = np.maximum(q_init,q_out)
                    q_out  = np.add(q_init,q_out)/2
                    q_out.shape
            except:
                pass
        try:
            with open("{}/q_mats/{}_qmax.npy".format(args.ovl_dir, spk_mic), 'wb') as fout:
                np.save(fout, q_out)
            with open("{}/q_mats/{}_q_out.npy".format(args.ovl_dir, utt), 'wb') as fout:
                np.save(fout, q_out)
        except:
               pass



    return 0



if __name__ == "__main__":
    main()
