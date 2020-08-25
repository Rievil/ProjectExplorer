clear all
dbfile='E:\Google Drive\SQLite\DB.db';
%dbfile='https://drive.google.com/file/d/1HjSdz46puVfOR9CXkGsJ4pBnN69Ghp2a/view?usp=sharing';
conn = sqlite(dbfile)
%%
sqlquery = 'SELECT * FROM TestTable WHERE TestTable.ID>0 ';
results = fetch(conn,sqlquery)
%%
close(conn);
%%
filename='E:\Google Drive\Škola\Mìøení\2017\D\1000\D46-UB0-SIGNAL.csv';
data=dlmread(filename,';',10,0);
%%
conn = sqlite(dbfile)
createInventoryTable = ['create table Signal2 (Time NUMERIC, Signal NUMERIC)'];
exec(conn,createInventoryTable);
%%
colnames = {'Time','Signal'};
insert(conn,'Signal2',colnames, ...
    {data(:,1),data(:,2)})

close(conn);
%%
conn = sqlite(dbfile)
sqlquery = 'SELECT * FROM Signal ';
results = fetch(conn,sqlquery);
close(conn);
%%