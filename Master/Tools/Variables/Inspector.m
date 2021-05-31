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
        Row=0;
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
        Nodes;
        ObjParent;
        TotalVariableCount;
    end
    
    properties
        StorePath;
        IconPath;
    end
    
    methods
        function obj = Inspector(varargin)
            while numel(varargin)>0
               switch lower(varargin{1})
                   case 'data'
                       AppendArray(obj,varargin{2});
                   case 'name'
                       AddName(obj,varargin{2})
                   case 'parent'
                       obj.ObjParent=varargin{2};
                       MF=OperLib.FindProp(obj.ObjParent,'MasterFolder');            
                       obj.IconPath=[MF 'Master\GUI\Icons\'];
               end
               varargin(1:2)=[];
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
        
        function saveobj(obj)
            obj.GUIParent=[];
            obj.GUI=[];
            obj.ObjParent=[];
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
                       case 'parent'
                           obj.ObjParent=varargin{2};
                           MF=OperLib.FindProp(obj.ObjParent,'MasterFolder');            
                           obj.IconPath=[MF 'Master\GUI\Icons\'];
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
                 obj.CurrArr=obj.MemArray{obj.CurrArrIdx};
            else
                disp('Out of scope');
            end
        end
        
        
        function DrawVar(obj,evnt,src)
            uit=src.Source.UserData;
            if numel(evnt.SelectedNodes.NodeData)~=0
            [A,name]=GetVar(obj,evnt.SelectedNodes.NodeData{1});
                
                if numel(src.PreviousSelectedNodes)==0
                    SelectedVarIcon=[obj.IconPath 'VarIconSelected.gif'];
                else
                    SelectedVarIcon=[obj.IconPath 'VarIconSelected.gif'];
                    if numel(src.PreviousSelectedNodes.NodeData)>0
                        src.PreviousSelectedNodes.Icon=[obj.IconPath src.PreviousSelectedNodes.NodeData{2}];
                    end
                end
                
                evnt.SelectedNodes.Icon=SelectedVarIcon;
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
                s = uistyle; 
                s.HorizontalAlignment  = 'left'; 
                addStyle(uit,s); 
            end
        end
        
        function SetGuiParent(obj,fig)
            obj.GUIParent=fig;
%             obj.Fig=1;
        end
        
        function FigWindowClose(obj,src,evnt)
            ClearGui(obj);
        end
        
        function Reset(obj)
            obj.CurrArr=[];
            obj.MemArray=[];
            obj.MemName=[];
            obj.Count=0;
            obj.ArrCount=[];
            obj.Row=0;
            tree=obj.GUI(4);
            a=tree.Children;
            a.delete;
        end
        
        function Show(obj)

        end
        
        function DrawGUI(obj)
            if obj.Fig==0
                fig = uifigure;
            else
                fig=obj.GUIParent;
            end
            
            trida=class(fig);
            switch trida
                case 'matlab.ui.container.Panel'
                case 'test'
                    fig.CloseRequestFcn=@obj.FigWindowClose;
                otherwise
            end
 
            g=uigridlayout(fig);
            g.RowHeight = {'1x','2x'};
            g.ColumnWidth = {300,600,'1x'};

            uit=uitable(g);
            uit.Layout.Row=1;
            uit.Layout.Column=[2 3];

            t = uitree(g,'SelectionChangedFcn',@obj.DrawVar,'UserData',uit,'FontSize',10);
            t.Layout.Row=[1 2];
            t.Layout.Column=1;

            
            obj.Fig=1;

            p = uipanel(g,'Title','Variable forge','FontSize',12);
            p.Layout.Row=2;
            p.Layout.Column=[2 3];
            
            obj.GUI=[fig,g,uit,t,p];
        end
        
        function FirstRun(obj)
            DefineTable(obj);
            obj.IconPath=[OperLib.FindProp(obj.ObjParent,'MasterFolder'),'Master\GUI\Icons\'];
            
            for i=1:obj.Count %procházím všechny uložené datové typy
                
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
            
            obj.Nodes=obj.GUI(4).Children;
            obj.TotalVariableCount=size(obj.T,2);
        end
        
        function Run(obj)
            
            obj.Type=class(obj.CurrArr);
            
            if obj.Child==0
                
                if obj.Fig==0
                    DefineTable(obj);
                    DrawGUI(obj);
                end
                tree=obj.GUI(4);
                AddPath(obj,'mainnode',obj.CurrArrName,0,0);
            end
                
            
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
            Select(obj,obj.T(row).CurrArr);
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
            obj.Row=0;
            obj.T=struct("CurrArr",[],"ID",[],"ParID",[],"Depth",[],"Type",Type,"Path",Path,"Num",Num,"Size",Size,"Name",'');
        end
        
        function LoopStruct(obj)
            Arr=obj.CurrArr;
            obj.Fields = fieldnames(Arr);
            obj.Sz=size(Arr);
            
            for i=1:obj.Sz(2)
                if obj.Sz(2)>1
%                     AddSepNode(obj);
                    AddPath(obj,"sepnode",[],1,1);
                    pArr=Arr(i);
                    ChildInspector(pArr,obj);
                else
                
                    for j=1:numel(obj.Fields)
                        type=class(Arr(i).(obj.Fields{j}));
                        pArr=Arr(i).(obj.Fields{j});
    %                     obj.Row=obj.Row+1;
                        obj.CurPath=string(obj.Fields{j});
                        obj.CurNum=i;
                        obj.CurType=string(type);
                        obj.VarSz=size(pArr);
                        AddPath(obj,obj.CurType,obj.CurPath,obj.CurNum,obj.VarSz);
                        
                        ChildInspector(pArr,obj);

                    end
                end
            end
        end
        
        function LoopTable(obj)
            VarNames=obj.CurrArr.Properties.VariableNames;
            for i=1:numel(VarNames)
%                 obj.Row=obj.Row+1;
                obj.CurNum=i;
                obj.CurPath=string(VarNames{i});
                obj.CurType=string(class(obj.CurrArr{:,i}));
                AddPath(obj,obj.CurType,obj.CurPath,obj.CurNum,size(obj.CurrArr{:,i}));
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
          icon=[obj.IconPath 'SepNode.gif'];
            if obj.Child>0
                obj.SepNode=uitreenode(obj.Node,'Text','Sep Node','Icon',icon,'NodeData',{0,''});
                obj.SepNodeBool=true;
            end
        end
        
        function AddNode(obj)           
            
            switch obj.CurType
                case 'table'
                    icon=[obj.IconPath 'TableIcon.gif'];
                    suffix='TableIcon.gif';
                case 'struct'
                    icon=[obj.IconPath 'StructIcon.gif'];
                    suffix='StructIcon.gif';
                otherwise
                    icon=[obj.IconPath 'VarIcon.gif'];
                    suffix='VarIcon.gif';
            end
            
            name=char(sprintf('%d - %s [%d]',obj.ID,obj.CurPath,size(obj.CurrArr,1)));
            
            if obj.Child==0
                obj.ChildNode=uitreenode(obj.Node,'Text',name,'NodeData',{obj.ID,suffix},'Icon',icon);
            else
                if obj.SepNodeBool==false
                    obj.ChildNode=uitreenode(obj.Node,'Text',name,'NodeData',{obj.ID,suffix},'Icon',icon);
                else
                    obj.ChildNode=uitreenode(obj.SepNode,'Text',name,'NodeData',{obj.ID,suffix},'Icon',icon);
                end
            end
        end
        
        function AddPath(obj,type,path,num,size)
            if obj.Child==0
%                 obj.Row=obj.Row+1;
                AddPathFin(obj,type,path,num,size);
                obj.ID=obj.T(end).ID;
            else
                AddPathChild(obj,type,path,num,size)
                p=FindParent(obj);
                obj.ID=p.T(end).ID;
            end
        end
        
        function DrawNodes(obj)
            nodes=cell(obj.TotalVariableCount,1);
            tree=obj.GUI(4);
            for i=1:obj.TotalVariableCount
                type=obj.T(i).Type(end);
                name=obj.T(i).Name;
                id=obj.T(i).ID;
                depth=obj.T(i).Depth;
                
                switch type
                    case 'mainnode'
                        id=1;
                        suffix='';
                        icon='';
                    case 'sepnode'
%             if obj.Child>0
%                 obj.SepNode=uitreenode(obj.Node,'Text','Sep Node','Icon',icon,'NodeData',{0,''});
                        icon=[obj.IconPath 'SepNode.gif'];
                        suffix='SepNode.gif';
                        id=0;
                    case 'table'
                        icon=[obj.IconPath 'TableIcon.gif'];
                        suffix='TableIcon.gif';
                    case 'struct'
                        icon=[obj.IconPath 'StructIcon.gif'];
                        suffix='StructIcon.gif';
                    otherwise
                        icon=[obj.IconPath 'VarIcon.gif'];
                        suffix='VarIcon.gif';
                end
                

                
                if depth==1
                    nodes{i,1}=uitreenode(tree,'Text',name,'NodeData',{id,suffix},'Icon',icon);
                else
                    parid=obj.T(i).ParID;
%                     node=
                    nodes{i,1}=uitreenode(nodes{parid,1},'Text',name,'NodeData',{id,suffix},'Icon',icon);
                end
                    
%                 obj.ChildNode=uitreenode(obj.SepNode,'Text',name,'NodeData',{obj.ID,suffix},'Icon',icon);
            end
        end
        
        
        function AddPathFin(obj,type,path,num,size)
            arguments
                obj
                type (:,1) string
                path (:,1) string
                num (:,1) double
                size (1,2) double
            end
            
            ltype=type(end,1);
            
            obj.Row=obj.Row+1;
            obj.T(obj.Row).CurrArr=obj.CurrArrIdx;
            obj.T(obj.Row).ID=obj.Row;
            obj.T(obj.Row).Type=type;
            
            switch ltype
                case 'mainnode'
                    obj.Depth=1;
                case 'sepnode'
                    
                otherwise
                    obj.Depth=numel(obj.T(obj.Row).Type)+1;
            end
            
            obj.T(obj.Row).Depth=obj.Depth;
            obj.T(obj.Row).ParID=GetLastParID(obj);
            obj.T(obj.Row).Path=path;
            obj.T(obj.Row).Num=num;
            obj.T(obj.Row).Size=size;
            obj.T(obj.Row).Name=obj.T(obj.Row).Path(end);
            
%             
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
                    dif=obj.Depth-obj.T(i).Depth;
                    if dif==1
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

