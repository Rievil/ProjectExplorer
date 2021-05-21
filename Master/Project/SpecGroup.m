classdef SpecGroup < Node
    %SPECGROUP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        TreeNode;
        Specimens table;
        SpecDesc table;
        Count=0;
        Sel;
    end
    
    methods
        function obj = SpecGroup(parent)
            obj.Parent=parent;
            obj.Specimens=table([],[],[],{},'VariableNames',...
                {'ID','Key','MeasID','Data'});
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
            elseif size(T2,1)==1
                idx=find(obj.Specimens.MeasID==spec.MeasID & obj.Specimens.Key==spec.Key);
                T=GetT(spec);
                T.ID=obj.Specimens.ID(idx);
                obj.Specimens(idx,:)=T;
            elseif size(T2,1)>0
                
            end
            
            
            
%             obj.Specimens=[obj.Specimens, spec];
            obj.Count=numel(obj.Specimens);
            CreateSelector(obj);
        end
        
        function CreateSelector(obj)
            arr=logical(zeros(size(obj.Specimens,1),1));
            obj.Sel=table(arr,'VariableNames',{'N'});
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

        function stash=Pack(obj)
            stash=struct;
            stash.Count=obj.Count;
            stash.Specimens=obj.Specimens;
        end
        
        function InitializeOption(obj)
            SetParent(obj,'project');
            Clear(obj);
            g=uigridlayout(obj.GuiParent);
            g.RowHeight = {22,'1x',25,25};
            g.ColumnWidth = {'1x','1x',25,25};
            
            la=uilabel(g,'Text','Specimens in experiemnt:');
            la.Layout.Row=1;
            la.Layout.Column=[1 4];
            
            T=[obj.Sel, obj.Specimens];
            arr=logical(zeros(1,size(T,2)));
            arr(1)=true;
            
            uit = uitable(g,'Data',T,...
                'ColumnWidth','auto','ColumnEditable',arr,'CellEditCallback',@obj.SetSel,...
                'ColumnSortable',true);
                %'CellSelectionCallback',@(src,event)obj.SetTabPos(obj,event),'UserData',0);
            uit.Layout.Row=2;
            uit.Layout.Column=[1 2];
        end
        
        function SetSel(obj,evnt,src)
            Row=src.Indices(1);
            Column=src.Indices(2);
            obj.Sel{Row,1}=~obj.Sel{Row,1};
        end
        
        function node=AddNode(obj)
            
        end
        
        function Populate(obj,stash)
            obj.Count=stash.Count;
            obj.Specimens=stash.Specimens;
            CreateSelector(obj);
        end
    end
end

