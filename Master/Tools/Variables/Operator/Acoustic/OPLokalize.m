classdef OPLokalize < Operator
    %INTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Position;
        LocalType=1; %1: 1D, 2: 2D, 3: 3D
        SpeedIdx=1;
        SensorOrderIdx=1;
        IDSignalIdx=1;
        SensorTable;
        SensorTableIdx;
        UISensorTable;
        Local;
    end

    
    methods
        function obj = OPLokalize(~)
            obj@Operator;
            obj.Name='OPLokalize';
            obj.Title='AE localization';
            
            
            
            obj.Description={'Select type of lokalization: 1D | 2D | 3D';
                'select x,y & z coordinates for sensor position';
                'select sensor order variable';
                'select signals IDs';
                'select time variable for each sensor';
                'select measured sound velocity variable'};
        end
        
        function CheckChange(obj)
            varList=sort(obj.GetVarList);
            currVarList=sort(string(categories(obj.SensorTable{1,2})));
            
            samesize=numel(varList)==numel(currVarList);
            if samesize==true
                b=strcmp(varList,currVarList);
                if sum(b)==numel(varList)
                    %vše je při starém
                else
                    %změna názvu proměné
                    ResetSensorTable(obj)
                end
            else
                %nová proměná | ubyla proměná
                ResetSensorTable(obj)
            end
        end
       
        function SetLocalType(obj,n)
            obj.LocalType=n;
        end
        
        function ResetSensorTable(obj)
            switch obj.LocalType
                case 1
                    T=[obj.GetSensorRow; obj.GetSensorRow];
                case 2
                    T=[obj.GetSensorRow; obj.GetSensorRow; obj.GetSensorRow];
                case 3
                    T=[obj.GetSensorRow; obj.GetSensorRow; obj.GetSensorRow; obj.GetSensorRow];
            end
            
%             obj.UISensorTable.Data=T;
            obj.SensorTable=T;
        end
        
        function AddSensor(obj)
            T=obj.GetSensorRow;
            obj.SensorTable=[obj.SensorTable; T];
            obj.UISensorTable.Data=obj.SensorTable;
        end
        
        function RemoveSensor(obj)
            if size(obj.SensorTable,1)>obj.LocalType+1
                obj.SensorTable(end,:)=[];
                obj.UISensorTable.Data=obj.SensorTable;
            end
        end
        
        
        
            
        function Ts=GetSensorRow(obj)
           varList=categorical(obj.GetVarList);
%            varList=categorical(obj.Parent.VarList);
           switch obj.LocalType
               case 1
                    Ts=table(varList(1),varList(1),varList(1),varList(1),'VariableNames',...
                        {'Sensor Label','SensorID','BeginTime','X pozition'});

               case 2
                    Ts=table(varList(1),varList(1),varList(1),varList(1),varList(1),'VariableNames',...
                        {'Sensor Label','SensorID','BeginTime','X pozition','Y pozition'});
               case 3
                    Ts=table(varList(1),varList(1),varList(1),varList(1),varList(1),varList(1),'VariableNames',...
                        {'Sensor Label','SensorID','BeginTime','X pozition','Y pozition','Z pozition'});
           end
        end
        
        function GetDeltas(obj)
            Loc=struct;
            Loc.Speed=obj.Parent.Output{obj.SpeedIdx};
            Loc.SensorOrder=obj.Parent.Output{obj.SensorOrderIdx};
            Loc.IDSignal=obj.Parent.Output{obj.IDSignalIdx};
            Loc.TS=GetSensorSpecific(obj);
            
            Loc.SensorCount=size(Loc.TS,2);
            
            
            
            cardname=string(Loc.SensorOrder(1,:));
            hitid=Loc.IDSignal(1,:);

            for i=1:size(Loc.SensorOrder,1)
                order=Loc.SensorOrder(i,:);
                SignalId=Loc.IDSignal(i,:);

                for j=1:numel(order)
                    TargetCard=replace(string(order{j})," ","");
                    cards=string({Loc.TS(:).Label});
                    Idx=find(cards==TargetCard);

                    HitID=SignalId(j);
                    Row=find(Loc.TS(Idx).SensorID==HitID);

                    time(Idx)=Loc.TS(Idx).BeginTime(Row,1);
                    x(Idx)=Loc.TS(Idx).X;
                    y(Idx)=0;
                    vzd(Idx)=Loc.Speed*time(Idx);

                end
                
                timediff=diff(time)*Loc.Speed;
                vzdx=diff(x);
                restlen(i,1)=x(1)+(vzdx-timediff)/2;
            end

            obj.Position=restlen;
 
        end

        
        function T=GetSensorSpecific(obj)
%             Names=obj.SensorTable.Properties.VariableNames;
            T=struct;
            switch obj.LocalType
                case 1
                    Names={'Label','SensorID','BeginTime','X'};
                case 2
                    Names={'Label','SensorID','BeginTime','X','Y'};
                case 3
                    Names={'Label','SensorID','BeginTime','X','Y','Z'};
            end
            
            for i=1:size(obj.SensorTable,1)
                for j=1:size(obj.SensorTable,2)
                    Var=obj.Parent.Output{obj.SensorTableIdx(i,j)};
                    T(i).(replace(Names{j},' ',''))=Var;
                end
            end
        end
        
        function MakeIdxTable(obj)
            varList=obj.GetVarList;
            obj.SensorTableIdx=zeros(size(obj.SensorTable,1),size(obj.SensorTable,2));
            for i=1:size(obj.SensorTable,1)
                for j=1:size(obj.SensorTable,2)
                    Idx=find(varList==string(obj.SensorTable{i,j}));
                    obj.SensorTableIdx(i,j)=Idx;
                end
            end
        end
    end
    
    
    
    methods %abstract
        function DrawGui(obj)
            varList=obj.GetVarList;
            
            g=uigridlayout(obj.Fig);
            g.RowHeight = {25,25,25,25,25,25,'1x','1x'};
            g.ColumnWidth = {'1x','1x',80,80};
            
            %Localizaiton type
            
            lbl1= uilabel(g,'Text','Select localization type:');
            lbl1.Layout.Row=1;
            lbl1.Layout.Column=1;
            
            
            drmx = uidropdown(g,'Items',{'1D','2D','3D'},'ItemsData',1:1:3,'Value',obj.LocalType,...
                'ValueChangedFcn',@obj.MSetLocalType);
            drmx.Layout.Row=1;
            drmx.Layout.Column=[2 3];
            
            %Sound velocity
            
            lbl1= uilabel(g,'Text','Sound velocity:');
            lbl1.Layout.Row=2;
            lbl1.Layout.Column=1;
            
            drspeed = uidropdown(g,'Items',varList,'ItemsData',1:1:numel(varList),'Value',obj.SpeedIdx,...
                'ValueChangedFcn',@obj.MSetSpeedIdx);
            drspeed.Layout.Row=2;
            drspeed.Layout.Column=[2 3];
            
            %Sensor order
            lbl1= uilabel(g,'Text','Sensor order:');
            lbl1.Layout.Row=3;
            lbl1.Layout.Column=1;
            
            drspeed = uidropdown(g,'Items',varList,'ItemsData',1:1:numel(varList),'Value',obj.SensorOrderIdx,...
                'ValueChangedFcn',@obj.MSetSensorOrder);
            drspeed.Layout.Row=3;
            drspeed.Layout.Column=[2 3];
            
            %Sensor signal IDs
            lbl1= uilabel(g,'Text','Signal IDs:');
            lbl1.Layout.Row=4;
            lbl1.Layout.Column=1;
            
            drspeed = uidropdown(g,'Items',varList,'ItemsData',1:1:numel(varList),'Value',obj.IDSignalIdx,...
                'ValueChangedFcn',@obj.MSetSignalID);
            drspeed.Layout.Row=4;
            drspeed.Layout.Column=[2 3];
            
            %Sensors properties
            lbl1= uilabel(g,'Text','Sensor properties:');
            lbl1.Layout.Row=6;
            lbl1.Layout.Column=1;
            
            
            if isempty(obj.SensorTable)
                obj.ResetSensorTable;
            else
                CheckChange(obj);
            end
            
            arr=logical(zeros(1,size(obj.SensorTable,2)));
            arr(:)=true;
            
            sentab = uitable(g,'Data',obj.SensorTable,'ColumnEditable',arr,...
                'CellEditCallback',@obj.MChangeSensorTable);
            sentab.Layout.Row=[7 8];
            sentab.Layout.Column=[1 4];
            
            obj.UISensorTable=sentab;
            
            but1=uibutton(g,'Text','Add sensor','ButtonPushedFcn',@obj.MAddSensor);
            but1.Layout.Row=6;
            but1.Layout.Column=3;
            
            but2=uibutton(g,'Text','Remove sensor','ButtonPushedFcn',@obj.MRemoveSensor);
            but2.Layout.Row=6;
            but2.Layout.Column=4;
            
        end
        
        
        function arr=RunTool(obj,~)
            MakeIdxTable(obj);
            GetDeltas(obj);
            obj.Output={obj.Position};
            switch obj.LocalType
                case 1
                    obj.Labels=["x"];
                case 2 
                    obj.Labels=["x","y"];
                case 3
                    obj.Labels=["x","y","z"];
            end
        end
        
        function stash=Pack(obj)
            stash=struct;
            stash.LocalType=obj.LocalType;
            stash.SpeedIdx=obj.SpeedIdx;
            stash.SensorOrderIdx=obj.SensorOrderIdx;
            stash.IDSignalIdx=obj.IDSignalIdx;
            stash.SensorTable=obj.SensorTable;
        end
        
        function Populate(obj,stash)
            obj.LocalType=stash.LocalType;
            obj.SpeedIdx=stash.SpeedIdx;
            obj.SensorOrderIdx=stash.SensorOrderIdx;
            obj.IDSignalIdx=stash.IDSignalIdx;
            obj.SensorTable=stash.SensorTable;
        end
    end
    
    methods %callbackes
        function MSetLocalType(obj,src,evnt)
                fig=OperLib.FindProp(obj.VarSmith,'UIFig');
                selection = uiconfirm(fig,['Changing the localization type will',...
                'add or remove Y or Z coordinates, continue?'],'Change localization type',...
                'Icon','warning');
            switch selection
                case 'OK'
                    obj.SetLocalType(src.Value);
                    obj.ResetSensorTable;
                    obj.UISensorTable.Data=obj.SensorTable;
                otherwise
                    src.Value=evnt.PreviousValue;
            end
        end
        
        function MAddSensor(obj,src,~)
            AddSensor(obj);
        end
        
        function MRemoveSensor(obj,src,~)
            RemoveSensor(obj);
        end
        
        function MChangeSensorTable(obj,src,~)
            obj.SensorTable=obj.UISensorTable.Data;
            MakeIdxTable(obj);
        end
        
        function MSetSensorOrder(obj,src,~)
            obj.SensorOrderIdx=src.Value;
        end
        
        function MSetSpeedIdx(obj,src,~)
            obj.SpeedIdx=src.Value;
        end
        
        function MSetSignalID(obj,src,~)
            obj.IDSignalIdx=src.Value;
            
        end
        
    end
end

