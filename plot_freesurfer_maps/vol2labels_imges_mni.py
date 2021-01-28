"""
Display ROI Labels
==================

Using PySurfer you can plot Freesurfer cortical labels on the surface
with a large amount of control over the visual representation.

"""

import os, glob
from subprocess import call

data_dir="./freesurfer_data/selectivity_labels"


reg_file = "/Applications/freesurfer/average/mni152.register.dat"
cwd = os.getcwd()

subj_list = ["subj_02", "subj_03", "subj_04", "subj_05", "subj_06", "subj_07", "subj_08", "subj_09", "subj_10", "subj_11", "subj_12", "subj_13", "subj_14", "subj_15", "subj_16"]


hemi_list = ["lh", "rh"]


os.chdir(data_dir)

for files in glob.glob("*.nii"):
        filename = files[:-4]
        for curr_hemi in hemi_list:
            call(["mri_vol2surf", "--src", files, "--out", filename+"_"+curr_hemi+".nii.gz", "--srcreg", reg_file, "--hemi", curr_hemi])
            call(["mri_vol2label", "--i", "./"+filename+"_"+curr_hemi+".nii.gz", "--surf", "fsaverage", curr_hemi, "--id", "1", "--l", "./"+filename+"_"+curr_hemi+".label"])



os.chdir(cwd)
