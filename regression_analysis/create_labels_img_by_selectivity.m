params.seed = 1;

results_dir = './results';

images_dir = 'ROIs_masks';
freesurfer_data_dir = '/freesurfer_data/selectivity_labels';

mkdir(freesurfer_data_dir);
rng('default')
rng(params.seed);

%% load data

files = dir ([results_dir filesep '*.mat']);

load([results_dir filesep files(1).name]);

curr_vol = results.conj_vol; 
curr_vol.dt = [16 0];



voxels_type_masks_headers = {   'face_dist', 'face_prox_body', 'face_prox_P' , 'face_prox_BP',...
                            'body_dist', 'body_prox_F', 'body_prox_place' , 'body_prox_FP',...
                            'place_dist', 'place_prox_F', 'place_prox_B' , 'place_prox_FB'};

interesting_rois_inds = [1,2,5,7,9];

masks_num = length(voxels_type_masks_headers);
 


subj_num = length(files);

        
volume_size = results.curr_vol.dim;
voxels_num = length(results.conj_mask);

voxel_inds = (1:voxels_num)';

   


for subj_itr = 1:subj_num
    load([results_dir filesep files(subj_itr).name]);

    subj_region_voxel_inds = voxel_inds(results.conj_mask);

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


    for img_itr = 1:length(interesting_rois_inds)

        curr_roi_ind = interesting_rois_inds(img_itr);

        vec_data = zeros(size(voxel_inds));
        vec_data(subj_region_voxel_inds) = roi_masks(:,curr_roi_ind);


        curr_vol.fname = [freesurfer_data_dir filesep voxels_type_masks_headers{curr_roi_ind},...
                            '_subj_' num2str(subj_itr, '%.2d') '.nii'];

        spm_write_vol(curr_vol, reshape(vec_data, curr_vol.dim)); 

    end

end