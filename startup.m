han=ExplorerObj(1);

%%

load('G:\Můj disk\Škola\Sandbox\P_1_Mechanics\main.mat');

%%
plt=han.Core.ProjectOverview.ProjectList.ProjectObj.Plotter;
Tout=plt.GetSampleData(1,'Test');


x=Tout.Deff_Deff{1};
y=Tout.Force_Force{1};

plot(x,y);