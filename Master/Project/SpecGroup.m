classdef SpecGroup < Node
    %SPECGROUP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
%         TreeNode;
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
            obj.Specimens=T;
        end
        
        function T=GetSpecRow(obj)
            T=table([],[],[],{},'VariableNames',...
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
            
            if obj.Init
                lbox=obj.Children(6);
                lbox.Items=obj.Selector.Name;
                lbox.ItemsData=obj.Selector.ID;
            end

        end
        

        
        function MenuNewSelector(obj,src,evnt)
            NewSelector(obj);
        end
        
        function MenuSelectAll(obj,src,evnt)
            obj.Sel(:)=true;
            obj.Selector.Specimens{obj.CurrSelID}=obj.Sel;
            obj.Children(3).Data.N=obj.Sel;
        end
        
        function MenuDeselectAll(obj,src,evnt)
            obj.Sel(:)=false;
            obj.Selector.Specimens{obj.CurrSelID}=obj.Sel;
            obj.Children(3).Data.N=obj.Sel;
        end
        
        function MenuSelectInverse(obj,src,evnt)
            obj.Sel(:)=~obj.Sel(:);
            obj.Selector.Specimens{obj.CurrSelID}=obj.Sel;
            obj.Children(3).Data.N=obj.Sel;
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
%             obj.Count=size(obj.Specimens,1);
        end
        
        function list=get.SpecimenList(obj)
            list=obj.Specimen.Key;
%             disp='test';
        end
        
        function idx=FindSpec(obj,key)
            idx=lower(obj.Specimens.Key)==lower(key);
        end
        
        function bool=SpecExist(obj,key)
            pos=obj.FindSpec(key);
            if sum(pos)>0
                bool=true;
            else
                bool=false;
            end
        end
        
        function UpdateSpec(obj,spec)
            row=obj.FindSpec(spec.Key);
            
            spec.ID=obj.Specimens.ID(row);
            obj.Specimens.MeasID(row)=spec.MeasID;
            Compare(obj.Specimens.Data{row},spec);
        end
        
        function bool=CheckUnqKey(obj,spec)
            keys=unique(obj.Specimens.Key);
            if numel(keys)==numel(obj.Specimens.Key)
                bool=true;
            else
                bool=false;
            end
        end
        
        function AddSpecimen(obj,spec)
            
            spec.ID=OperLib.FindProp(obj,'SpecimenID');
            
            obj.Specimens=[obj.Specimens; table(spec.ID,spec.Key,spec.MeasID,{spec},'VariableNames',...
                {'ID','Key','MeasID','Data'})];
            
        end
        
        function InitSelector(obj)
            if numel(obj.Selector)==0
                NewSelector(obj);
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

        function ClearIns(obj)
        end
        
        function T=GetSpecTable(obj)
            GetSel(obj);
            T=[table(obj.Sel,'VariableNames',{'N'}), obj.Specimens];
        end
        
        function Idx=HighLightMeas(obj,MeasID)
            Idx=zeros(size(MeasID,1),0);
            row=MeasID(1,1);
            marker=false;
            n=0;
            for i=2:size(MeasID,1)
                
                if MeasID(i,1)~=row
                    row=MeasID(i,1);
                    marker=~marker;    
                end
                if marker==true
                    n=n+1;
                    Idx=[Idx; i];
                end
%                 Idx(i,1)=marker;
            end
%             Idx(n:end,1)=[];
        end
        
        function InitializeOption(obj)
            SetParent(obj,'project');
            Clear(obj);
            g=uigridlayout(obj.GuiParent);
            g.RowHeight = {22,'1x',25,25,25,25};
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
            
%             TableMarker=obj.HighLightMeas(T.MeasID);
%             s = uistyle('BackgroundColor',[0.7, 0.7, 0.7]);
            s2=uistyle('HorizontalAlignment','left');
            
%             addStyle(uit,s,'row',TableMarker);
            addStyle(uit,s2);
            
            UITab=OperLib.FindProp(obj,'UIFig');
            cm = uicontextmenu(UITab);
            m1 = uimenu(cm,'Text','New selector',...
                'MenuSelectedFcn',@obj.MenuNewSelector);
            m2 = uimenu(cm,'Text','Select all',...
                'MenuSelectedFcn',@obj.MenuSelectAll);
            m3 = uimenu(cm,'Text','Deselect all',...
                'MenuSelectedFcn',@obj.MenuDeselectAll);
            m4 = uimenu(cm,'Text','Select inverse',...
                'MenuSelectedFcn',@obj.MenuSelectInverse);
            
        
            uit.ContextMenu =cm;

            uit.Layout.Row=2;
            uit.Layout.Column=1;
            
%             s = uistyle; 
            
%             s.HorizontalAlignment  = 'left'; 
%             addStyle(uit,s); 
            
            panel=uipanel(g,'Title','Specimen selector');
            panel.Layout.Row=[1 2];
            panel.Layout.Column=[2 4];
            
            g2=uigridlayout(panel);
            g2.RowHeight={25,'1x','1x'};
            g2.ColumnWidth={90,100,'1x'};
            
            lbl = uilabel(g2,'Text','Selector name:');
            lbl.Layout.Row=1;
            lbl.Layout.Column=1;
            
            if obj.Count>0
                selname=obj.Selector.Name(obj.CurrSelID);
            else
                selname="";
            end
            
            edt = uieditfield(g2,'Value',selname,'ValueChangedFcn',@obj.MChangeSelName);
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
            
            lbox = uilistbox(g2,'Items',items,'ItemsData',arr,'ValueChangedFcn',@obj.MenuChangeSelector,'Value',obj.CurrSelID);
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
            
            lbl = uilabel(g,'Text',sprintf('Specimens count: %d',size(obj.Specimens,1)));
            lbl.Layout.Row=3;
            lbl.Layout.Column=1;
            
            lbl = uilabel(g,'Text',sprintf('Measurements count: %d',size(unique(obj.Specimens.MeasID),1)));
            lbl.Layout.Row=4;
            lbl.Layout.Column=1;
            
            
            but1=uibutton(g,'Text','Select descriptive varibles');
            but1.Layout.Row=6;
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
%             stash.Count=obj.Count;
            stash.Specimens=obj.Specimens;
            stash.Sel=obj.Sel;
            stash.Selector=obj.Selector;
            stash.CurrSelID=obj.CurrSelID;
        end
        
        function Populate(obj,stash)
%             obj.Count=stash.Count;
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
            
            InitSelector(obj);
            
        end
    end
end

