%find seizures with files that have been converted to edf

% addpath('/Users/steve/Documents/code/unm/McKenzieLab/helpers/getAllExtFiles.m');
% addpath('/Users/steve/Documents/code/unm/buzcode/externalPackages/awt_freqlist.m');
% addpath('/Users/steve/Documents/code/unm/McKenzieLab/Dat_helpers/sm_MergeDats.m');
addpath('/Users/steve/Documents/code/unm/McKenzieLab/utils'); % moved above commented imports to this new utils folder

FilePath = '/Users/steve/Documents/code/unm/McKenzieLab/data/h24_data/raw';

% fileList = dir('/Users/steve/Documents/code/unm/data_mouse/*.edf');
% disp(fileList.name);


fils_edf = getAllExtFiles(FilePath,'edf',1);
fils_txt = getAllExtFiles(FilePath,'txt',1);
[~,b_edf] = cellfun(@fileparts,fils_edf,'uni',0);       % what does this do? 
[~,b_txt] = cellfun(@fileparts,fils_txt,'uni',0);       % what does this do?

goodFils = intersect(b_txt,b_edf);

seizure_fils = fils_txt(ismember(b_txt,goodFils));

edf_fils = fils_edf(ismember(b_edf,goodFils));



%%


% % masterDir = 'E:\data\IHKA';
% masterDir = '/Users/steve/Documents/code/unm/McKenzieLab/data/IHKA_output'; 

fprintf("length fils_edf = %i\n", length(fils_edf));


%%% Steve code for testing purposes

% check if file exists
f_edf = fils_edf{1};  % just pick the one

for j = 1:4 % iterate through each channel
    fprintf("\nRunning sm_getPowerPerChannel for channel %i\n", j);
    sm_getPowerPerChannel(f_edf,j)
end

%%% McKenzie code
% for i = 74:length(fils_edf)                             % why start at 74?
%     
%     % check if file exists
%     fileOut = regexprep(fils_edf{i},' ','_');
%     
%     [a,basename] = fileparts(fileOut);                  % define output directory
%     dirOut = [masterDir filesep basename ];
%     if ~exist(dirOut)
%         
%         for j = 1:4                                     % four channels, mouse data
%             sm_getPowerPerChannel(fils_edf{i},j)
%         end
%     end
%     i
% end



