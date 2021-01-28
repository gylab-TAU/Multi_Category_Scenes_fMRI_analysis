
PARAMS.exp_path = '../data';
PARAMS.SpmDir = [PARAMS.exp_path filesep 'spm' filesep];
PARAMS.FreesurferDir = '';

PARAMS.path_spm = '/usr/local/spm12/';
PARAMS.path_marsbar = '/usr/local/spm12/marsbar';

PARAMS.unite_rois.orig_rois_dir = ['ResultsLocalizer_mni' filesep 'ROI_Analysis'];
PARAMS.unite_rois.new_rois_dir = ['ResultsLocalizer_mni' filesep 'ROIs_for_prepData'];
                    

% PARAMS for prepData

PARAMS.use_fressurfer = 0;
PARAMS.use_segmentation_files = 0;

PARAMS.design_dirs = {'ResultsLocalizer_mni','ResultsModel_mni'};
PARAMS.header_prefix = {'loc_mni', 'model_mni'};
PARAMS.rois_dir = PARAMS.unite_rois.new_rois_dir;

PARAMS.data_dir = '../data_mat_files_mni/';
PARAMS.roi_anal_prefix_dir_name = 'ROI_';

PARAMS.max_subj_num = 15;
PARAMS.save_csv = false;
PARAMS.save_mat = true;

                   
PARAMS.subjects_list = {
                        'subj_02' % 2
                        'subj_03'  % 3
                        'subj_04'  % 4
                        'subj_05'  % 5
                        'subj_06'  % 6
                        'subj_07'  % 7
                        'subj_08'  % 8
                        'subj_09'  % 9
                        'subj_10' % 10
                        'subj_11' % 11
                        'subj_12' % 12
                        'subj_13' % 13
                        'subj_14' % 14
                        'subj_15' % 15
                        'subj_16' % 16
                        };
                    
                    
PARAMS.anatomy_path = { 
                        '17' %2
                        '15' %3
                        '15' %4
                        '15' %5
                        '15' %6
                        '15' %7   
                        '15' %8 
                        '15' %9 
                        '15' %10 
                        '15' %11 
                        '15' %12 
                        '19' %13 
                        '15' %14 
                        '15' %15 
                        '15' %16 
                        };
 
PARAMS.all_rois = { 'EBA_left_roi'
                    'EBA_right_roi'
                    'FBA_left_roi'
                    'FBA_right_roi'
                    'p_FFA_left_roi'
                    'p_FFA_right_roi'
                    'm_FFA_left_roi'
                    'm_FFA_right_roi'
                    'OFA_left_roi'
                    'OFA_right_roi'
                    'LO_left_roi' 
                    'LO_right_roi'
                    'pFS_left_roi'
                    'pFS_right_roi'
                    'PPA_left_roi'
                    'PPA_right_roi'
                    'TOS_left_roi'
                    'TOS_right_roi'
                    'EVC_roi'
                    'FB_fus_left_roi'
                    'FB_fus_right_roi'
                    'FB_lateral_left_roi'
                    'FB_lateral_right_roi'
                    'medial_obj_left_roi'
                    'medial_obj_right_roi'};
                    

%% Run code

unite_ROIs_for_prepData(PARAMS);

prep_data_wo_atlas(PARAMS);
 



