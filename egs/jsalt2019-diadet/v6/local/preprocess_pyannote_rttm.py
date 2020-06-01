#!/usr/bin/env python
# encoding: utf-8

# The MIT License (MIT)

# Copyright (c) 2019 JSALT

# AUTHORS
# Latané Bullock

from optparse import OptionParser

def normalize_spk_labels(rttm_fi, rttm_fo):
    fr = open(rttm_fi, 'r')
    fw = open(rttm_fo, 'w')
    lines = fr.readlines()
    for line_i, line in enumerate(lines):
        spk_label = line.split()[7]
        if spk_label.isalpha():
            fw.write(line)
        else:
            nearest_label_i = line_i + 1
            while not lines[nearest_label_i].split()[7].isalpha():
                nearest_label_i += 1
            new_label = lines[nearest_label_i].split()[7]
            new_line = line.split()
            new_line[7] = new_label
            print(new_line)
            fw.write('\t'.join(new_line))
            fw.write('\n')




def main():
    usage = "%prog [options] rttmIn rttmOut"
    desc = "Convert pyannote format rttm (with some labels A-Z, somet numbers) \
            to an rttm with all A-Z labels. "
    version = "%prog 0.1"
    parser = OptionParser(usage=usage, description=desc, version=version)
    (opt, args) = parser.parse_args()

    normalize_spk_labels(args[0], args[1])
    return 0



if __name__=="__main__":
    main()


