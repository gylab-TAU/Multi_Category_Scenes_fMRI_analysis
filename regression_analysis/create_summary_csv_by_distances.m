params.seed = 1;

results_dir = './results';

rng('default')
rng(params.seed);

%% load data

files = dir ([results_dir filesep '*.mat']);

load([results_dir filesep files(1).name]);



VTC_vol = spm_vol('./anatomical_masks/VTC_HarvardOxford-cort-maxprob-thr0-2mm.nii');
VTC_mask = spm_read_vols(VTC_vol);

LOC_vol = spm_vol('./anatomical_masks/LOC_HarvardOxford-cort-maxprob-thr0-2mm.nii');
LOC_mask = spm_read_vols(LOC_vol);

N_voxels = length(VTC_mask);

region_masks = [VTC_mask(:), LOC_mask(:)];
region_masks_headers = {'VTC','LOC'}; 

roi_masks_headers = {   'face_dist', 'face_prox_B', 'face_prox_P' , 'face_prox_BP',...
                            'body_dist', 'body_prox_F', 'body_prox_P' , 'body_prox_FP',...
                            'place_dist', 'place_prox_F', 'place_prox_B' , 'place_prox_FB'};


subj_num = length(files);

table_headers = {'subj','roi','voxel_ind','b_intercept','b_Face', 'b_Body', 'b_Chair', 'b_Room', 'sum' 'Rsq_FB',...
                't_Face_Object', 't_Body_Object','t_Object_Scrambed',...
                't_Scene_Object', 't_Face_all', 't_Body_all', 't_Object_all', 't_Scene_all',...
                't_FaceBody_object', 't_Face_otherCat', 't_Body_otherCat', 't_Object_otherCat', 't_Scene_otherCat', 't_Face_Body', 't_Object_FaceBody',...
                'model_PSC_Face', 'model_PSC_Body', 'model_PSC_Chair', 'model_PSC_Room','model_PSC_All', ...
                'X','Y','Z','num_of_voxels', ...
                'min_dist_t_Face_Object','min_dist_t_Body_Object','min_dist_t_Scene_Object','min_dist_t_Object_Scrambled'};
        
volume_size = results.curr_vol.dim;
voxels_num = length(results.conj_mask);

voxel_inds = (1:voxels_num)';

neighbors_mask = zeros(volume_size);
neighbors_mask(1:2:end,1:2:end,1:2:end)=1;
neighbors_mask = reshape(neighbors_mask, voxels_num,[]);


for region_itr = 1:length(region_masks_headers)
    
    data_mat = [];
    
    for subj_itr = 1:subj_num
        load([results_dir filesep files(subj_itr).name]);
        
        curr_region_mask = region_masks(results.conj_mask  ,region_itr);
        curr_neighbors_mask = neighbors_mask(results.conj_mask);
        subj_region_voxel_inds = voxel_inds(results.conj_mask);
        
        curr_region_mask_exclude_neighbors_mask = curr_region_mask & curr_neighbors_mask;
        
        % category selective voxels p<0.0001
        face_selective_mask = results.data_mat(:,8) > 3.734836;
        body_selective_mask = results.data_mat(:,9) > 3.734836;
        place_selective_mask = results.data_mat(:,11) > 3.734836;
        
        % distant voxels by categories
        distant_th = 0;
        distant_face_mask = results.data_mat(:,32) > distant_th;
        distant_body_mask = results.data_mat(:,33) > distant_th;
        distant_place_mask = results.data_mat(:,34) > distant_th;
        
        % division to regions by selectivity and distance 
        
        roi_masks = zeros(length(find(results.conj_mask)), 12);
        
        roi_masks(:,1) = face_selective_mask & distant_body_mask & distant_place_mask;
        roi_masks(:,2) = face_selective_mask & ~distant_body_mask & distant_place_mask;
        roi_masks(:,3) = face_selective_mask & distant_body_mask & ~distant_place_mask;
        roi_masks(:,4) = face_selective_mask & ~distant_body_mask & ~distant_place_mask;
        
        roi_masks(:,5) = body_selective_mask & distant_face_mask & distant_place_mask;
        roi_masks(:,6) = body_selective_mask & ~distant_face_mask & distant_place_mask;
        roi_masks(:,7) = body_selective_mask & distant_face_mask & ~distant_place_mask;
        roi_masks(:,8) = body_selective_mask & ~distant_face_mask & ~distant_place_mask;
        
        roi_masks(:,9) = place_selective_mask & distant_face_mask & distant_body_mask;
        roi_masks(:,10) = place_selective_mask & ~distant_face_mask & distant_body_mask;
        roi_masks(:,11) = place_selective_mask & distant_face_mask & ~distant_body_mask;
        roi_masks(:,12) = place_selective_mask & ~distant_face_mask & ~distant_body_mask;
        
        
        for roi_itr = 1:length(roi_masks_headers)
        
            curr_roi_mask = curr_region_mask_exclude_neighbors_mask & roi_masks(:,roi_itr);
            curr_data_exclude_neighbors = results.data_mat(curr_roi_mask,:);
            curr_voxel_inds = subj_region_voxel_inds(curr_roi_mask);

            roi_size = sum(curr_roi_mask);
            subj_number = str2num(results.subj_name(end-1:end));
    

            curr_data_mat = [subj_number*ones(roi_size,1), roi_itr*ones(roi_size,1),curr_voxel_inds, curr_data_exclude_neighbors];
            data_mat = [data_mat;curr_data_mat];
        end
    end
    
    t = array2table(data_mat,'VariableNames',table_headers);
    table_name = [results_dir filesep region_masks_headers{region_itr} '_all_voxles_excluding_neighbors_by_distance.csv'];
    writetable(t,table_name);
end

