#!/opt/sct/python/envs/venv_sct/bin/python

import pandas
import matplotlib.pyplot as pyplot

mot = pandas.read_csv('fmri_moco_params.tsv',sep='\t')
mot.plot(title='fMRI movement avg over slices')
pyplot.xlabel('Volume')
pyplot.ylabel('mm')
pyplot.savefig('movement.png')
