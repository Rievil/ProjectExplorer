classdef Inspector < handle

    properties
        CurrArr;
        MemArray;
        MemName (:,1) string;
        CurrArrName;
        CurrArrIdx;
        ArrCount;
        Count=0;
        Fields;
        Sz;
        VarSz;
        Type;
        T;
        Child=0;
        Row=1;
        CurPath;
        CurNum;
        CurType;
        Node;
        SepNode;
        SepNodeBool=false;
        ChildNode;
        Fig=0;
        ID;
        Depth;
        GUI;
        GUIParent;
    end
    
    properties
        StorePath;
    end
    
    methods
        function obj = Inspector(varargin)
            if numel(varargin)==0
            elseif numel(varargin)==1
                obj.CurrArr=varargin{1};
            elseif numel(varargin)>1
                AddArray(obj,varargin);
            end
        end
        
        function ClearGui(obj)
            for G=obj.GUI
                G.delete;
            end
            obj.GUI=[];
            obj.Fig=0;
            obj.GUIParent=[];
            obj.Node=[];
            obj.ChildNode=[];
        end
        
        function AddArray(obj,varargin)
            if numel(varargin)==1
                AppendArray(obj,varargin{1});
            elseif numel(varargin)>1
               while numel(varargin)>0
                   switch lower(varargin{1})
                       case 'data'
                           AppendArray(obj,varargin{2});
                       case 'name'
                           AddName(obj,varargin{2})
                   end
                   varargin(1:2)=[];
               end
            end
        end
        
        function AddName(obj,name)
            obj.MemName=[obj.MemName; string(name)];
        end
        
        function AppendArray(obj,arr)
            
            obj.Count=obj.Count+1;
            obj.MemArray{obj.Count}=arr;
            obj.CurrArrIdx=obj.Count;
            obj.CurrArr=obj.MemArray{obj.CurrArrIdx};
        end
        
        function ListArray(obj)
            for i=1:obj.Count
                disp(class(obj.MemArray));
            end
        end
        
        function Select(obj,i)
            if i>0 && i<=obj.Count
                 obj.CurrArrIdx=i;
                 obj.CurrArr=obj.MemArray(obj.CurrArrIdx);
            else
                disp('Out of scope');
            end
        end
        
        
        function DrawVar(obj,evnt,src)
            uit=src.Source.UserData;
            [A,name]=GetVar(obj,evnt.SelectedNodes.NodeData);

                R=A;
                bool=false;
                while bool==0
                    switch class(R)
                        case 'table'
                            tab=R;
                            bool=1;
                        case 'char'
                            R=string(R);
                        case 'cell'
                            R=string(R);
                        case 'struct'
                            R=struct2table(R,'AsArray',true);
                        otherwise
                            F=R;
                            bool=1;
                            tab=table(F,'VariableNames',name);
                    end
                end
                uit.Data=tab;
        end
        
        function SetGuiParent(obj,fig)
            obj.GUIParent=fig;
%             obj.Fig=1;
        end
        
        function FigWindowClose(obj,src,evnt)
            ClearGui(obj);
        end
        
        function DrawGUI(obj)
            if obj.Fig==0
                fig = uifigure;
            else
                fig=obj.GUIParent;
            end
            
            fig.CloseRequestFcn=@obj.FigWindowClose;
            
            g=uigridlayout(fig);
            g.RowHeight = {'1x','2x'};
            g.ColumnWidth = {'1x','2x'};
            uit=uitable(g);
            uit.Layout.Row=1;
            uit.Layout.Column=2;

            t = uitree(g,'SelectionChangedFcn',@obj.DrawVar,'UserData',uit);
            t.Layout.Row=[1 2];
            t.Layout.Column=1;

            
            obj.Fig=1;

            p = uipanel(g,'Title','Options','FontSize',12);
            p.Layout.Row=2;
            p.Layout.Column=2;

            g2=uigridlayout(p);
            g2.RowHeight = {25,25,'1x'};
            g2.ColumnWidth = {50,'3x','1x'};

            lbl = uilabel(g2,'Text','Size:');
            lbl.Layout.Row=1;
            lbl.Layout.Column=[1 2];
            obj.GUI=[fig,g,uit,t,p,g2,lbl];
        end
        
        function Run3(obj)
            for i=1:obj.Count
                obj.CurrArrIdx=i;
                obj.CurrArr=obj.MemArray{i};
                if numel(obj.MemName)==0
                    obj.CurrArrName=char(sprintf('Array %d',i));
                    obj.MemName(i,1)=string(obj.CurrArrName);
                else
                    if isempty(obj.MemName(i,1))
                        obj.CurrArrName=char(sprintf('Array %d',i));
                    else
                        obj.CurrArrName=char(obj.MemName(i,1));
                    end
                end
                Run(obj);
            end
        end
        
        function Run(obj)
            if obj.Child==0
                
                if obj.Fig==0
                    DefineTable(obj);
                    DrawGUI(obj);
                end
                tree=obj.GUI(4);
                obj.Node = uitreenode(tree,'Text',obj.CurrArrName);
            end
                
            obj.Type=class(obj.CurrArr);
            switch obj.Type
                case 'struct'
                    LoopStruct(obj);
                case 'table'
                    LoopTable(obj);
                otherwise
            end
        end
        
        function [A,name]=GetVar(obj,ID)
            row=ID;
            path=obj.T(row).Path;
            numpath=obj.T(row).Num';
            name=obj.T(row).Name;
            
            A=obj.CurrArr;
            for i=1:numel(path)
                typeIN=class(A);
                switch typeIN
                    case 'struct'
                        A=A(numpath(i)).(path{i});
                    case 'table'
                        if numpath(i)==0
                            A=A.(path{i});
                        else
                            A=A.(path{i});
                            
                        end
                    otherwise
                end
%                 typeOUT=class(A)
            end
        end
        
        function DefineTable(obj)
            Type=strings(0,0);
            Path=strings(0,0);
            Num=zeros(0,0);
            Size=[0,0];
            obj.T=struct("ID",[],"ParID",[],"Depth",[],"Type",Type,"Path",Path,"Num",Num,"Size",Size,"Name",'');
        end
        
        function LoopStruct(obj)
            Arr=obj.CurrArr;
            obj.Fields = fieldnames(Arr);
            obj.Sz=size(Arr);
            
            for i=1:obj.Sz(2)
                if obj.Sz(2)>1
                    AddSepNode(obj);
%                     AddPath(obj,"sepnode",[],[],[]);
                end
                
                for j=1:numel(obj.Fields)
                    type=class(Arr(i).(obj.Fields{j}));
                    pArr=Arr(i).(obj.Fields{j});
                    
                    obj.CurPath=string(obj.Fields{j});
                    obj.CurNum=i;
                    obj.CurType=string(type);
                    obj.VarSz=size(pArr);
                    AddPath(obj,obj.CurType,obj.CurPath,obj.CurNum,obj.VarSz);
                    AddNode(obj);
                    
                    switch type
                        case 'struct'
                            ChildInspector(pArr,obj);
                            
                        case 'table'
                            ChildInspector(pArr,obj);
                        otherwise
                            
%                             obj.Row=obj.Row+1;
%                             AddPath(obj,pArr);                            
                    end
                end
            end
        end
        
        function LoopTable(obj)
            VarNames=obj.CurrArr.Properties.VariableNames;
            for i=1:numel(VarNames)
                obj.CurNum=i;
                obj.CurPath=string(VarNames{i});
                obj.CurType=string(class(obj.CurrArr{:,i}));
                AddPath(obj,obj.CurType,obj.CurPath,obj.CurNum,size(obj.CurrArr{:,i}));
                AddNode(obj);
                obj.Row=obj.Row+1;
            end
        end
        
        function AddVariable(obj,arr)
            if obj.Child==0
                exAddVariable(obj,arr);
            else
                exAddVariable(obj.Parent,arr)
            end
        end
        
        function AddSepNode(obj)
          icon='C:\Users\Richard\OneDrive - Vysoké učení technické v Brně\Dokumenty\Github\ProjectExplorer\Master\GUI\Icons\SepNode.gif';
            if obj.Child>0
                obj.SepNode=uitreenode(obj.Node,'Text','Sep Node','Icon',icon);
                obj.SepNodeBool=true;
            end
        end
        
        function AddNode(obj)
            path='C:\Users\Richard\OneDrive - Vysoké učení technické v Brně\Dokumenty\Github\ProjectExplorer\Master\GUI\Icons\';
            
            switch obj.CurType
                case 'table'
                    icon=[path 'TableIcon.gif'];
                case 'struct'
                    icon=[path 'StructIcon.gif'];
                otherwise
                    icon=[path 'VarIcon.gif'];
            end
            
            name=[char(num2str(obj.ID)) ' - ' char(obj.CurPath)];
            if obj.Child==0
                obj.ChildNode=uitreenode(obj.Node,'Text',name,'NodeData',obj.ID,'Icon',icon);
            else
                if obj.SepNodeBool==false
                    obj.ChildNode=uitreenode(obj.Node,'Text',name,'NodeData',obj.ID,'Icon',icon);
                else
                    obj.ChildNode=uitreenode(obj.SepNode,'Text',name,'NodeData',obj.ID,'Icon',icon);
                end
            end
        end
        
        function AddPath(obj,type,path,num,size)
            if obj.Child==0
                AddPathFin(obj,type,path,num,size);
                obj.ID=obj.T(end).ID;
            else
                AddPathChild(obj,type,path,num,size)
                p=FindParent(obj);
                obj.ID=p.T(end).ID;
            end
        end
        
        function DrawNodes(obj)

        end
        
        function AddPathFin(obj,type,path,num,size)
%             
            obj.T(obj.Row).ID=obj.Row;
%             sz=size(obj.T(obj.Row).Type,1);
            obj.T(obj.Row).Type=type;
            obj.Depth=numel(obj.T(obj.Row).Type)+1;
            obj.T(obj.Row).Depth=obj.Depth;
            obj.T(obj.Row).ParID=GetLastParID(obj);
            
            obj.T(obj.Row).Path=path;
            obj.T(obj.Row).Num=num;
            obj.T(obj.Row).Size=size;
            obj.T(obj.Row).Name=obj.T(obj.Row).Path(end);
            
%             AddNode(obj,obj.T(obj.Row).Name)
            obj.Row=obj.Row+1;
        end
        
        function ID=GetLastParID(obj)
            m=size(obj.T,2);
            arr=flip(linspace(1,m,m)');
            ID=1;
            for j=1:numel(arr)
                i=arr(j,1);
                if obj.Row==1
                    ID=1;
                    break;
                else
                    if obj.Depth>obj.T(i).Depth
                        ID=obj.T(i).ID;
                        break;
                    end
                end
            end
        end
        
        function AddPathChild(obj,type,path,num,size)
            path=[obj.Parent.CurPath; path];
            num=[obj.Parent.CurNum; num];
            type=[obj.Parent.CurType; type];
            AddPath(obj.Parent,type,path,num,size)
        end

    end
end

