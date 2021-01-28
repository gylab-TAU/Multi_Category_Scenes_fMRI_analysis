function [data,settings, params] = searchlight_per_subject(settings, params, load_setting_file_name)

rng('default')


if isempty(load_setting_file_name)
    [settings, params] = load_settings_params(settings, params);
    
else
    currDir = pwd;
    [pathstr,name,ext] = fileparts(load_setting_file_name);
    cd (pathstr);
    [settings, params] = feval(name, settings, params);
    cd (currDir);
        
end


   
rng(params.seed);

% load mask and relevant pairs of conditions (data from all runs)
data = load_data_searchlight(settings);

% prepare data for analysis
data = divide_data_to_conditions(settings, data);

% perform analysis
results = perform_searchlight_with_intercept(data, settings, params);


end


function [settings, params] = load_settings_params()
    [FileName,PathName,FilterIndex] = uigetfile('CreateSettingsParams.m');
    
    currDir = pwd;
    cd (PathName);
    funcName = FileName(1:(end-2));
    [settings, params] = feval(funcName);
    cd (currDir);
end
