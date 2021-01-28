"""
=======================
Display fMRI Activation
=======================

The most straightforward way to plot activations is when you already have
a map of them defined on the Freesurfer surface. This map can be stored in any
file format that Nibabel can understand.

"""
import os
from surfer import Brain
from mayavi import mlab
import numpy as np
from surfer import io
from IPython import embed

print(__doc__)

figures_dir = "./freesurfer_figures/parcels_correlations_colorbar/"
data_dir="./freesurfer_data/parcels_correlations/"


if not os.path.exists(figures_dir):
        os.mkdir(figures_dir)
        print("Directory " , figures_dir ,  " Created ")

show_colorbar = True


overlays_list = ["r_Face", "r_Body", "r_Room", "sig_Face", "sig_Body", "sig_Room"]

# for each overlay define the min and max values to be presented. values must be positives.
# -1 means that the min and val values of the overlay real data will be taken.
min_list = [ -0.55, -0.55, -0.55, 0.1,0.1,0.1]
max_list = [0.55, 0.55,0.55,1,1,1]
center_list = [0,0,0,0,0,0]
min_th_list = [-100,-100,-100,0.3,0.3, 0.3]


hemi_list = [ "rh"]
ventral_distance = 550
zoom_distance = 250
#show_colorbar = False


ventral_roll_val = [270]



if not os.path.exists(figures_dir):
    os.mkdir(figures_dir)
    print("Directory " , figures_dir ,  " Created ")

for hemi_itr in range(len(hemi_list)):

    curr_hemi = hemi_list[hemi_itr]

    brain = Brain("fsaverage", curr_hemi, surf="inflated", background="white")

    for overlay_itr in range(len(overlays_list)):

        curr_overlay = overlays_list[overlay_itr]
        min_val = min_list[overlay_itr]
        max_val = max_list[overlay_itr]
        center_val = center_list[overlay_itr]
        min_th = min_th_list[overlay_itr]
        overlay_file = os.path.join(data_dir, "%s_%s.nii.gz" % (curr_overlay, curr_hemi))
        sig = io.read_scalar_data(overlay_file)

        sig[sig < min_list[overlay_itr]] = -1000

 
        brain.add_data(sig, min=min_val, max=max_val, thresh=min_val, colormap="jet",
                        smoothing_steps="20", colorbar=show_colorbar, remove_existing=True) 


        brain.show_view("lateral")

        mlab.view(-30,90)
        mlab.savefig(os.path.join(figures_dir, "%s_m30_p90_%s.png" % (curr_overlay,curr_hemi)))
        

        brain.show_view("ventral")
        mlab.view(distance=ventral_distance, roll=ventral_roll_val[hemi_itr])
        mlab.savefig(os.path.join(figures_dir, "%s_ventral_%s.png" % (curr_overlay, curr_hemi)))

        brain.show_view("medial")
        mlab.savefig(os.path.join(figures_dir, "%s_medial_%s.png" % (curr_overlay, curr_hemi)))


