params.seed = 1;

results_dir = './results';

parcellation_file = './Schaefer2018_400Parcels_17Networks_order_FSLMNI152_2mm.nii'; 
% The parcels file is available as part of the data of: Schaefer, A. et al. Local-Global Parcellation of the Human Cerebral Cortex from Intrinsic Functional Connectivity MRI. Cereb. Cortex 28, 30953114 (2018).

images_dir = 'parcellation_results';
freesurfer_data_dir = '/freesurfer_data/parcels_correlations';


rng('default')
rng(params.seed);

%% load data

files = dir ([results_dir filesep '*.mat']);
subj_num = length(files);


% load([results_dir filesep files(1).name]);


V_parcellation = spm_vol(parcellation_file);
parcellation_idx = spm_read_vols(V_parcellation);
parcellation_idx_vec = parcellation_idx(:);
parcels_num = max(parcellation_idx(:));

curr_vol = V_parcellation; 
voxels_num = length(parcellation_idx_vec);

category_name = {'Face', 'Body', 'Room'};

category_num = length(category_name);

r_single_subj = NaN(parcels_num, category_num, subj_num);


neighbors_mask = zeros(curr_vol.dim);
neighbors_mask(1:2:end,1:2:end,1:2:end)=1;
neighbors_mask = reshape(neighbors_mask, voxels_num,[]);



for subj_itr = 1:subj_num
   
    load([results_dir filesep files(subj_itr).name]);

    curr_conj_mask = results.conj_mask;
    
    model_betas = results.betas(:,[2,3,5]);
    selectivity_t = results.center_loc_t_vals(:,[1,2,4]);
    
    for parcel_itr = 1:parcels_num
       
        curr_parcel_mask = parcellation_idx_vec == parcel_itr;
        
        curr_valid_parcel_mask = curr_parcel_mask & curr_conj_mask & neighbors_mask;
        
        if sum(curr_valid_parcel_mask > 0)
        
            for cat_itr = 1:category_num

                r = corr(model_betas(curr_valid_parcel_mask, cat_itr),selectivity_t(curr_valid_parcel_mask, cat_itr));

                r_single_subj(parcel_itr, cat_itr, subj_itr) = r;

            end
        end
        
    end
    
end

valid_corr_mask = abs(r_single_subj)<0.999;

z_single_subj = atanh(r_single_subj);

z_single_subj(~valid_corr_mask) = nan;

r_group_mean = tanh(nanmean (z_single_subj,3));



% 
% z_group_mean = mean(z_single_subj, 3, 'omitnan');
% r_group_mean = tanh(z_group_mean);

p_ttest = zeros(parcels_num, category_num);
sig_ttest = zeros(parcels_num, category_num);

for parcel_itr = 1:parcels_num
    
    for cat_itr = 1:category_num

        [sig_ttest(parcel_itr, cat_itr), p_ttest(parcel_itr, cat_itr)] = ttest(z_single_subj(parcel_itr, cat_itr, valid_corr_mask(parcel_itr,cat_itr,:)),0,'Alpha',0.05/(parcels_num/2), 'Tail','right');    
    
    end
end



brain_vec_cor_sig = zeros(voxels_num, category_num) - 1000;
brain_vec_cor_r = zeros(voxels_num, category_num) - 1000;


for parcel_itr = 1:parcels_num
   
    for cat_itr = 1:category_num
        brain_vec_cor_r(parcellation_idx == parcel_itr,cat_itr) = r_group_mean(parcel_itr,cat_itr);

        brain_vec_cor_sig (parcellation_idx == parcel_itr,cat_itr) = sig_ttest(parcel_itr,cat_itr);
    end
end

curr_vol = V_parcellation;


for cat_itr = 1:category_num

    curr_vol.fname = [freesurfer_data_dir filesep 'r_' category_name{cat_itr} '.nii'];
    spm_write_vol(curr_vol, reshape(brain_vec_cor_r(:,cat_itr), curr_vol.dim)); 

    curr_vol.fname = [freesurfer_data_dir filesep 'sig_' category_name{cat_itr} '.nii'];
    spm_write_vol(curr_vol, reshape(brain_vec_cor_sig(:,cat_itr), curr_vol.dim)); 


end



% roi_num = length(results.roi_masks_headers);
% 
% roi_names = {'EBA' 'EBA' 'FBA' 'FBA' 'FFA' 'FFA' 'OFA' 'OFA' ...
%            'LO' 'LO' 'pFS' 'pFS' 'PPA' 'PPA' 'TOS' 'TOS',...
%            'FB_fus','FB_fus', 'FB_lateral','FB_lateral', 'medial_obj', 'medial_obj'};
% 
% rois_hemis = {'Left','Right','Left','Right','Left','Right','Left','Right',...
%                 'Left','Right','Left','Right','Left','Right','Left','Right',...
%                 'Left','Right','Left','Right','Left','Right'};

% 
% subj_num = length(files);
% 
% table_headers = {'subj','roi','voxel_ind','b_intercept','b_Face', 'b_Body', 'b_Chair', 'b_Room', 'sum' 'Rsq_FB',...
%                 't_Face_Object', 't_Body_Object','t_Object_Scrambed',...
%                 't_Scene_Object', 't_Face_all', 't_Body_all', 't_Object_all', 't_Scene_all',...
%                 't_FaceBody_object', 't_Face_otherCat', 't_Body_otherCat', 't_Object_otherCat', 't_Scene_otherCat', 't_Face_Body', 't_Object_FaceBody',...
%                 'model_PSC_Face', 'model_PSC_Body', 'model_PSC_Chair', 'model_PSC_Room','model_PSC_All', ...
%                 'X','Y','Z','num_of_voxels', ...
%                 'min_dist_t_Face_Object','min_dist_t_Body_Object','min_dist_t_Scene_Object','min_dist_t_Object_Scrambled'};
%         
% volume_size = results.curr_vol.dim;
% voxels_num = length(results.conj_mask);
% 
% voxel_inds = (1:voxels_num)';
% 
% neighbors_mask = zeros(volume_size);
% neighbors_mask(1:2:end,1:2:end,1:2:end)=1;
% neighbors_mask = reshape(neighbors_mask, voxels_num,[]);
% 
% 
% for region_itr = 1:length(region_masks_headers)
%     
%     data_mat = [];
%     
%     for subj_itr = 1:subj_num
%         load([results_dir filesep files(subj_itr).name]);
%         
%         curr_region_mask = region_masks(results.conj_mask  ,region_itr);
%         curr_neighbors_mask = neighbors_mask(results.conj_mask);
%         subj_region_voxel_inds = voxel_inds(results.conj_mask);
%         
%         curr_region_mask_exclude_neighbors_mask = curr_region_mask & curr_neighbors_mask;
%         
%         % category selective voxels p<0.0001
%         face_selective_mask = results.data_mat(:,8) > 3.734836;
%         body_selective_mask = results.data_mat(:,9) > 3.734836;
%         place_selective_mask = results.data_mat(:,11) > 3.734836;
%         
%         % distant voxels by categories
%         distant_th = 0;
%         distant_face_mask = results.data_mat(:,32) > distant_th;
%         distant_body_mask = results.data_mat(:,33) > distant_th;
%         distant_place_mask = results.data_mat(:,35) > distant_th;
%         
%         % division to regions by selectivity and distance 
%         
%         roi_masks = zeros(length(find(results.conj_mask)), 12);
%         
%         roi_masks(:,1) = face_selective_mask & distant_body_mask & distant_place_mask;
%         roi_masks(:,2) = face_selective_mask & ~distant_body_mask & distant_place_mask;
%         roi_masks(:,3) = face_selective_mask & distant_body_mask & ~distant_place_mask;
%         roi_masks(:,4) = face_selective_mask & ~distant_body_mask & ~distant_place_mask;
%         
%         roi_masks(:,5) = body_selective_mask & distant_face_mask & distant_place_mask;
%         roi_masks(:,6) = body_selective_mask & ~distant_face_mask & distant_place_mask;
%         roi_masks(:,7) = body_selective_mask & distant_face_mask & ~distant_place_mask;
%         roi_masks(:,8) = body_selective_mask & ~distant_face_mask & ~distant_place_mask;
%         
%         roi_masks(:,9) = place_selective_mask & distant_face_mask & distant_body_mask;
%         roi_masks(:,10) = place_selective_mask & ~distant_face_mask & distant_body_mask;
%         roi_masks(:,11) = place_selective_mask & distant_face_mask & ~distant_body_mask;
%         roi_masks(:,12) = place_selective_mask & ~distant_face_mask & ~distant_body_mask;
%         
%         
%         for roi_itr = 1:length(roi_masks_headers)
%         
%             curr_roi_mask = curr_region_mask & roi_masks(:,roi_itr);
%             curr_data_exclude_neighbors = results.data_mat(curr_roi_mask,:);
%             curr_voxel_inds = subj_region_voxel_inds(curr_roi_mask);
% 
%             roi_size = sum(curr_roi_mask);
%     %         subj_name_cells = repmat({results.subj_name},roi_size,1);
%             subj_number = str2num(results.subj_name(end-1:end));
%     
%             vec_data = zeros(size(results.conj_mask));
%             conj_inds = find(results.conj_mask);
%             vec_data(conj_inds(curr_roi_mask)) = 1;
%             
%            
%             curr_vol.fname = [freesurfer_data_dir filesep region_masks_headers{region_itr} '_' roi_masks_headers{roi_itr},...
%                  '_subj_' num2str(subj_itr, '%.2d') '_roi.nii'];
%             spm_write_vol(curr_vol, reshape(vec_data, curr_vol.dim)); 
% 
%             
% %             curr_data_mat = [subj_number*ones(roi_size,1), roi_itr*ones(roi_size,1),curr_voxel_inds, curr_data_exclude_neighbors];
% %             data_mat = [data_mat;curr_data_mat];
%         end
%     end
%     
% %     t = array2table(data_mat,'VariableNames',table_headers);
% %     table_name = [results_dir filesep region_masks_headers{region_itr} '_all_voxles_excluding_neighbors_by_rois_dist_0.csv'];
% %     writetable(t,table_name);
%     % TODO save 
% end
% 
% % %% predict - leave-1-subj-out
% % 
% % t = readtable([results_dir filesep 'Category_Right_exclude_neighbors.csv']);
% % 
% % voxel_num = size(t,1);
% % subj_list = unique(t.subj);
% % subj_num = length(subj_list);
% % 
% % Wf_pred = zeros(voxel_num,1);
% % Wb_pred = zeros(voxel_num,1);
% % 
% % t = [t,table(Wf_pred,Wb_pred)];
% % 
% % Wf_pred_corr = zeros(1,subj_num);
% % Wb_pred_corr = zeros(1,subj_num);
% % 
% % Wf_coefs = zeros(3,subj_num);
% % Wb_coefs = zeros(3,subj_num);
% % 
% % for subj_itr = 1:subj_num
% %    curr_subj_rows = t.subj==subj_itr;
% %    
% %    % predict wf and wb based on face and body selectivity of all voxels
% %    % except the curr subject
% %    modelspec_Wf = 'Wf~face_object_t_s+body_object_t_s';
% %    modelspec_Wb = 'Wb~face_object_t_s+body_object_t_s';
% %    
% %    mdl_Wf = fitlm(t(~curr_subj_rows,:),modelspec_Wf);
% %    mdl_Wb = fitlm(t(~curr_subj_rows,:),modelspec_Wb);
% %    
% %    Wf_coefs(:,subj_itr) = mdl_Wf.Coefficients.Estimate;
% %    Wb_coefs(:,subj_itr) = mdl_Wb.Coefficients.Estimate;
% %    
% %    % compute the prediction for the curr subj based on the regression
% %    t.Wf_pred(curr_subj_rows) = predict(mdl_Wf, t(curr_subj_rows,:));
% %    t.Wb_pred(curr_subj_rows) = predict(mdl_Wf, t(curr_subj_rows,:));
% %    
% %    % correlate between predictions and results
% %    Wf_pred_corr(subj_itr) = corr(t.Wf_pred(curr_subj_rows), t.Wf(curr_subj_rows));
% %    Wb_pred_corr(subj_itr) = corr(t.Wb_pred(curr_subj_rows), t.Wb(curr_subj_rows));
% %       
% %    % compute the prediction for the curr subj based on the regression
% %    % values we got and compute the square (or abs?) of the difference
% %    % between prediction and real data
% %    
% %    
% %    
% %    % permutaion? mix face and body selectivity labels and do last 2 steps.
% %    % repeat 10000 times. see if the difference is smaller than expected for
% %    % p=0.05
% %    
% %     
% %     
% % end
% % 
% % % perm_vec = randi(2,voxel_num,1);
% % % perm_vec = perm_vec-1;
% % % 
% % % t.face_object_permed(perm_vec) = t.face_object_t_s(perm_vec);
% % % t.face_object_permed(~perm_vec) = t.body_object_t_s(~perm_vec);
% % % 
% % % t.body_object_permed(perm_vec) = t.body_object_t_s(perm_vec);
% % % t.body_object_permed(~perm_vec) = t.face_object_t_s(~perm_vec);
% % % 
