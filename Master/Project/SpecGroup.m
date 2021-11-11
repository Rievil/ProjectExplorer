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
            obj.Specimens=GetSpecRow(obj);
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
        
        
        function idx=GetSelIdx(obj,sel)
            arguments
                obj
                sel string;
            end
            
            idx=false(obj.Count,1);
            for i=1:numel(sel)
                logarr=obj.Selector.Specimens{obj.Selector.Name==sel(i)};
                idx=idx | logarr;
            end
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
            
%             if obj.Init
%                 lbox=obj.Children(6);
                obj.UILBox.Items=obj.Selector.Name;
                obj.UILBox.ItemsData=obj.Selector.ID;
%             end

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
            list=obj.Specimens.Key;
%             disp='test';
        end
        
        function idx=FindSpec(obj,key)
            idx=contains(lower(obj.Specimens.Key),lower(key));
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
            Compare(obj.Specimens.Data(row),spec);
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
        
        function list=GetSelList(obj)
            list=obj.Selector.Name;
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
        
        function uit=DrawSepcTable(obj,g)
            
            list=string(obj.Parent.TypeSettings.DataType);
            colors=lines(numel(list));
            
            data=table;
            for i=1:numel(list)
                arr=false(obj.Count,1);
                data=[data, table(arr,'VariableNames',{list{i}})];
            end
            
            for i=1:obj.Count
                spec=obj.Specimens.Data(i);
                for j=1:size(spec.Data,2)
                    A=contains(list,string(spec.Data(j).type));
                    data.(list(A))(i)=true;
                end
            end
            
            T=[table(obj.Sel,'VariableNames',{'N'}), obj.Specimens(:,2), data];
            
            
            
            arr=logical(zeros(1,size(T,2)));
            arr(1)=1;
            
            cwidth = cell(1,2+numel(list));
            cwidth{1}=30;
            cwidth{2}=150;
            for i=1:numel(list)
                cwidth{2+i}=90;
            end
            
            uit = uitable(g,'Data',T,...
                'ColumnWidth',cwidth,'ColumnEditable',arr,'CellEditCallback',@obj.TalbeSetSel,...
                'ColumnSortable',true,'FontSize',10);
            
            
            s=uistyle('HorizontalAlignment','left');
            addStyle(uit,s);
            
            aIdx=1:1:obj.Count;
            aIdx=aIdx';
            for i=1:numel(list)
                sn=uistyle('BackgroundColor',colors(i,:));
                rows=aIdx(data{:,i});
                cols=linspace(2+i,2+i,numel(rows));
                cols=cols';
                addStyle(uit,sn,'cell',[rows,cols]);
            end
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
            g.ColumnWidth = {400,'2x',400,25,25};
            
            la=uilabel(g,'Text','Specimens in experiemnt:');
            la.Layout.Row=1;
            la.Layout.Column=[1 4];

            uit=DrawSepcTable(obj,g);

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
            uit.Layout.Column=[1 2];
            
%             s = uistyle; 
            
%             s.HorizontalAlignment  = 'left'; 
%             addStyle(uit,s); 
            
            panel=uipanel(g,'Title','Specimen selector');
            panel.Layout.Row=[1 2];
            panel.Layout.Column=[3 4];
            
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
            lbox.Layout.Row=[2 3];
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
            stash.Count=obj.Count;
            
            stash.Sel=obj.Sel;
            stash.Selector=obj.Selector;
            stash.CurrSelID=obj.CurrSelID;
            
            stash.Specimens=table;
            for i=1:stash.Count
                stash.Specimens=[stash.Specimens; obj.Specimens(i,1:3),...
                    table(Pack(obj.Specimens.Data(i)),'VariableNames',{'Data'})];
            end
        end
        
        function Populate(obj,stash)
%             obj.Count=stash.Count;
            if isfield(stash,'Specimens')
                
                for i=1:stash.Count
                    spec=Specimen(obj);
                    spec.Populate(stash.Specimens.Data(i));
                    obj.Specimens=[obj.Specimens; stash.Specimens(i,1:3),...
                    table(spec,'VariableNames',{'Data'})];
                end
            end
            
%             obj.Specimens=stash.Specimens;
            
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

