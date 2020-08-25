filename='H:\Google drive\GitHub\Matlab\DataTypes\TrainData\PenTest.xls';
%%
obj = DTab(filename);
%%
Data=GetData(obj);

%%
PressData=DAsymTab('H:\Google drive\GitHub\Matlab\DataTypes\TrainData\19.09.13. - F-H CH50, 100, ohyb_cas sila.xls',2);
%%
plot(AsymTab.Data{1, 2}(:,1),AsymTab.Data{1, 2}(:,2));
%%
%%
conn = database ('jdbc:mysql://localhost/vutprojects','Richard','5tr0ngPa55w@rd');
curs = exec(conn,'select *from dtm');
