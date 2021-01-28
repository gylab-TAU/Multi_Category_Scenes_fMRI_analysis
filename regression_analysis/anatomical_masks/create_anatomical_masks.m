atlas_V = spm_vol('HarvardOxford-cort-maxprob-thr0-2mm.nii');

atlas_vals = spm_read_vols(atlas_V);

% List of indices of areas as they appear in the xml label file:
VTC_inds = [14:15, 33:34, 36:38];
LOC_inds = [12, 21:22];

% note that the index values in these xml files are equal to the volume number of the corresponding
% structure in the 4D prob atlases, but are one less than the number of the corresponding label in 
% the maxprob atlases.

VTC_inds = VTC_inds +1;
LOC_inds = LOC_inds +1;

VTC_mask = zeros(size(atlas_vals));
LOC_mask = zeros(size(atlas_vals));

for VTC_itr = 1:length(VTC_inds)
    
   VTC_mask(atlas_vals==VTC_inds(VTC_itr)) = 1;
   
end

for LOC_itr = 1:length(LOC_inds)
    
   LOC_mask(atlas_vals==LOC_inds(LOC_itr)) = 1;
   
end

VTC_vol = atlas_V;
VTC_vol.fname = 'VTC_HarvardOxford-cort-maxprob-thr0-2mm.nii';
spm_write_vol(VTC_vol, VTC_mask);

LOC_vol = atlas_V;
LOC_vol.fname = 'LOC_HarvardOxford-cort-maxprob-thr0-2mm.nii';
spm_write_vol(LOC_vol, LOC_mask);


