%load DLC position
cd R:\McKenzieLab\DonaldsonT\DA2h1-210803-113837
tracking_data = h5read('DA_animals-210702-122707_DA2h1-210803-113837_Cam1DLC_mobnet_100_GRAB_catAug5shuffle1_100000.h5','/df_with_missing/table');
%%

cd R:\McKenzieLab\DonaldsonT\DA2h1-210803-120056

tracking_data = h5read('DA_animals-210702-122707_DA2h1-210803-120056_Cam1DLC_mobnet_100_GRAB_catAug5shuffle1_100000.h5','/df_with_missing/table');
%%

%load fiber data

fiber_data = TDTbin2mat(pwd);

skip = 2e3;
fs = fiber_data.streams.x465A.fs;
ts_data = (1:length(fiber_data.streams.x465A.data))/fs;
a = polyfit(ts_data(skip:end),fiber_data.streams.x465A.data(skip:end),2);

data_hat = polyval(a,ts_data);

%baseline substract

data_465= fiber_data.streams.x465A.data - data_hat;



a = polyfit(ts_data(skip:end),fiber_data.streams.x405A.data(skip:end),2);

data_hat = polyval(a,ts_data);

%baseline substract

data_405= fiber_data.streams.x405A.data - data_hat;




%without isobestic
%data_465 = (data_465-median(data_465(skip:end)))./median(data_465(skip:end));
%data_405 = (data_405-median(data_405(skip:end)))./median(data_405(skip:end));

a = polyfit(data_405(skip:end),data_465(skip:end),1);
data_405_rescale = polyval(a,data_405);

data_NE = data_465;%-data_405_rescale;

%%
%check this!

ts_video = fiber_data.epocs.Cam1.onset;


data_NE_aligned = interp1(ts_data',data_NE',ts_video);

data_NE_aligned = data_NE_aligned';
%%

left_ear = tracking_data.values_block_0(1:2,1:length(ts_video))';
 [t,x,y,vx,vy,ax,ay] = KalmanVel(left_ear(:,1),left_ear(:,2),ts_video,2);
 
 %%
 vel = (vx.^2+vy.^2).^.5; 
 acc = (ax.^2+ay.^2).^.5;
 
 b = find(diff(acc>8)>0);
 
 
 
ix = repmat(b(:),1,10001) + repmat(-5000:5000,length(b),1);

kp = [diff(ts_video(b))>5;true] & all(ix>0,2);
ix = ix(kp,:);

d = double(data_NE(ix));
d = nanzscore(d,[],2);

figure
%plot((-5000:5000)/fs,nanmedian(d))

hold on
plot((-5000:5000)/fs,nanmean(d),'k')

