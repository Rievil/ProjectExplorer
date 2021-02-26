username = "PEClient";
password = "45@&25#!#HezkyK_n";
conn = database('Project explorer Client',username,password);
%% Create projects

execute(conn,'DELETE FROM ProjectList WHERE ID>0');
names=["CETRIS";"HANKA"];
desc=["M��en� cementot��skov�ch desek";...
    "M��en� lomov� energie na alkalicky aktivovan�ch tr�me�c�ch o rozm�rech 40x40x160 mm"];
startdate=[datetime(2019,1,1,'Format','yyyy-MM-dd hh:mm:ss');datetime(2020,1,1,'Format','yyyy-MM-dd hh:mm:ss')];
enddate=[datetime(2021,12,31,'Format','yyyy-MM-dd hh:mm:ss');datetime(2021,12,31,'Format','yyyy-MM-dd hh:mm:ss')];
lastchange=[datetime(now(),'ConvertFrom','datenum','Format','yyyy-MM-dd hh:mm:ss');datetime(now(),'ConvertFrom','datenum','Format','yyyy-MM-dd hh:mm:ss')];

datain=table(names,desc,...
        startdate,enddate,lastchange,'VariableNames',...
        {'ProjectName','Description','ProjectStart','ProjectEnd','LastChange'});
    

sqlwrite(conn,'ProjectList',datain)
%% Create random experiments for each project

selectquery = 'SELECT * FROM ProjectList';
ProjectList = select(conn,selectquery);

IDs=ProjectList.ID;
datain=table;
for i=IDs'
    
    for j=1:rand(5)*10
        data=table(i,sprintf("Experiment %d",j),"Popis",'VariableNames',...
            {'ProjectID','Name','Description'});
        datain=[datain; data];
    end
end

sqlwrite(conn,'Experiments',datain)

%%

selectquery = 'SELECT * FROM Experiments';
Experiments = select(conn,selectquery);

%% For each experiment create set of measurements

IDs=Experiments.ID;
clear datain;
datain=table;

for i=IDs'
    
    for j=1:rand(20)*10
        data=table(i,datetime(2021,12,31,'Format','yyyy-MM-dd hh:mm:ss'),...
            int16(rand(1)*100),string([cd '\Master\']),"Popis m��en� v dan�m dni",'VariableNames',...
            {'ExpID','Datetime','SpecCount','MasterFolder','Description'});
        datain=[datain; data];
    end
end
%%
sqlwrite(conn,'Meas',datain)
%%
selectquery = 'SELECT * FROM Meas';
Meas = select(conn,selectquery);
%%
close(conn);
