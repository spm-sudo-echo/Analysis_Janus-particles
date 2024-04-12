rawdata=csvread("MSDdata.csv",1,0);
time=rawdata(:,1);
msd=rawdata(:,2);
start = 1;
finish = 25;
time_cut=time(start:finish);
msd_cut=msd(start:finish);