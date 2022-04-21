% this is the top level function for calculating feature space for all
% sessions. For computational efficacy, features are only calculated for a
% subset of times, a fixed percentage per seizure for each time bin

% import utility functions
addpath('/Users/steve/Documents/code/unm/McKenzieLab/utils'); 
% Steve: will this also bring .m files into the scope of functions called in here
% Steve: (e.g. in sm_PredictIHKA_calcFeatures, which requires LoadBinary)
% Steve: The answer is YES! (determined experimentally)

% MakeAll_getPowerPerChannel must have been called on all raw data files to
% prepare feature files


% % path where raw data is stored with seizure labels
% ops.RawDataPath = 'R:\IHKA_Scharfman\IHKA data';  % is this the .dat or the .edf files?
% ops.FeaturePath = {'F:\data1\IHKA','E:\data\IHKA'};     % why are there
% two paths here? (because too much data) 
% FeaturePath is where all the features and .dat files are stored
% ops.FeatureFileOutput = 'E:\data\IHKA\features.mat';    % where to store the features

ops.RawDataPath = '/Users/steve/Documents/code/unm/McKenzieLab/data/h24_data/raw'; % best guess...
ops.FeaturePath = {'/Users/steve/Documents/code/unm/McKenzieLab/data/h24_data/feature'}; % this is what 
% we replaced E:\data\IHKA with in sm_getPowerPerChannel.m (there it was called 'masterDir')
ops.FeatureFileOutput = '/Users/steve/Documents/code/unm/McKenzieLab/data/h24_data/feature/features.mat';

% define time windows around to predict (s)

ops.bins = [ 3*3600 3600 600 10];


% define % of time to take within each time bin
%   1-3hrs:     5%
%   10min-1hr:  5%
%   10s-10min:  20%
%   0-10s:      100%
%   seizure:    100%
%   post ictal: 20%

ops.pct = [.05 .05 .2 1 1 .2];

ops.nBins = length(ops.pct);

% define postIctal time, 600s after seizure offset
ops.timPost = 600;

% info for full feature space
ops.Fs  = 2000; % sampling rate is 2000 Hz
ops.reScalePhase = 1000;  %
ops.reScalePower = 1000;  % 32767/maxPower < 1,000


% frequency bands for coherence
% freq bands for coherence. must match sm_getPowerPerChannel
ops.freqs = logspace(log10(.5),log10(200),20);

% frequency selection for phase/amplitude (must match index in getPowerPerChannel)
ops.amp_idx = 15:20;
ops.ph_idx = 1:10;

ops.durFeat = 5; % 5s feature bins

%channel for phase amplitude coupling
%ch1 = ipsi HPC
%ch2 = ipsi cortex
%ch3 = contra HPC
%ch4 = contral cortex

ops.ch_phaseAmp =2;

%information about feature file (getPowerPerChannel)
ops.nCh_featureFile = 41; %20 power, 20 phase, 1 time series
ops.nCh_raw = 4; % N = 4 eeg channels

ops.features = @sm_PredictIHKA_calcFeatures;




%DEPENDENCIES
% getAllExtFiles, sm_PredictIHKA_calcFeatures,sm_getPowerPerChannel,sm_MakeAll_getPowerPerChannel,
% getXPctTim, circ_corrcl
% Steve: circ_corrcl is used in sm_PredictIHKA_calcFeatures.m

%%




% find all edf files and txt files (with seizure labels)
fils_edf = getAllExtFiles(ops.RawDataPath,'edf',1);
fils_txt = getAllExtFiles(ops.RawDataPath,'txt',1);

% find all edf files with annotations
[~,b_edf] = cellfun(@fileparts,fils_edf,'uni',0);
[~,b_txt] = cellfun(@fileparts,fils_txt,'uni',0);
goodFils = intersect(b_txt,b_edf);
seizure_fils = fils_txt(ismember(b_txt,goodFils));
edf_fils = fils_edf(ismember(b_edf,goodFils));




%%

sessions = [];

% find feature files that match annotation file
% Steve: this code is a bit hard to read... 
%
% The following code produces `sessions` which is a list of tuples (x,y)
% where x is the path/to/24_hour_data.txt
% and   y is the path/to/directory/of/24_hour_data_dat_file
% (y doesn't have the extension)
%
for j = 1:length(ops.FeaturePath)           % cause large data volumes, .dat data was stored in multiple (two) places
    d = dir(ops.FeaturePath{j});            % d is a directory object, directory with sessions (i.e. 24h .dat files)
    d = {d(cell2mat({d.isdir})).name}';     % not sure... probably don't need to exactly understand this
    [a,b] = fileparts(seizure_fils);        % fileparts returns [path,name,extension]
    seizure_fils_txt = regexprep(b,' ','_');% probably some matlab convention for filename string comparison
    [~,b] = ismember(seizure_fils_txt,d);   % check if the seizure file 
    kp = b>0;                               % kp is a bool, true if ismember
    b(~kp) =[];                             % not sure...
    seizure_filst = seizure_fils(kp);       % 
    
    
    % save list of file names for the paired annotation/feature files
    
    sessions = [sessions;seizure_filst cellfun(@(a) [ops.FeaturePath{j} filesep a filesep a],d(b),'uni',0)];

end

nSessions = size(sessions,1);


%%

warning off

% Get all relevant timepoints around the seizure start and end

% TS name in file.
TSname1 = 'Seizure starts';
TSname2 = 'ends';


% loop over all seizures (i.e. "good" 24h recording sessions)
for i= 1:size(sessions,1)
    
    % tims{i} = [NxM] , N = seizure number, M = timestamp for bin of interest length(bins)+2
    % Steve: hmm, it seems that the code doesn't run if there are no
    %        seizures... so we need a sample with seizures 
    tims{i} = [];
    
    
    TSdata = readtable(sessions{i,1});
    TSdata = table2cell(TSdata);
    
    seizure_start = cell2mat(TSdata(cellfun(@any,regexp(TSdata(:,6),TSname1)),4));
    seizure_end = cell2mat(TSdata(cellfun(@any,regexp(TSdata(:,6),TSname2)),4));
    
    
    %loop over seizures per subject
    for j = 1:length(seizure_start)
        
        %bins around seizure
        tmp = [seizure_start(j)-ops.bins seizure_start(j) seizure_end(j) seizure_end(j)+ops.timPost];
        
        %if seizure is early, delete time
        tmp(tmp<0) = nan;
        
        
        %if bin overlaps with prior seizure, delete
        if j>1
            tmp(tmp<seizure_start(j-1)) = nan;
        end
        
        % if bin overlaps with next seizure, delete
        if j<length(seizure_start)
            tmp(tmp>seizure_start(j+1)) = nan;
        end
        
        %save time bins per seizure per subject
        tims{i} = [tims{i};tmp];
        
        
    end
    
end

%%

% clear feature variable that will be used to aggregate across sesions
clear sz


for k = 1:ops.nBins
    
    dat{k} =[];
    sesID{k} = [];
end

%%


%loop over number of sessions
for i = 1:nSessions                         % just one session for test
    fname = sessions{i,2};                  % path + base of fname of the four channels .dat files
    
    %loop of time bins
    for k = 1:ops.nBins
        fprintf("i=%i, k=%i\n", i,k);       % test; prints: i=1 k=1
        fprintf("tims{i}=%f\n", tims{i});   % test; nothing prints here
        fprintf("%f\n", ops.pct(k));        % test; 0.050000
        fprintf("%f", tims{i}(:,k:k+1));    % this is where the bug is
        
        %choose random subset (pct) of samples within each session to train
        %model
        
        sz{k} = getXPctTim(tims{i}(:,k:k+1), ops.pct(k),1); % what is this variable? (sz?)    
        % for each seizure it's grabbing the moments at the timestamps
        % the getXPctTim gets ops.pct(k) percent of the time windows before
        % the seizure

        % last param of getXPctTim is size of windows in seconds

        
        %loop over all timepoints for each session for each bin
        for ev = 1:numel(sz{k})
            
            %find duration of the file
            powerFil = [fname '_1.dat'];
            s = dir(powerFil);
            dur = s.bytes/ops.nCh_featureFile/ops.Fs/2;
            
            tim = sz{k}(ev)-ops.durFeat;
            %make sure the event does not exceed duration of recording
            if ~isnan(tim) && (dur-tim)>ops.durFeat
                
                try
                    % get features (some pre calculated, some calculated on the fly)
                    features = ops.features(fname,tim,ops);
                    
                    % save all features for each time bin
                    dat{k} = [dat{k};features];
                    
                    % keep track of which session matches which feature
                    sesID{k} = [sesID{k}; i tim];
                    fprintf("\nHurray %d", ev)
                    %disp(features);
                catch
                    disp(fname)
                    disp(['file length: ' num2str(dur) ' time of read:' num2str(tim)])
                end 
            end
        end
    end
    
     %save the full feature space
     save(ops.FeatureFileOutput,'dat','sesID','sessions','ops','-v7.3')
end



