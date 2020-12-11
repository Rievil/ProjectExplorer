
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
%% Connection to database

%ProjectExplorerClient

conn = database('ProjectExplorerDB','ProjectExplorerClient','18@25_LL35_!QR');

%Set query to execute on the database
query = ['SELECT * ' ...
    'FROM master.dbo.spt_fallback_dev'];

data = fetch(conn,query);
close(conn)