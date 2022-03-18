function [estimateLabel,trueLabel,inTrainingSet,time2seizure] = sm_getSeizurePred(fname,seizFil,rusTree,trainingTime,ops)

% this function takes the classifier in rusTree and applease the feature
% space specified in ops and classified ever moment in time for the file
% (fname)
%%

Fs =ops.Fs;
bins = ops.bins;
nCh_featureFil = ops.nCh_featureFile;

%%

%get seizure times
TSname1 = 'Seizure starts'; % TS name in file.
TSname2 = 'ends';
TSdata = readtable(seizFil);
TSdata = table2cell(TSdata);
seizure_start = cell2mat(TSdata(cellfun(@any,regexp(TSdata(:,6),TSname1)),4));
seizure_end = cell2mat(TSdata(cellfun(@any,regexp(TSdata(:,6),TSname2)),4));

%%

% get true time to seizure

powerFil = [fname '_1.dat'];
s = dir(powerFil);
dur = s.bytes/nCh_featureFil/Fs/2;



ts = 0: (dur-ops.durFeat);
time2seizure = ts;
kp = true(size(ts));
for i = 1:length(seizure_start)
    time2seizure(kp&ts<seizure_start(i)) = ts(kp&ts<seizure_start(i)) - seizure_start(i);
    time2seizure(kp& ts>seizure_start(i) & ts<seizure_end(i)) = .5;
    time2seizure(kp& ts>seizure_end(i) & ts<seizure_end(i)+600) = 1.5;
    
    
    kp(ts<seizure_start(i) | ...
        (ts>seizure_start(i) & ts<seizure_end(i)) | ...
        (ts>seizure_end(i) & ts<seizure_end(i)+600)) = false;
end

[~,trueLabel] = histc(time2seizure,[-inf -(bins) 0 1 2]);
inTrainingSet = histc(trainingTime,ts)>0;
%%


%get prediction
estimateLabel =[];
dat1 =[];
for i = ts
    
    
    
    
    tim = i;
    features = ops.features(fname,tim,ops);
    
    
    dat1 = [dat1;features];
    
    if mod(i,100)== 0
        estimateLabel = [estimateLabel;predict(rusTree,dat1)];
        dat1 =[];
    elseif i > (dur- mod(dur,100))
        estimateLabel = [estimateLabel;predict(rusTree,dat1)];
         dat1 =[];
    end
    
end




end





