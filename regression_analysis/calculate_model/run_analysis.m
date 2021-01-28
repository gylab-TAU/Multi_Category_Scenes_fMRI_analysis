clear; clc; close all;


subj = dir ('../data_mat_files_mni/*.mat');


load_settings_file_list = {'./load_settings_params_searchlight_mni.m'
                            };
warning('off','stats:regress:NoConst')

MAX_SUBJ_NUM = 20;


for subj_itr = 1:min(length(subj), MAX_SUBJ_NUM)
    
    for settings_file_itr = 1: length(load_settings_file_list)
        tic
        settings.subj_file = subj(subj_itr).name;
        params = [];
        [data,settings, params] = searchlight_per_subject (settings, params, load_settings_file_list{settings_file_itr}); 
        fprintf('\n');

        toc
    end
end
    