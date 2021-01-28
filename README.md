# Multi_Category_Scenes_fMRI_analysis


This code was used to analyze the data for the paper (please cite if using this code): Kliger, L., & Yovel, G. (submitted). The representation of multi-category scenes varies as a function of the distance between category-selective visual brain areas. 

The code is divided to five parts (by order of running):

1. fMRI analysis: including preprocessing and standard GLM analysis (Matlab).
2. arrange_data_after_preprocessing: loading the fMRI GLM .nii results files, including betas, percent signal change and contrast t-maps into a combined .mat file (Matlab).
3. regression_analysis: Perform searchlight analysis and predicting the response to multiple objects based on the response to single objects (Matlab).
4. statistical_tests_and_figures: Perform statistics on the results and plot figures (R).
5. plot_freesurfer_maps: Convert .nii maps to surfaces and plot on an inflated brain (Python)

The code uses spm12 (https://www.fil.ion.ucl.ac.uk/spm/doc/ ), marsbar (http://marsbar.sourceforge.net/), HarvardOxford atlas (from FSL, https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/), Freesurfer (https://surfer.nmr.mgh.harvard.edu) and pysurfer (https://pysurfer.github.io).


