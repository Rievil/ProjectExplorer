
%% Testing of categorical arrays and their sorting
pr=ProjectExplorer;
%%
results = GetCurrentData(pr);
%%
T=pr.PR.Projects.TotalTable.Zedo(1,1).Data.Records(1).ConDetector;
x=T{:,4};
y=T{:,9};
z=T{:,10};
arr=[x,y,z];
%%
E=results(1).Type.Data.Events;
x=E{:,16};

Time=E{:,7};
PTime=results(2).Type.Data.Time;
y=interp1(results(2).Type.Data.Time,results(2).Type.Data.Strength,Time);
z=E{:,13};
size=log(E{:,11}*10e+17);
color=E{:,13};
scatter3(x,y,z,size,color,'filled');
arr=[x,y,z,size];
%%
figure(1);
hold on;
s=E{:,11}*10e+14;

scatter3(x,y,z,s,'filled');
%%
s=log(E{:,11}*10e+15).^2;
plot(s);
%%
filename='K:\ZEDO_DATA_Export\200527_Melichar_THIS\br121\br121.65.1a-ae-signal-00005.bin'
[hit]=ReadHit('K:\ZEDO_DATA_Export\200527_Melichar_THIS\br121\','br121.65.1a-ae-signal-00005.bin')