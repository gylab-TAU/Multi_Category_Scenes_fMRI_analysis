"""
Display ROI Labels
==================

Using PySurfer you can plot Freesurfer cortical labels on the surface
with a large amount of control over the visual representation.

"""

import os, glob
from subprocess import call

data_dir="./freesurfer_data/parcels_correlations/"
reg_file = "/Applications/freesurfer/average/mni152.register.dat"
cwd = os.getcwd()


hemi_list = ["lh", "rh"]


os.chdir(data_dir)
       
for files in glob.glob("*.nii"):
    filename = files[:-4]
    for curr_hemi in hemi_list:
        call(["mri_vol2surf", "--src", files, "--out", filename+"_"+curr_hemi+".nii.gz", "--srcreg", reg_file, "--hemi", curr_hemi])

os.chdir(cwd)
