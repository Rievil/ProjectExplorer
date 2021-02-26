username = "PEClient";
password = "45@&25#!#HezkyK_n";
conn = database('Project explorer Client',username,password);
%% Create projects

execute(conn,'DELETE FROM ProjectList WHERE ID>0');
names=["CETRIS";"HANKA"];
desc=["M��en� cementot��skov�ch desek";...
    "M��en� lomov� energie na alkalicky aktivovan�ch tr�me�c�ch o rozm�rech 40x40x160 mm"];
startdate=[datetime(2019,1,1,'Format','yyyy-mm-dd hh:mm:ss');datetime(2020,1,1,'Format','yyyy-mm-dd hh:mm:ss')];
enddate=[datetime(2021,12,31,'Format','yyyy-mm-dd hh:mm:ss');datetime(2021,12,31,'Format','yyyy-mm-dd hh:mm:ss')];
lastchange=[datetime(now(),'ConvertFrom','datenum','Format','yyyy-mm-dd hh:mm:ss');datetime(now(),'ConvertFrom','datenum','Format','yyyy-mm-dd hh:mm:ss')];

datain=table(names,desc,...
        startdate,enddate,lastchange,'VariableNames',...
        {'ProjectName','Description','ProjectStart','ProjectEnd','LastChange'});
    

sqlwrite(conn,'ProjectList',datain)
