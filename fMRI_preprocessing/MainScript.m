
function [times] = MainScript()  
    
    addpath('/data/libi/fMRI_analyses/gyfmri_libi_12');
    
    Settings = loadSettings();
  
    
    
%% Phase 1 - convert and arrange data    
    convertDicoms(Settings);
    removeDummyScans(Settings);

    
%% Phase 2 - preprocessing
    Phase2_preprocessing(Settings);  
    check_motion(Settings); 
    resample_img(Settings);
   
    
%% Stop for CheckReg and check motion files!!
    
%% phase 3 - run GLM model

    Phase3_runGLM(Settings);


%% phase 4
     Phase4a_new(Settings);

end

function [Settings] = loadSettings()
    [FileName,PathName,FilterIndex] = uigetfile('CreateSettings.m');
    
    currDir = pwd;
    cd (PathName);
    funcName = FileName(1:(end-2));
    Settings = feval(funcName);
    cd (currDir);
end

