function [ settings, params ] = load_settings_params_searchlight_exp3_mni(settings, params )
    
%% paths

settings.path_Data = '../data_mat_files_mni';
settings.path_Results = '../results';


%%
settings.method = 'Euclidean'; % options: 'SVM' 'Correlationa'

settings.file_header_info = 'SL';

settings.data.data_type = 'PercSigCh'; % PercSigCh, Beta
settings.data.cv = 'ALL_TOGETHER'; % LORO = Leave-One-Run-Out cross validation
settings.data.data_design = 'model_mni';
settings.data.normalize = 0; % if 1 than normalization (zscore of data) is performed


settings.min_voxel_num = 30;
settings.exact_voxel_num = 30;

settings.cond_names = {'Face' 'Body' 'Chair' 'Room' 'All'};
settings.single_cond_names = {'Face' 'Body' 'Chair' 'Room'}; 
settings.combined_cond_name = 'All'; % combined cond


%% masks 
% if there are no masks to apply for the data, set an empty value for the masks:
% settings.masks = [];
settings.masks(1).type = 'mask_values';
settings.masks(1).header = 'Brain_activation_mask_loc_mni';

settings.masks(2).type = 'mask_values';
settings.masks(2).header = 'Brain_activation_mask_model_mni';


%% rois overlaps and exclusions

settings.t_vals.cont_t_vals = { 'Cont_loc_mni_Faces>Objects'
                                'Cont_loc_mni_Bodies>Objects'
                                'Cont_loc_mni_Objects>Scrambled'
                                'Cont_loc_mni_Scenes>Objects'
                                'Cont_loc_mni_Faces>all'
                                'Cont_loc_mni_Bodies>all'
                                'Cont_loc_mni_Objects>all'
                                'Cont_loc_mni_Scenes>all'
                                'Cont_loc_mni_Faces_Bodies>Objects'
                                'Cont_loc_mni_Faces>other_cat'
                                'Cont_loc_mni_Bodies>other_cat'
                                'Cont_loc_mni_Objects>other_cat'
                                'Cont_loc_mni_Scenes>other_cat'
                                'Cont_loc_mni_Face>Body'
                                'Cont_loc_mni_Objects>Faces_Bodies'
                                }; 

settings.t_vals.names = {'Face_Object'
                         'Body_Object'
                         'Object_Scrambled'
                         'Scene_Object'
                         'Face_all'
                         'Body_all'
                         'Object_all'
                         'Scene_all'
                         'FaceBody_Object'
                         'Face_otherCat'
                         'Body_otherCat'
                         'Object_otherCat'
                         'Scene_otherCat'
                         'Face_Body'
                         'Object_FaceBody'}; 
                             

%%

settings.dist_contrasts_names = {'Cont_loc_mni_Faces>Objects'
                                'Cont_loc_mni_Bodies>Objects'
                                'Cont_loc_mni_Scenes>Objects'
                                'Cont_loc_mni_Objects>Scrambled'};
                           
settings.dist_contrast_th = 3.734836; %  p<0.0001

%% fixed params

params.seed = 1; % the seed for the randomize

