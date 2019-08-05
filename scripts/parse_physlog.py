#!/opt/sct/python/envs/venv_sct/bin/python
#
# Load a Philips scan physlog file, trim to the exact scan time, and split into separate 
# cardiac and respiratory signals. Save to AFNI .1D format. 

import sys
import pandas

if len(sys.argv) is not 3:
    print('Usage:')
    print(sys.argv[0] + ' physlog_file scandur_sec')
    exit()

physlog_file = sys.argv[1]
scandur_sec = sys.argv[2]
print('Physlog file: ' + physlog_file)
print('Assumed scan duration in sec: ' + scandur_sec)

