vendor = "Microsoft SQL Server";
opts = configureJDBCDataSource('Vendor',vendor);
%% Create new connection and save to registr of client pc
username = "PEClient";
password = "45@&25#!#HezkyK_n";
%%
driverfile=[cd '\Databases\sqljdbc4.jar'];

vendor = "Microsoft SQL Server";

opts = configureJDBCDataSource('Vendor',vendor);

opts = setConnectionOptions(opts, ...
    'DataSourceName','Project explorer Client', ...
    'Server','147.229.25.228', ...
    'PortNumber',1433,...
    'DatabaseName','Projects',...
    'JDBCDriverLocation',driverfile, ...
    'AuthType','Server');

status = testConnection(opts,username,password);
saveAsJDBCDataSource(opts);
%%

conn = database('Project explorer Client',username,password);

%%
tic;
conn = database('Project explorer Client',username,password);

selectquery = 'SELECT * FROM ProjectList';
fetchdata = select(conn,selectquery);
elapsedtime=toc
%%
tic;
conn = database('Project explorer Client',username,password);

selectquery = 'SELECT * FROM ProjectList';
fetchdata = select(conn,selectquery);
elapsedtime=toc
%%
%Inner join
selectquery=['SELECT ep.ID, pl.ID, pl.ProjectName, ep.Name, ep.Description ',...
            'FROM Experiments ep '...
            'INNER JOIN ProjectList pl ',...
            'ON ep.ProjectID = pl.ID '];
        
fetchdata = select(conn,selectquery);

%%
close(conn);
%%
tic;
testdata=table;
for i=1:5
    data=table("CETRIS","Popis projektu žluouèký kùò",...
        datetime(2021,2,25),datetime(2021,2,25),datetime(2021,2,25),'VariableNames',...
        {'ProjectName','Description','ProjectStart','ProjectEnd','LastChange'});
    testdata=[testdata; data];
end
elapsedtime=toc
%%
tic;
conn = database('Project explorer Client',username,password);
sqlwrite(conn,'ProjectList',testdata)
elapsedtime=toc
%%
rtf="Zkouška formátovaného textu\nkterý má více øádkù";
conn = database('Project explorer Client',username,password);
data=table(2,"CETRIS",rtf,...
    'VariableNames',...
    {'ProjectID','Name','Description'});
sqlwrite(conn,'Experiments',data);
% close(conn);
%%
sqlquery = 'DELETE FROM ProjectList WHERE ID>0';

%%
sqlquery = 'UPDATE ProjectList SET ID = 1 WHERE ID = 20';
execute(conn,sqlquery);
%%
close(conn);