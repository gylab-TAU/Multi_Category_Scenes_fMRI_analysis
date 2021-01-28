
function [Settings] = CreateSettings() 
    

    %% settings

    clear Settings;

    Settings.dcm2nii_path = '../mricron/dcm2nii';
    Settings.dcm2nii_ini_path = './dcm2nii.ini';
    Settings.SpmVer='12';
    Settings.spmpath= '../spm12';
    Settings.marsbarpath = [Settings.spmpath '/toolbox/marsbar'];
    Settings.ProgDir='./'; 
    Settings.ProjDir='./';
    
    % path for raw data (dicom files)
    Settings.SubjDir='../data/dicom_files/';
    
    % path for .nii data and all further analysis files:
    Settings.SpmDir ='../data/nii_files/'; 
    
    % each row is a single subject. 
    % First value: name of subject's dicom dir
    % Second valuus: name of subject's nii dir
    % Third to (n-1) values: names of functional run's data dirs (numbered by the order of original scanning)
    % Last value: name of MPRAGE data dir
    Settings.Sessions = {{'subj_02','subj_02','05','07','09','11','13','15','22','24','26','28','17'} %2
                         {'subj_03','subj_03','03','05','07','09','11','13','20','22','24','26','15'} %3
                         {'subj_04','subj_04','03','05','07','09','11','13','20','22','24','26','15'} %4 
                         {'subj_05','subj_05','03','05','07','09','11','13','20','22','24','26','15'} %5
                         {'subj_06','subj_06','03','05','07','09','11','13','20','22','24','26','15'} %6
                         {'subj_07','subj_07','03','05','07','09','11','13','20','22','24','26','15'} %7
                         {'subj_08','subj_08','03','05','07','09','11','13','20','22','24','26','15'} %8
                         {'subj_09','subj_09','03','05','07','09','11','13','20','22','24','26','15'} %9
                         {'subj_10','subj_10','03','05','07','09','11','13','20','22','24','26','15'} %10
                         {'subj_11','subj_11','03','05','07','09','11','13','20','22','24','26','15'} %11
                         {'subj_12','subj_12','03','05','07','09','11','13','20','22','24','26','15'} %12
                         {'subj_13','subj_13','05','07','11','13','15','17','24','26','28','30','19'} %13
                         {'subj_14','subj_14','3','5','7','9','11','13','20','22','24','26','15'} %14
                         {'subj_15','subj_15','3','5','7','9','11','13','20','22','24','26','15'} %15
                         {'subj_16','subj_16','3','5','7','9','11','13','20','22','24','26','15'} %16
                         }; % MPRAGE should be last
                    
    Settings.NumOfDummyScans = 6; % in TRs. If this number is different for different runs, than it should be an array at the size of the num of runs at the same order as in the sessions var.
    Settings.RoiDirs={'p_FFA','m_FFA','OFA','STS-FA', 'EBA', 'FBA','pFS','LO', 'PPA', 'RSC', 'TOS', 'FB_fus', 'FB_lateral', 'medial_obj'};
    Settings.TR = 1; %in sec
    
    Settings.output_Graph_jpegs=1;  % 0 = don't output ; 1 = output
    Settings.output_number_of_bins = 34;
    Settings.isREML=1; % default is 1.
    
    % Experimet designs. Fill for each type of run separately
    % Experiment design #1 (localizer)
    Settings.ExpDesign{1}.Name = 'Localizer_mni';
    Settings.ExpDesign{1}.FilePrefix = 'swrs'; %(Normalized smoothed-swars, smoothed-sars,Normalized unsmoothed-wars, unsmoothed-ars,or any other prefix). usually localizer uses sars and model uses ars.
    Settings.ExpDesign{1}.HasContrasts = 1; % at old versions: Contrast
    Settings.ExpDesign{1}.output_number_of_bins = 34;
    Settings.ExpDesign{1}.addRTRegressor = 0;
    Settings.ExpDesign{1}.regressionFolder = ''; % Should be filled if addRTRegressor is 1
    Settings.ExpDesign{1}.ConditionsNames = {'Faces'  'Bodies' 'Objects' 'Scenes','Scrambled_Objects' }; % at old versions: ContrastParts
    Settings.ExpDesign{1}.model_type = 'beta_for_cond'; % 'beta_for_single_trial' or 'beta_for_cond'

    
    Settings.ExpDesign{1}.contrastsAcrossRuns.HasContrasts = 1; %1 1=one contrast across all runs.
    Settings.ExpDesign{1}.contrastsAcrossRuns.ContrastsNames = { 'Faces>Objects'  % at the same order of the contrasts themselves
                                                                 'Bodies>Objects'
                                                                 'Objects>Scrambled'
                                                                 'Scenes>Objects'
                                                                 'Faces>all'
                                                                 'Bodies>all'
                                                                 'Objects>all'
                                                                 'Scenes>all'
                                                                 'Faces_Bodies>Objects'
                                                                 'Faces>other_cat'
                                                                 'Bodies>other_cat'
                                                                 'Objects>other_cat'
                                                                 'Scenes>other_cat'
                                                                 'Face>Body'
                                                                 'Objects>Faces_Bodies'
                                                                 'Objects_Scenes>Faces_Bodies'
                                                                 'Objects>Scenes'};
                                                             
    Settings.ExpDesign{1}.contrastsAcrossRuns.Contrasts = { [1 0 -1 0 0]  % at old versions: numbers instaed of a vector. The order of the 0's and 1's represents the order of condition names.
                                                            [0 1 -1 0 0]
                                                            [0 0 1 0 -1]
                                                            [0 0 -1 1 0]
                                                            [1 -0.25 -0.25 -0.25 -0.25]
                                                            [-0.25 1 -0.25 -0.25 -0.25]
                                                            [-0.25 -0.25 1 -0.25 -0.25]
                                                            [-0.25 -0.25 -0.25 1 -0.25]
                                                            [0.5 0.5 -1 0 0]
                                                            [3 -1 -1 -1 0]
                                                            [-1 3 -1 -1 0]
                                                            [-1 -1 3 -1 0]
                                                            [-1 -1 -1 3 0]
                                                            [1 -1 0 0 0]
                                                            [-0.5 -0.5 1 0 0]
                                                            [-0.5 -0.5 0.5 0.5 0]
                                                            [0 0 1 -1 0]};
    
    Settings.ExpDesign{1}.contrastsSingleRun.HasContrasts = 0; %1 = a different contrast for each run. 
    Settings.ExpDesign{1}.contrastsSingleRun.ContrastsNames = {} ; % at the same order of the contrasts themselves
                                                                
    Settings.ExpDesign{1}.contrastsSingleRun.Contrasts = {}; % at old versions: numbers instaed of a vector. The order of the 0's and 1's represents the order of condition names.
                                                          
    
    % The numbers in DesignFiles relate to the order in ConditionNames. make
    % sure that the order of condition names is as written in your original
    % experiment code to match the design order.
%     Settings.ExpDesign{1}.DesignFilesType = 'prepared_mat'; % could be vec=vector of numbers; par=optseq2 output
    Settings.ExpDesign{1}.design_file_prefix = 'fboss_localizer';
 
    % Name of runs that were of the current design, a row for every subject
    Settings.ExpDesign{1}.runDirs = {{'07','11','15','24','28'} % 2
                                    {'05','09','13','22','26'} % 3 
                                    {'03','07','11','22','26'} % 4
                                    {'05','09','13','22','26'} % 5
                                    {'05','09','13','22','26'} % 6 
                                    {'05','09','13','22','26'} % 7
                                    {'05','09','13','22','26'} % 8 
                                    {'05','09','13','22','26'} % 9 
                                    {'05','09','13','22','26'} % 10
                                    {'05','09','13','22','26'} % 11
                                    {'05','09','13','22','26'} % 12
                                    {'05','11','15','26','30'} % 13
                                    {'5','9','13','22','26'} % 14
                                    {'5','9','13','22','26'} % 15
                                    {'5','9','13','22','26'} % 16
                                    };

    % Experiment design #2 
    Settings.ExpDesign{2}.Name = 'Model_mni';
    Settings.ExpDesign{2}.FilePrefix = 'wrs'; %(Normalized smoothed-swars, smoothed-sars,Normalized unsmoothed-wars, unsmoothed-ars,or any other prefix). usually localizer uses sars and model uses ars.
    Settings.ExpDesign{2}.addRTRegressor = 0;
    Settings.ExpDesign{2}.regressionFolder = ''; % Should be filled if addRTRegressor is 1
    Settings.ExpDesign{2}.HasContrasts = 0; % For now should be 0, otherwise it will create a problem with phase5
    Settings.ExpDesign{2}.output_number_of_bins = 24;
    Settings.ExpDesign{2}.ConditionsNames = {'Face','Body', 'Chair', 'Room', 'all'};% at old versions: ContrastParts
%     Settings.ExpDesign{2}.IsContrastsAcrossRuns = 0; %0 = a different contrast for each run. 1=one contrast across all runs.
    Settings.ExpDesign{2}.model_type = 'beta_for_cond'; % 'beta_for_single_trial' or 'beta_for_cond'


    Settings.ExpDesign{2}.contrastsAcrossRuns.HasContrasts = 1; % 1=one contrast across all runs.
    Settings.ExpDesign{2}.contrastsAcrossRuns.ContrastsNames = { 'Chair>Face'  % at the same order of the contrasts themselves
                                                                 'Chair>Body'
                                                                 'Chair>Room'
                                                                 'Chair>all_scene'
                                                                 'Chair>otherSingleCat'};
    Settings.ExpDesign{2}.contrastsAcrossRuns.Contrasts = { [-1 0 1 0 0]  % at old versions: numbers instaed of a vector. The order of the 0's and 1's represents the order of condition names.
                                                            [0 -1 1 0 0]
                                                            [0 0 1 -1 0]
                                                            [0 0 1 0 -1]
                                                            [-1 -1 -1 3 0]};
    
    % create contrasts for each beta -> the contrast is the t-value for the
    % beta
    Settings.ExpDesign{2}.contrastsSingleRun.HasContrasts = 0; %1 = a different contrast for each run. 
    N_conditions = length(Settings.ExpDesign{2}.ConditionsNames);
    Settings.ExpDesign{2}.Contrasts = cell(N_conditions,1);
    contrasts_template = zeros(1,N_conditions);
    for cont_ind = 1:N_conditions
        contrast = contrasts_template;
        contrast(cont_ind)=1;
        Settings.ExpDesign{2}.contrastsSingleRun.Contrasts{cont_ind} = contrast;
    end
    Settings.ExpDesign{2}.contrastsSingleRun.ContrastsNames = Settings.ExpDesign{2}.ConditionsNames;
    
    Settings.ExpDesign{2}.design_file_prefix = 'Scene_Integration';
    

    % The next three property are specific for each subject and therfor should contain a cell for each subject:    
     Settings.ExpDesign{2}.runDirs = {{'05','09','13','22','26'} % 2
                                      {'03','07','11','20','24'} % 3
                                      {'05','09','13','20','24'} % 4
                                      {'03','07','11','20','24'} % 5
                                      {'03','07','11','20','24'} % 6
                                      {'03','07','11','20','24'} % 7
                                      {'03','07','11','20','24'} % 8
                                      {'03','07','11','20','24'} % 9
                                      {'03','07','11','20','24'} % 10
                                      {'03','07','11','20','24'} % 11
                                      {'03','07','11','20','24'} % 12
                                      {'07','13','17','24','28'} % 13
                                      {'3','7','11','20','24'} % 14 
                                      {'3','7','11','20','24'} % 15 
                                      {'3','7','11','20','24'} % 16 
                                    };

                                
   
    % add spm path
    addpath (Settings.spmpath);
%     addpath (genpath  ([Settings.spmpath filesep 'toolbox']));
    addpath (Settings.ProgDir);



    % create project dir
    if (exist(Settings.ProjDir,'dir')~=7)
        mkdir(Settings.ProjDir);
    end


