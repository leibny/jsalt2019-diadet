#!/usr/bin/env python
# encoding: utf-8
#
# 
# Latané Bullock - JSALT 2019

from typing import TextIO
from typing import Union
from pyannote.core import Timeline
from pyannote.core import Annotation
from optparse import OptionParser
from pyannote.database import get_protocol
from pyannote.audio.features import Precomputed
from pyannote.audio.signal import Binarize
import sys

print(sys.version)


def write_txt(file: TextIO, output: Union[Timeline, Annotation]):
    """Write pipeline output to "txt" file

    Parameters
    ----------
    file : file object
    output : `pyannote.core.Timeline` or `pyannote.core.Annotation`
        Pipeline output
    """

    if isinstance(output, Timeline):
        for s in output:
            dur = s.end-s.start
            line = 'SPEAKER {} 1 {} {} <NA> <NA> A <NA> <NA>\n'.format(output.uri, s.start, dur)
            # line = f'{output.uri} {s.start:.3f} {s.end:.3f}'
            file.write(line)
    
    else:
        print('Parameter passed in not a pyannote Timeline')
        raise AssertionError
    return



def main():
    usage = "%prog [options] database output_file"
    desc = "Generate oracle overlap rttm and write to file"
    version = "%prog 0.1"
    parser = OptionParser(usage=usage, description=desc, version=version)
    (opt, args) = parser.parse_args()

    if(len(args)!=2):
        parser.error("Two arguments expected")
    database, output_file_path = args
    print(database)

    # get test file of protocol
    protocol = get_protocol(database)




    # fw = open(f"exp/overlap/oracle/{database}.rttm", 'w')
    fw = open(f"exp/overlap/oracle/dev.rttm", 'w')

    # FIXME don't forget to do test too!
    for test_file in protocol.development():
        og_timeline = test_file['annotation'].get_timeline()
        segmented = test_file['annotation'].get_timeline().segmentation()
        overlap_timeline = Timeline(uri=test_file['uri'])
        for segment in segmented:
            if len(og_timeline.overlapping(segment.middle)) >= 2:
                overlap_timeline.add(segment)

        # write the output into text
        print('writing to file')
        write_txt(fw, overlap_timeline)
 
    fw.close()


    # fw = open(f"exp/overlap/oracle/{database}.rttm", 'w')
    fw = open(f"exp/overlap/oracle/test.rttm", 'w')

    # FIXME don't forget to do test too!
    for test_file in protocol.test():
        og_timeline = test_file['annotation'].get_timeline()
        segmented = test_file['annotation'].get_timeline().segmentation()
        overlap_timeline = Timeline(uri=test_file['uri'])
        for segment in segmented:
            if len(og_timeline.overlapping(segment.middle)) >= 2:
                overlap_timeline.add(segment)

        # write the output into text
        write_txt(fw, overlap_timeline)
 
    fw.close()

if __name__=="__main__":
    main()
