classdef SpecGroup < Node
    %SPECGROUP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        TreeNode;
        Specimens table;
        SpecDesc table;
        Selector table;
        CurrSelID;
        Sel;
        UISelName;
        UILBox;
    end
    
    properties (Dependent)
        SpecimenList;
        Count;
        SelCount;
    end
    
    methods
        function obj = SpecGroup(parent)
            obj.Parent=parent;
            obj.Specimens=table([],[],[],{},'VariableNames',...
                {'ID','Key','MeasID','Data'});
        end
        
        function count=get.Count(obj)
            count=size(obj.Specimens,1);
        end
        
        function selcount=get.SelCount(obj)
            selcount=size(obj.Selector,1);
        end
        
        function sel=GetEmptySel(obj)
            sel=logical(zeros(size(obj.Specimens,1),1));
        end
        
        function sel=GetSel(obj)
            if size(obj.Specimens,1)==numel(obj.Sel)
%                 sel=obj.Sel;
            elseif size(obj.Specimens,1)>numel(obj.Sel)
                obj.Sel=GetEmptySel(obj);
            elseif size(obj.Specimens,1)<numel(obj.Sel)
                obj.Sel=GetEmptySel(obj);
                
            end
            sel=obj.Sel;
        end

        
        function MenuChangeSelector(obj,src,~)
%             ID=src.Value;
            CheckSelectors(obj);
            obj.CurrSelID=src.Value;
            obj.Sel=obj.Selector.Specimens{obj.CurrSelID};
            obj.Children(3,1).Data.N=obj.Sel;
            obj.UISelName.Value=obj.Selector.Name(obj.CurrSelID);
%             disp('test');
        end
        
        function CheckSelectors(obj)
            test=false;
            for i=1:size(obj.Selector,1)
                if obj.Count~=size(obj.Selector.Specimens{i},1)
                    test=true;
                    newsel=logical(zeros(obj.Count,1));
                    obj.Selector.Specimens{i}=newsel;
                    
                end
            end
            
            if test==true
                obj.Sel=newsel;
            end
            
            
            
        end
        
        function NewSelector(obj)
%             obj.CurrSelID=
            if numel(obj.Selector)==0
                NewID=1;
                obj.CurrSelID=1;
            else
                NewID=max(obj.Selector.ID)+1;
            end
            
            Name=string(sprintf('Selector %d',NewID));
            sel=GetEmptySel(obj);
            obj.Selector=[obj.Selector; table(NewID,Name,{sel},...
                'VariableNames',{'ID','Name','Specimens'})];
            
            lbox=obj.Children(6);
            lbox.Items=obj.Selector.Name;
            lbox.ItemsData=obj.Selector.ID;

        end
        

        
        function MenuNewSelector(obj,src,evnt)
            NewSelector(obj);
        end
        
        function MChangeSelName(obj,src,~)
            
            obj.Selector.Name(obj.CurrSelID)=src.Value;
            obj.Children(6).Items=obj.Selector.Name;
        end
        
        function MenuDeleteSelector(obj,src,event)
            if size(obj.Selector,1)>1
                row=obj.Selector.ID==obj.CurrSelID;
                obj.Selector(row,:)=[];
                
                obj.CurrSelID=obj.Selector.ID(end);
                
                obj.Sel=obj.Selector.Specimens{obj.CurrSelID};
                obj.Children(3).Data.N=obj.Sel;
                obj.Children(6).Items=obj.Selector.Name;
                obj.Children(6).ItemsData=obj.Selector.ID;
                obj.Children(6).Value=obj.Selector.ID(obj.CurrSelID);

            end
        end
        
        function data=GetVarSample(obj)
            data=obj.Specimens.Data(1);
        end
        
        function RemoveSpecimens(obj,varargin)
            
            while numel(varargin)>0
                switch lower(varargin{1})
                    case 'measid'
                        Idx=obj.Specimens.MeasID==double(varargin{2});
                    case 'specimenid'
                        Idx=obj.Specimens.ID==double(varargin{2});
                end
                obj.Specimens(Idx,:)=[];
                obj.Sel(Idx,:)=[];
                varargin(1:2)=[];
                
            end
            obj.Count=size(obj.Specimens,1);
        end
        
        function list=get.SpecimenList(obj)
            list=obj.Specimen.Key;
%             disp='test';
        end
        
        function AddSpecimen(obj,spec)
            
            T2=table;
            if numel(obj.Specimens)>0
                T2=obj.Specimens(obj.Specimens.MeasID==spec.MeasID,:);
                T2=T2(T2.Key==spec.Key,:);
            end
            
            if numel(T2)==0
                spec.ID=OperLib.FindProp(obj,'SpecimenID');
                T=GetT(spec);
                obj.Specimens=[obj.Specimens; T];
%                 CreateSelector(obj);
            elseif size(T2,1)==1
                idx=find(obj.Specimens.MeasID==spec.MeasID & obj.Specimens.Key==spec.Key);
                T=GetT(spec);
                T.ID=obj.Specimens.ID(idx);
                obj.Specimens(idx,:)=T;
            elseif size(T2,1)>0
                
            end

%             obj.Count=numel(obj.Specimens);

        end
        
        function InitSelector(obj)
            if numel(obj.Selector)==0
                NewSelector(obj);
            else
                
            end
        end
        
        function NewSel(obj)
            arr=logical(zeros(size(obj.Specimens,1),1));
            obj.Sel=arr;
        end
    end
    
    methods %abstract
        function FillUITab(obj,Tab)
            p=OperLib.FindProp(obj,'UITab');
            SetGuiParent(obj,p);
            InitializeOption(obj);
        end
        
        function FillNode(obj)
            iconfilename=[OperLib.FindProp(obj,'MasterFolder') 'Master\Gui\Icons\SpecGroup.gif'];
            obj.TreeNode=uitreenode(obj.Parent.TreeNode,'Text','Specimens','NodeData',{obj,'specgroup'},...
                'Icon',iconfilename);
        end

        function T=GetSpecTable(obj)
            GetSel(obj);
            T=[table(obj.Sel,'VariableNames',{'N'}), obj.Specimens];
        end
        
        function InitializeOption(obj)
            SetParent(obj,'project');
            Clear(obj);
            g=uigridlayout(obj.GuiParent);
            g.RowHeight = {22,'1x',25,25};
            g.ColumnWidth = {400,'1x',25,25};
            
            la=uilabel(g,'Text','Specimens in experiemnt:');
            la.Layout.Row=1;
            la.Layout.Column=[1 4];
            
            T=GetSpecTable(obj);
            arr=logical(zeros(1,size(T,2)));
            arr(1)=1;
            
            uit = uitable(g,'Data',T,...
                'ColumnWidth',{30,50, 'auto',70,'auto'},'ColumnEditable',arr,'CellEditCallback',@obj.TalbeSetSel,...
                'ColumnSortable',true,'FontSize',10);
            
            UITab=OperLib.FindProp(obj,'UIFig');
            cm = uicontextmenu(UITab);
            m1 = uimenu(cm,'Text','New selector',...
                'MenuSelectedFcn',@obj.MenuNewSelector);
            %,...
                %'MenuSelectedFcn',@obj.MenuAddMeas);
            uit.ContextMenu =cm;
            
                %'CellSelectionCallback',@(src,event)obj.SetTabPos(obj,event),'UserData',0);
            uit.Layout.Row=2;
            uit.Layout.Column=1;
            
            s = uistyle; 
            s.HorizontalAlignment  = 'left'; 
            addStyle(uit,s); 
            
            panel=uipanel(g,'Title','Specimen selector');
            panel.Layout.Row=[1 2];
            panel.Layout.Column=[2 4];
            
            g2=uigridlayout(panel);
            g2.RowHeight={25,'1x','1x'};
            g2.ColumnWidth={90,100,'1x'};
            
            lbl = uilabel(g2,'Text','Selector name:');
            lbl.Layout.Row=1;
            lbl.Layout.Column=1;
            
            edt = uieditfield(g2,'ValueChangedFcn',@obj.MChangeSelName);
            edt.Layout.Row=1;
            edt.Layout.Column=2;
            
            obj.UISelName=edt;
            
            
            if obj.SelCount>0
                items=string(obj.Selector.Name);
            else
                InitSelector(obj);
                items=string(obj.Specimens.Name);
            end
            arr=1:1:numel(items);
            
            lbox = uilistbox(g2,'Items',items,'ItemsData',arr,'ValueChangedFcn',@obj.MenuChangeSelector);
            lbox.Layout.Row=2;
            lbox.Layout.Column=[1 2];
            
            obj.UILBox=lbox;
            
             obj.Children=[g;la;uit;panel;g2;lbox];
             
            
            
            
            cm2 = uicontextmenu(UITab,'UserData',lbox);
            m21 = uimenu(cm2,'Text','New selector',...
                'MenuSelectedFcn',@obj.MenuNewSelector);
            m22 = uimenu(cm2,'Text','Remove selector',...
                'MenuSelectedFcn',@obj.MenuDeleteSelector);
            lbox.ContextMenu=cm2;
            
            but1=uibutton(g,'Text','Select descriptive varibles');
            but1.Layout.Row=4;
            but1.Layout.Column=1;
        end


        function TalbeSetSel(obj,evnt,src)
            Row=src.Indices(1);
            Column=src.Indices(2);
            obj.Sel(Row,1)=~obj.Sel(Row,1);
            obj.Selector.Specimens{obj.CurrSelID}=obj.Sel;
        end
        
        function node=AddNode(obj)
            
        end
        
        function stash=Pack(obj)
            stash=struct;
            stash.Count=obj.Count;
            stash.Specimens=obj.Specimens;
            stash.Sel=obj.Sel;
            stash.Selector=obj.Selector;
            stash.CurrSelID=obj.CurrSelID;
        end
        
        function Populate(obj,stash)
            obj.Count=stash.Count;
            obj.Specimens=stash.Specimens;
            
            if isfield(stash,'Sel')
                obj.Sel=stash.Sel;
            end
            if isfield(stash,'Selector')
                obj.Selector=stash.Selector;
            end
            
            if isfield(stash,'CurrSelID')
                obj.CurrSelID=stash.CurrSelID;
            end
            
            
        end
    end
end

