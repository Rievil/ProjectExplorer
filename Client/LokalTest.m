lok=Tout.(1){1,1};
%%
b=ExplorerAppStartMain;
%%
plotter=b.Core.ProjectOverview.Projects(1).Plotter;
%%
Tout=plotter.GetSampleData(3,1);
%%

cardname=string(lok.SensorOrder(1,:));
hitid=lok.IDSignal(1,:);

            
Time=table([],[],[],[],...
    'VariableNames',{'EventID','Sensor','Begin','End'});
figure;
hold on;
for i=1:size(lok.SensorOrder,1)
    order=lok.SensorOrder(i,:);
    SignalId=lok.IDSignal(i,:);

    for j=1:numel(order)
        TargetCard=replace(string(order{j})," ","");
        cards=string({lok.TS(:).Label});
        Idx=find(cards==TargetCard);

        HitID=SignalId(j);
        Row=find(lok.TS(Idx).SensorID==HitID);
    
        time(Idx)=lok.TS(Idx).Begin(Row,1);
        x(Idx)=lok.TS(Idx).X;
        y(Idx)=0;
        vzd(Idx)=lok.Speed*time(Idx);
%         Time(j,1)=lok.TS(Idx).Begin(Row,1);
%         Time(j,2)=lok.TS(Idx).End(Row,1);

    end
    timediff=diff(time)*lok.Speed;
    vzdx=diff(x);
    restlen(i,1)=x(1)+(vzdx-timediff)/2;


end

%%

x1=10;
y1=10;
r1=20;

x2=30;
y2=30;
r2=5;

[xout,yout] = circcirc(x1,y1,r1,x2,y2,r2);

figure;
hold on;

p = nsidedpoly(1000, 'Center', [x1,y1], 'Radius', r1);
p2 = nsidedpoly(1000, 'Center', [x2,y2], 'Radius', r2);

plot(p, 'FaceColor', 'r')
plot(p2, 'FaceColor', 'r');

scatter(xout,yout,'ok','filled');