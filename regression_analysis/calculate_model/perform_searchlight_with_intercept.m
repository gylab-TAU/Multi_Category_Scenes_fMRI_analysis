function [results] = perform_searchlight_with_intercept(data, settings, params)

subj_name = settings.subj_file(1:(end-4));
% sub_folder_path = [setting
% s.method];
results_path = [settings.path_Results];
results.subj_name = subj_name;

this_time = fix(clock);
this_time_str = [num2str(this_time(3)) '_' num2str(this_time(2)) '_' num2str(this_time(1)) '_' num2str(this_time(4)) '_' num2str(this_time(5))];

results.file_name_prefix = ['searchlight_weights_' settings.data.data_design '_' this_time_str];

results.settings = settings;
results.params = params;

if ~exist(results_path, 'dir')
    mkdir (results_path);
end


voxels_num = length(data.inds.voxel_ind);
% min_X_ind = min(data.inds.X_ind);
% max_X_ind = max(data.inds.X_ind);
% min_Y_ind = min(data.inds.Y_ind);
% max_Y_ind = max(data.inds.Y_ind);
% min_Z_ind = min(data.inds.Z_ind);
% max_Z_ind = max(data.inds.Z_ind);

volume_size = [max(data.inds.X_ind), max(data.inds.Y_ind), max(data.inds.Z_ind)];

results.betas = nan(voxels_num,length(data.single_cond_headers)+1);
results.Rsq = nan(voxels_num,1);
results.voxel_num_for_calc = zeros(voxels_num,1);
results.mean_loc_t_vals = zeros(voxels_num,length(data.loc_t_names));
results.loc_t_vals_names = data.loc_t_names;
results.conj_mask = data.conj_mask;
results.min_dist = nan(voxels_num,length(data.dist_t_names));

single_conds_all = zeros(length(data.conj_mask),length(data.single_cond_data));
for cond_itr = 1:length(data.single_cond_data)
    single_conds_all(:,cond_itr) = mean(data.single_cond_data{cond_itr},2);
end

combined_cond_all = mean(data.combined_cond_data,2);


masked_voxels = find(data.conj_mask);
% masked_dist_t_vals = data.dist_t_vals(data.conj_mask,:);

masked_selectivity_coord_X = cell(1,length(data.dist_t_names));
masked_selectivity_coord_Y = cell(1,length(data.dist_t_names));
masked_selectivity_coord_Z = cell(1,length(data.dist_t_names));

for dist_contrast_itr = 1:length(data.dist_t_names)
       
    curr_contrast_mask = data.dist_t_vals(data.conj_mask,dist_contrast_itr) > data.dist_contrast_th;
    
    masked_selectivity_coord_X{dist_contrast_itr} = data.coords.X(data.conj_mask); 
    masked_selectivity_coord_X{dist_contrast_itr} = masked_selectivity_coord_X{dist_contrast_itr}(curr_contrast_mask);
    
    masked_selectivity_coord_Y{dist_contrast_itr} = data.coords.Y(data.conj_mask); 
    masked_selectivity_coord_Y{dist_contrast_itr} = masked_selectivity_coord_Y{dist_contrast_itr}(curr_contrast_mask);
    
    masked_selectivity_coord_Z{dist_contrast_itr} = data.coords.Z(data.conj_mask); 
    masked_selectivity_coord_Z{dist_contrast_itr} = masked_selectivity_coord_Z{dist_contrast_itr}(curr_contrast_mask);
 
end


for masked_voxel_itr = 1:length(masked_voxels)
    
    voxel_itr = masked_voxels(masked_voxel_itr);
    
    % curr center voxel in XYZ
    [center_X, center_Y, center_Z] = ind2sub(volume_size, voxel_itr);
    
    voxel_list_X = zeros(1,27);
    voxel_list_Y = zeros(1,27);
    voxel_list_Z = zeros(1,27);
    voxel_list_itr = 0;
    
    for X_itr = 1:3
        
        curr_X = center_X-2+X_itr;
        if curr_X < 1 || curr_X > volume_size(1)
            continue
        end
        
        for Y_itr = 1:3
            
            curr_Y = center_Y-2+Y_itr;
            if curr_Y < 1 || curr_Y > volume_size(2)
                continue
            end
            
            for Z_itr = 1:3
                
                curr_Z = center_Z-2+Z_itr;
                if curr_Z < 1 || curr_Z > volume_size(3)
                    continue
                end
                
                % update voxels list
                voxel_list_itr = voxel_list_itr + 1;
                voxel_list_X(voxel_list_itr) = curr_X;
                voxel_list_Y(voxel_list_itr) = curr_Y;
                voxel_list_Z(voxel_list_itr) = curr_Z;
                
                
            end
        end
    end
    
    % get voxel inds
    voxel_list_inds = sub2ind   (volume_size,...
                                voxel_list_X(1:voxel_list_itr),...
                                voxel_list_Y(1:voxel_list_itr),...
                                voxel_list_Z(1:voxel_list_itr)); 
    
    % remove voxels from list that are out of the mask
%     included_inds_of_list = find(data.conj_mask(voxel_list_inds));
%     voxel_list_inds = voxel_list_inds(included_inds_of_list);    
    voxel_list_inds = voxel_list_inds(data.conj_mask(voxel_list_inds));
    
    if length(voxel_list_inds) < 10
        continue
    end
    
%     % run regression calculator
    
    [b,~,~,~,stats] = regress(combined_cond_all(voxel_list_inds),[ones(length(voxel_list_inds),1),single_conds_all(voxel_list_inds,:)]);
    
    results.betas(voxel_itr,:) = b;
    results.Rsq(voxel_itr) = stats(1);
    
    % calculate distance from nearest voxelss
    curr_X_coords = data.coords.X(voxel_itr);
    curr_Y_coords = data.coords.Y(voxel_itr);
    curr_Z_coords = data.coords.Z(voxel_itr);
    
    
    
    for dist_contrast_itr = 1:length(data.dist_t_names)
       
%         curr_contrast_mask = masked_dist_t_vals(:,dist_contrast_itr) > data.dist_contrast_th;
        
        dist_vec =  (masked_selectivity_coord_X{dist_contrast_itr} - curr_X_coords).^2 + ...
                    (masked_selectivity_coord_Y{dist_contrast_itr} - curr_Y_coords).^2 + ...
                    (masked_selectivity_coord_Z{dist_contrast_itr} - curr_Z_coords).^2 ;
    
        results.min_dist(voxel_itr, dist_contrast_itr) = sqrt(min(dist_vec));

    end
    

    
    results.voxel_num_for_calc(voxel_itr) = length(voxel_list_inds);
    

end

%% calculate sum and diff of weights for all voxels

results.sum = sum(results.betas,2);
results.center_loc_t_vals = data.loc_t_vals;
results.coords = [data.coords.X,data.coords.Y,data.coords.Z];
results.center_model_psc_vals = [single_conds_all,combined_cond_all];
results.roi_masks = data.roi_masks;
results.roi_masks_headers = data.roi_masks_headers;
results.conj_mask = data.conj_mask;


%% get all results in a table format

results.data_mat = [results.betas, results.sum, ...
                    results.Rsq, results.center_loc_t_vals, results.center_model_psc_vals,...
                    results.coords, results.voxel_num_for_calc, results.min_dist];
                
results.data_mat = results.data_mat(results.conj_mask,:);

% results.data_mat_headers = {'betas','sum','diff','Rsq', 'loc_t','model_PSC','coords','voxel_num'};
results.data_mat_headers = {};
results.data_mat_headers = [results.data_mat_headers, 'beta_intercept'];
for itr = 1:length(data.single_cond_names)    
    results.data_mat_headers = [ results.data_mat_headers, ['beta_' data.single_cond_names{itr}]];     
end

results.data_mat_headers = [ results.data_mat_headers, {'sum','Rsq'}];

for itr = 1:length(data.loc_t_names)    
    results.data_mat_headers = [ results.data_mat_headers, ['t_' data.loc_t_names{itr}]];     
end

for itr = 1:length(data.single_cond_names)    
    results.data_mat_headers = [ results.data_mat_headers, ['model_PSC_' data.single_cond_names{itr}]];     
end

results.data_mat_headers = [ results.data_mat_headers, ['model_PSC_' data.combined_cond_name]];
results.data_mat_headers = [ results.data_mat_headers, {'coords_X' 'coords_Y' 'coords_Z','voxel_num'}];

for itr = 1:length(data.dist_t_names)
    results.data_mat_headers = [ results.data_mat_headers, ['min_dist_' data.dist_t_names{itr}]];
end

% %% filter neighboring voxels
% 
% neighbors_mask = zeros(volume_size);
% neighbors_mask(1:2:end,1:2:end,1:2:end)=1;
% neighbors_mask = reshape(neighbors_mask, voxels_num,[]);
% 


results.curr_vol = data.spm_vol;
%% save results
save ([results_path filesep results.file_name_prefix '_' subj_name '.mat'], 'results');

