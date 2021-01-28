function []=Phase2_preprocessing(Settings) %Previously batch_preprocess_multsubj_spm5


%% Settings

StartFilePrefix='s0'; % prefix of *.img files to be preprocessed

is_perform_realignment = 1;
is_perform_coregister = 1;
is_perform_segmentation = 1;
is_perform_data_normalization = 1;
is_perform_smoothing = 1;

    
templ_param_smooth_FWHM = 5; % smooth kernel radius (in mm) 

MNI_template_file_full_path = [Settings.spmpath filesep 'canonical' filesep 'avg305T1.nii'];
aal_source_file_full_path = [Settings.spmpath filesep 'toolbox' filesep 'aal' filesep 'ROI_MNI_V4.nii'];
spm_labels_source_file_full_path = [Settings.spmpath filesep 'tpm' filesep 'labels_Neuromorphometrics.nii'];

subj_num = length(Settings.Sessions);

%% %%%%%%%%Script start %%%%%%%%%%%%%%%
addpath(Settings.spmpath);
spm fmri;



for subj_itr = 1:subj_num
    
    filePrefix = StartFilePrefix;
    
    curr_subject_session_info = Settings.Sessions{subj_itr};
    curr_subject_spm_path = [Settings.SpmDir filesep curr_subject_session_info{2}];
    dataFolders = curr_subject_session_info(3:(end-1)); % all EPI folders, not including the MPRANGE which is the last folder
    means_file_path = [curr_subject_spm_path filesep curr_subject_session_info{3}];
    
    anatomy_file_path = [curr_subject_spm_path filesep curr_subject_session_info{end}];
    temp_anatomy_file_dirs = dir ([anatomy_file_path filesep 's*.img']);
    anatomy_file_full_path = [anatomy_file_path filesep temp_anatomy_file_dirs(1).name];
    anatomy_file = dir ([anatomy_file_path filesep 's*.img']);

    
    cd(curr_subject_spm_path);
    
    %% realignment
    if is_perform_realignment
        disp(['REALIGNING - subj: ' curr_subject_session_info{2}]);
        % realign parameters
        jobs{1}.spm.spatial.realign.estwrite.data = '';

        jobs{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
        jobs{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
        jobs{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
        jobs{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
        jobs{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
        jobs{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
        jobs{1}.spm.spatial.realign.estwrite.eoptions.weight = '';

        jobs{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
        jobs{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
        jobs{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
        jobs{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
        jobs{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';    

        jobs{1}.spm.spatial.realign.estwrite.data = cell(1,length(dataFolders));

        for runs_itr = 1:length(dataFolders)

            currRunPath = [curr_subject_spm_path filesep dataFolders{runs_itr}];
            ValidateSessionFolder(currRunPath, filePrefix);

            d = dir([currRunPath filesep filePrefix '*.img']);    %load file names of files for preprocessing
            files={d.name}';
            % add files to the templae
            jobs{1}.spm.spatial.realign.estwrite.data{runs_itr} = cellstr(strcat([currRunPath filesep] ,files,',1'));

        end

        %run realignment:
        spm_jobman('run' , jobs);   
    end % end is_perform_realignment
    
    filePrefix = ['r',filePrefix];  %add 'r' at the beginning of file prefix
    jobs = [];
    
    
    %% coregistration 
    if is_perform_coregister
       
        disp(['COREGISTRATION - subj: ' curr_subject_session_info{2}]);
       
       % We do the coregistration in two steps:
       %   1. Coregister the subject anatimical scan to a template: spm12\canonical\avg305T1.nii
       %   2. Coregister all the EPIs to the anatomical scan.
       
       jobs{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
       jobs{1}.spm.spatial.coreg.estimate.eoptions.sep = [4,2];
       jobs{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02,0.02,0.02,0.001,0.001,0.001,0.01,0.01,0.01,0.001,0.001,0.001;];
       jobs{1}.spm.spatial.coreg.estimate.eoptions.fwhm= [ 7,7];
       
       means_file = dir([means_file_path filesep 'means*.img']);
       
       % first step - coregister the anatomy image to a cannical template image in
       % MNI coordinates
       jobs{1}.spm.spatial.coreg.estimate.ref = {[MNI_template_file_full_path ',1']}; % the reference is MNI canonical img file that comes with the SPM package
       jobs{1}.spm.spatial.coreg.estimate.source = {[anatomy_file_full_path ',1']}; % the source image (that is being moved to fit to the reference image) is the anatomy img
       jobs{1}.spm.spatial.coreg.estimate.other = {{}};
       
       % run coregister of anatomical image to canonical template
       spm_jobman('run' , jobs);
       
       % second step - coregister the EPI images to the anatomical image. we
       % use the means file that was created after the realignment procedure
       % as a the source image. all EPIs are alligned to the mean image, so
       % they share the same orientation matrix. all EPIs are transformed
       % together with the mean image (listed as 'others')
       
       jobs{1}.spm.spatial.coreg.estimate.ref = {[anatomy_file_path filesep anatomy_file(1).name ',1']}; % the reference is the anatomy img
       jobs{1}.spm.spatial.coreg.estimate.source = {[means_file_path filesep means_file(1).name ',1']}; % the source image (that is being moved to fit to the reference image) is the mean functional img file that realign saves at the first functional images folder
                  
       jobs{1}.spm.spatial.coreg.estimate.other=[];
       
       for runs_itr = 1:length(dataFolders)
 
           currRunPath = [curr_subject_spm_path filesep dataFolders{runs_itr}];         
           DirsList=dir([currRunPath filesep filePrefix '*.img']); %load file names of files for preprocessing
           
           for files_ind = 1:length(DirsList)
               jobs{1}.spm.spatial.coreg.estimate.other{end+1,1}=[currRunPath filesep DirsList(files_ind).name ',1'];
           end
           
       end
       
       % run coregister of epi images to anatomical images
       spm_jobman('run' , jobs);
       jobs = [];
    end
    
    
    
    %% segmentation 
    if is_perform_segmentation
       
        disp(['SEGMRNTATION - subj: ' curr_subject_session_info{2}]);
        
        jobs{1}.spm.spatial.preproc.channel.vols = [];
        jobs{1}.spm.spatial.preproc.channel.biasreg = 0.001;
        jobs{1}.spm.spatial.preproc.channel.biasfwhm = 60;
        jobs{1}.spm.spatial.preproc.channel.write = [0 1];
        jobs{1}.spm.spatial.preproc.tissue(1).tpm = {[Settings.spmpath filesep 'tpm' filesep 'TPM.nii,1']};
        jobs{1}.spm.spatial.preproc.tissue(1).ngaus = 2;
        jobs{1}.spm.spatial.preproc.tissue(1).native = [1 0];
        jobs{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
        jobs{1}.spm.spatial.preproc.tissue(2).tpm = {[Settings.spmpath filesep 'tpm' filesep 'TPM.nii,2']};
        jobs{1}.spm.spatial.preproc.tissue(2).ngaus = 2;
        jobs{1}.spm.spatial.preproc.tissue(2).native = [1 0];
        jobs{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
        jobs{1}.spm.spatial.preproc.tissue(3).tpm = {[Settings.spmpath filesep 'tpm' filesep 'TPM.nii,3']};
        jobs{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
        jobs{1}.spm.spatial.preproc.tissue(3).native = [1 0];
        jobs{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
        jobs{1}.spm.spatial.preproc.tissue(4).tpm = {[Settings.spmpath filesep 'tpm' filesep 'TPM.nii,4']};
        jobs{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
        jobs{1}.spm.spatial.preproc.tissue(4).native = [1 0];
        jobs{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
        jobs{1}.spm.spatial.preproc.tissue(5).tpm = {[Settings.spmpath filesep 'tpm' filesep 'TPM.nii,5']};
        jobs{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
        jobs{1}.spm.spatial.preproc.tissue(5).native = [1 0];
        jobs{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
        jobs{1}.spm.spatial.preproc.tissue(6).tpm = {[Settings.spmpath filesep 'tpm' filesep 'TPM.nii,6']};
        jobs{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
        jobs{1}.spm.spatial.preproc.tissue(6).native = [0 0];
        jobs{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
        jobs{1}.spm.spatial.preproc.warp.mrf = 1;
        jobs{1}.spm.spatial.preproc.warp.cleanup = 1;
        jobs{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
        jobs{1}.spm.spatial.preproc.warp.affreg = 'mni';
        jobs{1}.spm.spatial.preproc.warp.fwhm = 0;
        jobs{1}.spm.spatial.preproc.warp.samp = 3;
        jobs{1}.spm.spatial.preproc.warp.write = [1 1];
        
           
        jobs{1}.spm.spatial.preproc.channel.vols = {[anatomy_file_full_path ',1']};

        % run segmentation
        spm_jobman('run' , jobs);  
        
        jobs = [];
    end
    
        
    
     %% data normalization 
    if is_perform_data_normalization
       
        disp(['DATA NORMALIZATION - subj: ' curr_subject_session_info{2}]);
        
        % normalize EPIs with voxel resolution of [2 2 2] (original epi resolution)
%          jobs{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70 ; 78 76 85];
        jobs{1}.spm.spatial.normalise.write.woptions.bb = [-90 -126 -72 ; 90 90 108];
        jobs{1}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
        jobs{1}.spm.spatial.normalise.write.woptions.interp = 4;
        jobs{1}.spm.spatial.normalise.write.woptions.prefix = 'w';
               
        deformation_file = dir ([anatomy_file_path filesep 'y_*.nii']);        
        jobs{1}.spm.spatial.normalise.write.subj.def = {[anatomy_file_path filesep deformation_file(1).name]};
                
        resample_files = cell(1,length(dataFolders)+1);       

        for runs_ind = 1:length(dataFolders)
            
            currRunPath = [curr_subject_spm_path filesep dataFolders{runs_ind}];
            ValidateSessionFolder(currRunPath, filePrefix);
            
            d = dir([currRunPath filesep filePrefix '*.img']);    %load file names of files for preprocessing
            files={d.name}';
            
            resample_files{runs_ind} = cellstr(strcat([currRunPath filesep] ,files,',1'));
            
        end
        
        means_file = dir([means_file_path filesep 'means*.img']);
        resample_files(length(dataFolders)+1) = {{[means_file_path filesep means_file(1).name ',1']}};
        
        jobs{1}.spm.spatial.normalise.write.subj.resample = vertcat(resample_files{:});
        
        % run normalization for epi data
        spm_jobman('run' , jobs);   % run normalization
        
        % normalize anatomical image with [1 1 1] voxels size
        jobs{1}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
        jobs{1}.spm.spatial.normalise.write.subj.resample = [];
        jobs{1}.spm.spatial.normalise.write.subj.resample = {[anatomy_file_path filesep anatomy_file(1).name ',1']};
        
        % run normalization for anatomical image
        spm_jobman('run' , jobs);
        
        filePrefix = ['w',filePrefix]; %add 'w' to file prefix
        jobs=[];
    
    end
    
     %% smoothing
    if is_perform_smoothing
       
        disp(['SMOOTHING - subj: ' curr_subject_session_info{2}]);
        
        jobs{1}.spm.spatial.smooth.data = '';
        jobs{1}.spm.spatial.smooth.fwhm = ones(1,3)* templ_param_smooth_FWHM;
        jobs{1}.spm.spatial.smooth.dtype = 0;
        jobs{1}.spm.spatial.smooth.im = 0;
        jobs{1}.spm.spatial.smooth.prefix = 's';
               
        Images = '';
        
        for runs_ind = 1:length(dataFolders)
            
            currRunPath = [curr_subject_spm_path filesep dataFolders{runs_ind}];
            ValidateSessionFolder(currRunPath, filePrefix);
            
            d=dir([currRunPath filesep filePrefix '*.img']); %load file names of files for preprocessing
            files={d.name}';
            
            Images = [Images; cellstr(strcat([currRunPath filesep] ,files,',1'))];
            
        end
        
        means_file_path = [curr_subject_spm_path filesep curr_subject_session_info{3}];
        means_file = dir([means_file_path filesep 'means*.img']);
        
        Images = [Images; {[means_file_path filesep means_file(1).name ',1']}];
        
        jobs{1}.spm.spatial.smooth.data='';
        jobs{1}.spm.spatial.smooth.data=Images;
       
        % run smoothing
        spm_jobman('run' , jobs); %ron smoothing
        
                filePrefix = ['s',filePrefix]; %add 's' to file prefix
        jobs=[];
    end
    
end




end

%%

function ValidateSessionFolder(sessionPath, filePrefix)
    if exist(sessionPath,'dir') == 0
        error(['Directory ' sessionPath ' doesnt exist. We stop running...']);
    end

    d=dir([sessionPath filesep filePrefix '*.img']);
    if length(d) == 0
        error(['In direcory ' sessionPath ' no files with prefix ' filePrefix '. We stop running...']);
    end
end

