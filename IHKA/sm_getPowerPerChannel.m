function sm_getPowerPerChannel(filename,channel,varargin)
% function calculates features from a single channel of an edf files and
% saves those features as a flat binary (*.dat)

% Required:
%   filename  = *.edf file containing data
%   channel = which channel to read from edf file


% Optional inputs
%   Fs = sampling rate of edf file (default = 2000hz)
%   numFreq = number of wavelet bands to consider (default = 20)
%   lowF = lowest frequency to consider (default = 0.5)
%   hiF = highest frequency to consider (default = 200)
%   spacing = log (defualt)/linear spacing of frequency decomposition
%   zscorePower = should wavelet power be zscored? (default = true)
%   fileOut = filename of output file (defualt = filename_channel w/o spaces)
%   dirOut = output directory for feature files
%   features = features to consider ('waveletPower','waveletPhase')

% DEPENDENCIES: edfread,sm_MergeDats,awt_freqlist,getAllExtFiles
%%
% parse inputs

% print statements for the user
fprintf("Function sm_getPowerPerChannel called with variables\nfilename=%s\nchannel=%i",filename,channel);

p = inputParser;


addParameter(p,'Fs',2000,@isnumeric)
addParameter(p,'numFreq',20,@isnumeric)
addParameter(p,'lowF',0.5,@isnumeric)
addParameter(p,'hiF',200,@isnumeric)
addParameter(p,'spacing','log',@ischar)
addParameter(p,'zscorePower',true,@islogical)
addParameter(p,'fileOut',[],@ischar)
addParameter(p,'dirOut',[],@ischar)
addParameter(p,'features',{'waveletPower','waveletPhase'},@iscell)


parse(p,varargin{:})


Fs = p.Results.Fs;
numFreq = p.Results.numFreq;
lowF = p.Results.lowF;
hiF = p.Results.hiF;
spacing = p.Results.spacing;
zscorePower = p.Results.zscorePower;
fileOut =  p.Results.fileOut;
dirOut =  p.Results.dirOut;
features =  p.Results.features;

%%

% define input/output files and directories

% why do we remove spaces?
if isempty(fileOut)
    fileOut = regexprep(filename,' ','_'); % remove spaces, why???
end


if isempty(dirOut)
    % masterDir is the directory where the .dat files are stored; previously 'E:\data\IHKA'
    masterDir = '/Users/steve/Documents/code/unm/McKenzieLab/data/h24_data/feature';
    [~,basename] = fileparts(fileOut);          % define output directory
    dirOut = [masterDir filesep basename ]; 
end



if ~exist(dirOut)
    mkdir(dirOut)
end

% temporary subdirout; Todo: rename to 'cache'
fnameOutb = [dirOut filesep basename filesep ]; % Steve: this naming convention is a bit confusing because of repetition, also it would be good to be clear about what is only temporarily being saved (i.e. to put files into a cache folder) But this can be done in python.
fnameOutb = regexprep(fnameOutb,' ','_'); % steve wrote this... might be wrong

if ~exist(fnameOutb)
    mkdir(fnameOutb)
end

%%

% define feature space

if strcmpi(spacing,'log')
    freqs = logspace(log10(lowF),log10(hiF),numFreq);
elseif strcmpi(spacing,'linear')
    freqs = linspace(lowF,hiF,numFreq);
else
    error('frequency spacing must be: log/linear')
end


%%

%read data
fprintf("\nReading .edf data file %s" , filename); % this takes a while 
data = edfread(filename);

ch = data{:,channel};
clear data
ch = cell2mat(ch);


%%

% scale factors to maximize range for int16
reScalePhase = 1000; % (next time change here to 32767/pi ~ 10,0000)
reScalePower = 1000; % 32767/maxPower < 1,000

featureList = [];


lsdir_fnameOutb = arrayfun(@(x) x.name , dir(fnameOutb) , 'UniformOutput' , false); % this is a list of all the cached files
disp("Here is the contents of the cache so far");       % trace
disp(lsdir_fnameOutb);                                  % trace
disp("Now Looping through frequencies.");               % trace
% loop over frequencies
for i = 1:length(freqs) 
    fprintf("\n\nloop i=%i",i);                             % trace
    
    i_out =  sprintf( '%03d', i ); 
    
    fnameOut1 = [fnameOutb basename '_A' num2str(i_out) '.dat'];
    splitstr = split(fnameOut1,"/"); % only on mac, this is a hack
    fnameOut1OnlyFile = splitstr{length(splitstr)};
    fnameOut2 = [fnameOutb basename '_P' num2str(i_out) '.dat'];
    splitstr = split(fnameOut2,"/"); % hack
    fnameOut2OnlyFile = splitstr{length(splitstr)};

    % if the files have already been computed, there's no need to
    % re-compute them (steve mac, was taking long time for everything to come together)
    if ~ismember(fnameOut1OnlyFile , lsdir_fnameOutb) || ~ismember(fnameOut2OnlyFile , lsdir_fnameOutb)
        fprintf("\nComputing wavelet filter (convolution) for f=%d",freqs(i));                          
        % wavelet decomposition
        signal_filtered = awt_freqlist(ch,Fs,freqs(i));
            
        if ismember('waveletPower',features) 
            
            % temp file for power
            % fnameOut1 = [fnameOutb basename '_A' num2str(i_out) '.dat'];
            %%% moved above line to before if statement
            fidO1 = fopen(fnameOut1,'w');
            
            % calculate power
            power_filtered = abs(signal_filtered);
            
            % normalize power
            if zscorePower
                power_filtered = zscore(power_filtered);
            end
            
            % rescale for int16
            power_filtered = power_filtered * reScalePower;
            
            
            %write to disk
            fwrite(fidO1,power_filtered(:),'int16');
            fclose(fidO1);
            
            
        end
        
        
        if ismember('waveletPhase',features) 
            
            %temp file for phase
            % fnameOut2 = [fnameOutb basename '_P' num2str(i_out) '.dat']; 
            %%% moved above line to before if statement
            fidO2 = fopen(fnameOut2,'w');
            
            
            % calculate phase
            ph = atan2(real(signal_filtered),imag(signal_filtered));
            
            % rescale to int16
            ph = ph * reScalePhase;
            
            % write to disk
            fwrite(fidO2,ph(:),'int16');
            fclose(fidO2);
        end
        
        
    else 
        disp("Skipping");
        disp(fnameOut1);
        disp("and");
        disp(fnameOut2);
        disp("Files already exist, no need to compute wavelet convolution.");
    end

    featureList_t = [];
    if ismember('waveletPower',features) % for testing, shld always be true
        if zscorePower
            featureList_t = [' ZPower:' num2str(round(10*freqs(i))/10)];
        else
            featureList_t = [' Power:' num2str(round(10*freqs(i))/10)];
        end
    end
    if ismember('waveletPhase',features) % for testing, shld always be true
        featureList_t = [featureList_t '  Phase:' num2str(round(10*freqs(i))/10)]; 
    end
    featureList = [featureList featureList_t];
end
%%
% save time series in the dat file

fnameOut = [fnameOutb basename '_000.dat'];
fidO = fopen(fnameOut,'w');
fwrite(fidO,ch(:),'int16');
fclose(fidO);

featureList = ['ch:' num2str(channel) ' ' featureList];

%%

% resave all frequency bands in single dat file
fils = getAllExtFiles(fnameOutb,'dat',0);

% sort temp dat files by frequency
[~,b]=  sort(cellfun(@(a) str2num(a(end-6:end-4)),fils));
fils = fils(b);

fnameOut_merged = [dirOut filesep basename '_' num2str(channel) '.dat'];

% save merged file with all features and with time series
sm_MergeDats(fils,fnameOut_merged)

fnameOutfeature = [dirOut filesep basename '_' num2str(channel) '.mat'];

% save feature list
save(fnameOutfeature,'featureList')



% delete all temp tiles
for i = 1:length(fils)
    delete(fils{i})
    
end

end
