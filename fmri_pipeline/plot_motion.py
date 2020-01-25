#!/opt/sct/python/envs/venv_sct/bin/python

import pandas
import matplotlib.pyplot as pyplot

mot = pandas.read_csv('fmri_moco_params.tsv',sep='\t')
vat = pandas.read_csv('volume_acquisition_time.txt',header=None)

mot.plot(title='fMRI movement avg over slices')
pyplot.xlabel('Volume (Computed vol acq time is %0.4f sec)' % vat[0][0])
pyplot.ylabel('mm')
pyplot.savefig('movement.png')
