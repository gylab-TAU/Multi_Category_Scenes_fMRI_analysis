"""
Display ROI Labels
==================

Using PySurfer you can plot Freesurfer cortical labels on the surface
with a large amount of control over the visual representation.

"""
import os
import numpy as np
from surfer import io
from surfer import Brain
from mayavi import mlab

print(__doc__)

figures_dir = "./freesurfer_figures/selectivity_maps/"
data_dir = "./freesurfer_data/selectivity_labels"



if not os.path.exists(figures_dir):
        os.mkdir(figures_dir)
        print("Directory " , figures_dir ,  " Created ")

show_colorbar = True

overlays_list = ["face_dist", "body_dist", "place_dist", "face_prox_body", "body_prox_place"]

blue_color="#005b9a"
red_color="#e7402f"
green_color="#209f56"
purple_color="#b04ed8"
babyblue_color ="#91caee"



overlays_colors = [ red_color, blue_color ,green_color,purple_color, babyblue_color]                  

subj_list = ["subj_01", "subj_02", "subj_03", "subj_04", "subj_05", "subj_06", "subj_07", "subj_08", "subj_09", "subj_10", "subj_11", "subj_12", "subj_13", "subj_14", "subj_15"]


hemi_list = ["rh"]

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
        
    for subj_itr in range(len(subj_list)):

        curr_subj = subj_list[subj_itr]
    
    

        for overlay_itr in range(len(overlays_list)):

            curr_overlay = overlays_list[overlay_itr]

            overlay_file = os.path.join(data_dir, "%s_%s_%s.label" % (curr_overlay, curr_subj, curr_hemi))
            
            if os.path.exists(overlay_file):

                brain.add_label(overlay_file, color=overlays_colors[overlay_itr])
            

        brain.show_view("lateral")

        mlab.view(-30,90)
        mlab.savefig(os.path.join(figures_dir, "%s_m30_p90_%s.png" % (curr_subj, curr_hemi)))
                
        brain.show_view("ventral")
        mlab.view(distance=ventral_distance, roll=ventral_roll_val[hemi_itr])
        mlab.savefig(os.path.join(figures_dir, "%s_ventral_%s.png" % (curr_subj,curr_hemi)))

        brain.remove_labels()
        
