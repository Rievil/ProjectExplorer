classdef OPEventParam < Operator
    %OPEVENTPARAM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
%         ;Property1
        LocalType=1;
        SensorOrderIdx=1;
        IDSignalIdx=1;
        DetTable;
        UIDetTable;
        SensorTableIdx;
%         Labels;
    end
    
    methods
        function obj = OPEventParam(inputArg1,inputArg2)
            obj@Operator;
            obj.Name='OPEventParam';
            obj.Title='Parameters of localized events';
            
            
            
            obj.Description={'Select type of lokalization: 1D | 2D | 3D';
                'select name of cards';
                'select hit IDs from events';
                'select hit Order from events';
                'select HitDet for each card'};
        end

        
        function ResetHitDetTable(obj)
            switch obj.LocalType
                case 1
                    obj.DetTable=[GetSensorRow(obj); GetSensorRow(obj)];
                case 2
                    obj.DetTable=[GetSensorRow(obj); GetSensorRow(obj); GetSensorRow(obj)];
                case 3
                    obj.DetTable=[GetSensorRow(obj); GetSensorRow(obj); GetSensorRow(obj); GetSensorRow(obj)];
            end
        end
        
        function CheckChange(obj)
            varList=sort(obj.GetVarList);
            currVarList=sort(string(categories(obj.DetTable{1,1})));
            
            samesize=numel(varList)==numel(currVarList);
            if samesize==true
                b=strcmp(varList,currVarList);
                if sum(b)==numel(varList)
                    %vše je při starém
                else
                    %změna názvu proměné
                    ResetHitDetTable(obj)
                end
            else
                %nová proměná | ubyla proměná
                ResetHitDetTable(obj)
            end
        end
        
        function T=GetSensorRow(obj)
            varList=categorical(obj.GetVarList);
            T=table(varList(1),varList(1),'VariableNames',...
                        {'CardName','HitDet'});
        end
        
        function newT=MergeData(obj)
            EID=obj.Parent.Output{obj.IDSignalIdx};
            EOrder=lower(obj.Parent.Output{obj.SensorOrderIdx});
            index=1:size(EOrder,1);
            ET=table(index',EID(:,1),EOrder(:,1),'VariableNames',{'Index','ID','Order'});
            
            htdata=struct;
            newT=table;
            
            for i=1:size(obj.DetTable,1)
                htdata(i).Cards=lower(obj.Parent.Output{obj.SensorTableIdx(i,1)});
                htdata(i).Hits=obj.Parent.Output{obj.SensorTableIdx(i,2)};
                names=htdata(i).Hits.Properties.VariableNames;
                Idx=find(names=="Hit_ID");
                htdata(i).Hits.Properties.VariableNames{Idx}='ID';
                
                ET2=ET(ET.Order==htdata(i).Cards,:);
%                 testik=;
                if numel(intersect(ET2.ID,htdata(i).Hits.ID))>0
                    T=join(ET2,htdata(i).Hits,'Keys','ID');
                    newT=[newT; T];
                end 
            end
            
            if numel(newT)>0
                newT=sortrows(newT,'Index');
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
            
            
            if isempty(obj.DetTable)
                obj.ResetHitDetTable;
            else
                CheckChange(obj);
            end
            
            arr=logical(zeros(1,size(obj.DetTable,2)));
            arr(:)=true;
            
            sentab = uitable(g,'Data',obj.DetTable,'ColumnEditable',arr,...
                'CellEditCallback',@obj.MChangeDetTable);
            sentab.Layout.Row=[7 8];
            sentab.Layout.Column=[1 4];
            
            obj.UIDetTable=sentab;
            
            but1=uibutton(g,'Text','Add sensor','ButtonPushedFcn',@obj.MAddSensor);
            but1.Layout.Row=6;
            but1.Layout.Column=3;
            
            but2=uibutton(g,'Text','Remove sensor','ButtonPushedFcn',@obj.MRemoveSensor);
            but2.Layout.Row=6;
            but2.Layout.Column=4;
            
        end
        
        
        
        
        function RunTool(obj,~)
            MakeIdxTable(obj);
            obj.Output={MergeData(obj)};
            obj.Labels='ConnectedHits';
        end
        
        function stash=Pack(obj)
            stash=struct;
            stash.LocalType=obj.LocalType;
            
            stash.SensorOrderIdx=obj.SensorOrderIdx;
            stash.IDSignalIdx=obj.IDSignalIdx;
            stash.DetTable=obj.DetTable;
        end
        
        function Populate(obj,stash)
            obj.LocalType=stash.LocalType;
            
            obj.SensorOrderIdx=stash.SensorOrderIdx;
            obj.IDSignalIdx=stash.IDSignalIdx;
            obj.DetTable=stash.DetTable;
        end
    end
    
    methods (Access = private)%callbacks
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
            T=obj.GetSensorRow;
            obj.DetTable=[obj.DetTable; T];
            obj.UIDetTable.Data=obj.DetTable;
        end
        
        function MRemoveSensor(obj,src,~)
            if size(obj.DetTable,1)>obj.LocalType+1
                obj.DetTable(end,:)=[];
                obj.UIDetTable.Data=obj.DetTable;
            end
        end

        function MChangeDetTable(obj,src,~)
            obj.DetTable=obj.UIDetTable.Data;
            MakeIdxTable(obj);
        end
        
        function MSetSensorOrder(obj,src,~)
            obj.SensorOrderIdx=src.Value;
        end
        
        function MSetSignalID(obj,src,~)
            obj.IDSignalIdx=src.Value;
        end
        
        function MakeIdxTable(obj)
            varList=obj.GetVarList;
            obj.SensorTableIdx=zeros(size(obj.DetTable,1),size(obj.DetTable,2));
            for i=1:size(obj.DetTable,1)
                for j=1:size(obj.DetTable,2)
                    Idx=find(varList==string(obj.DetTable{i,j}));
                    obj.SensorTableIdx(i,j)=Idx;
                end
                
               
                
            end
        end
    end
end

