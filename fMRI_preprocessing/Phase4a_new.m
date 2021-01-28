function Phase4a_new (Settings)
% global Settings;
% load ([Settings.ProjDir filesep 'SpmDir.mat']);
% load ([Settings.ProjDir filesep 'Settings.mat']);

%feel free to add areas as you'd like. Please do not substract areas...
%dirs={'FFA', 'OFA','EBA','PFS','LO','STS','FBA','PPA','TOS','RSC'};  % original setting before changed by Jonathan Oron 27-07-14
% dirs={'FFA', 'OFA','EBA','PFS','LO','STS' ,'pSTS','aSTS','mSTS','FBA','PPA','TOS','RSC','MT','ATL','pIFG','aIFG','IFG','Amygdala'};  

dirs = Settings.RoiDirs;

%mkdir(SpmDir,'ROI_Analysis');

% for DesignNum=1:length(Settings.ExpDesign)
%     ParentDir=[Settings.SpmDir filesep 'ROI_Analysis' Settings.ExpDesign{DesignNum}.Name];
%     
%     for dirindex=1:length(dirs)
%         mkdir(ParentDir,[dirs{dirindex} '_right']);
%         mkdir(ParentDir,[dirs{dirindex} '_left']);
% %         rmdir([ParentDir filesep 'FFA_right']);
% %         rmdir([ParentDir filesep 'FFA_left']);
%     end
%     mkdir(ParentDir,'Excluded');
% end

SpmInfo=dir(Settings.SpmDir);

for index=1:length(SpmInfo)
    if strcmp(SpmInfo(index).name,'.') || strcmp(SpmInfo(index).name,'..') || ~isempty(strfind(SpmInfo(index).name,'ROI_Analysis'))
        continue;
    end
    for DesignNum=1:1%size(Settings.ExpDesign,2)
        ParentDir=[Settings.SpmDir filesep SpmInfo(index).name filesep 'Results'  Settings.ExpDesign{DesignNum}.Name '_m' filesep  'ROI_Analysis_rep'];
        rmdir(ParentDir, 's');
        mkdir(ParentDir);
        
        for dirindex=1:length(dirs)
            mkdir(ParentDir,[dirs{dirindex} '_right']);
%             mkdir(ParentDir,[dirs{dirindex} '_left']);
%             rmdir([ParentDir filesep 'FFA_right']);
%         rmdir([ParentDir filesep 'FFA_left']);
        end
        mkdir(ParentDir,'Excluded');
    end
end

helpdlg('Done!','Creating ROI directories');

end