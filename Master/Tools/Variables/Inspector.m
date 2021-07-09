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
        Nodes;
        ObjParent;
        CurrVariableID;
        UITableSelector;
        OutAdress;
        CurrDialog;
        UICbox;
        SelectMultiple;
        MultipleVarIDList;
        MultiAdressTable;
        MultiAdressList;
        UIVarTableRowSelected=0;
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
        
        function T=GetAdress(obj,id)
            count=numel(obj.T(id).Type);
            type=obj.T(id).Type(count);
            path=string(['[',replace(char(join(flip(obj.T(id).Path))),' ','],['),']']);
            name=obj.T(id).Name;
            size=obj.T(id).Size;
            
            T=table(id,name,type,path,size,'VariableNames',...
                {'ID','Name','Type','Path','Size'});
        end
        
        function SelectOne(obj,id)
            
        end
        
        
        function AddSelectedAdress(obj)
            if obj.CurrVariableID>0
                
                adress=Adress(obj.CurrDialog);
                setAdress(adress,obj.T(obj.CurrVariableID));
                Ta=GetRow(adress);
                
                if obj.SelectMultiple==true
                    obj.MultipleVarIDList=[obj.MultipleVarIDList, obj.CurrVariableID];
                    id=numel(obj.MultiAdressList)+1;
                    obj.MultiAdressList{id}=adress;
                    obj.MultiAdressTable=[obj.MultiAdressTable; Ta];
                else
                    obj.MultiAdressList{1}=adress;
                    obj.MultiAdressTable=Ta;
                end
                
                obj.UITableSelector.Data=obj.MultiAdressTable;
            end
        end
        
        function DrawVar(obj,evnt,src)
            uit=src.Source.UserData;
            if numel(evnt.SelectedNodes.NodeData)~=0
                [A,name]=GetVar(obj,evnt.SelectedNodes.NodeData{1});

                obj.CurrVariableID=evnt.SelectedNodes.NodeData{1};

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
            obj.Row=1;
%             tree=obj.GUI(4);
%             a=tree.Children;
%             a.delete;
        end
        
        function RemoveUIVariable(obj)
            count=numel(obj.MultiAdressList);
            if count >0
                if obj.UIVarTableRowSelected>0
                    delete( obj.MultiAdressList{obj.UIVarTableRowSelected});
                    obj.MultiAdressList(obj.UIVarTableRowSelected)=[];
                    obj.MultiAdressTable(obj.UIVarTableRowSelected,:)=[];
                    
                    obj.UIVarTableRowSelected=obj.UIVarTableRowSelected-1;
                else
                    delete(obj.MultiAdressList{count});
                    obj.MultiAdressList(count)=[];
                    obj.MultiAdressTable(count,:)=[];
                end
                obj.UITableSelector.Data=obj.MultiAdressTable;
            end
        end
        
        function SelectAndMoveVars(obj)
            if obj.SelectMultiple==true
                for ad=obj.MultiAdressList
                    adre=ad{1};
                    AddAdress(obj.CurrDialog,adre);
                end
            else
                AddAdress(obj.CurrDialog,obj.MultiAdressList{1});
            end
            
            obj.MultiAdressList=[];
            obj.MultiAdressTable=[];
            obj.MultipleVarIDList=[];
        end
          
        function CloseFig(obj)
            close(obj.GUI(1));
        end
           
        function Show(obj)
            
        end
        
        function DrawGUI(obj)
            if obj.Fig==0
                Pix_SS = get(0,'screensize');
                A=1000;
                B=500;
                dim=[Pix_SS(3)/2-A/2,Pix_SS(4)/2-B/2,A,B];
                fig = uifigure('WindowKeyPressFcn',@obj.MCheckKeyPressed,'Position',dim);
                
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
            g.RowHeight = {25,'1x','2x',25};
            g.ColumnWidth = {'1x','1x',80,80};
            
            uit=uitable(g);
            uit.Layout.Row=2;
            uit.Layout.Column=[2 5];
            
            lab1=uilabel(g,'Text','Raw variables in measurement:');
            lab1.Layout.Row=1;
            lab1.Layout.Column=1;
            
            lab1=uilabel(g,'Text','Preview of selected variable:');
            lab1.Layout.Row=1;
            lab1.Layout.Column=[2 3];
            
            t = uitree(g,'SelectionChangedFcn',@obj.DrawVar,'UserData',uit,'FontSize',10);
            t.Layout.Row=[2 3];
            t.Layout.Column=1;

            
            obj.Fig=1;

            
            uit2=uitable(g,'CellSelectionCallback',@obj.MVarTableSelect);
            obj.UITableSelector=uit2;
            uit2.Layout.Row=3;
            uit2.Layout.Column=[2 5];
            
            cbox=uicheckbox(g,'Text','Multiple varaibles?','ValueChangedFcn',@obj.MSetMultipleSelection);
            cbox.Layout.Row=4;
            cbox.Layout.Column=3;
            
            obj.UICbox=cbox;
            obj.SelectMultiple=obj.UICbox.Value;
        
            
            but1=uibutton(g,'Text','Select variables','ButtonPushedFcn',@obj.MSelectVariable);%,'ButtonPushedFcn',@obj.MCheckVar);
            but1.Layout.Row=4;
            but1.Layout.Column=4;
            
            but2=uibutton(g,'Text','Cancel selection','ButtonPushedFcn',@obj.MCloseFig);%,'ButtonPushedFcn',@obj.MCheckVar);
            but2.Layout.Row=4;
            but2.Layout.Column=5;
            
            but3=uibutton(g,'Text','Add variable','ButtonPushedFcn',@obj.MAddVariable);%,'ButtonPushedFcn',@obj.MCheckVar);
            but3.Layout.Row=4;
            but3.Layout.Column=1;
            
            but4=uibutton(g,'Text','Remove variable','ButtonPushedFcn',@obj.MRemoveVariable);%,'ButtonPushedFcn',@obj.MCheckVar);
            but4.Layout.Row=4;
            but4.Layout.Column=2;
            
            
            obj.GUI=[fig,g,uit,t];
        end
        
        function MCheckKeyPressed(obj,src,evnt)
            switch evnt.Key
                case 'space'
                    AddSelectedAdress(obj);
                case 'delete'
                    RemoveUIVariable(obj);
                case 'return'
                    SelectAndMoveVars(obj);
                    CloseFig(obj);
                case 'escape'
                    CloseFig(obj);
                otherwise
                    disp('Different key');
            end
                    
        end
        
        function MCloseFig(obj,~,~)
            CloseFig(obj);
        end
        
        function MAddVariable(obj,src,~)
            AddSelectedAdress(obj);
        end
        
        function MSetMultipleSelection(obj,src,~)
            obj.SelectMultiple=~obj.SelectMultiple;
        end
        
        function MRemoveVariable(obj,src,~)
            RemoveUIVariable(obj);
        end
        
        function MVarTableSelect(obj,src,evnt)
            obj.UIVarTableRowSelected=evnt.Indices(1);
        end
        
        function MSelectVariable(obj,src,~)
            SelectAndMoveVars(obj);
            CloseFig(obj);
        end
        
        function BakeAdress(obj)

        end
        
        function close(obj) %overloaded operator
%             if obj.SelBool==0
%                 obj.Type=[];
%             end
        end
        
        function FirstRun(obj)
            MF=OperLib.FindProp(obj.ObjParent,'MasterFolder');            
            obj.IconPath=[MF 'Master\GUI\Icons\'];
            DefineTable(obj);
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
            obj.Nodes=obj.GUI(4).Children;
        end
        
        function Run(obj)
            obj.MultiAdressList=[];
            obj.MultiAdressTable=[];
            obj.MultipleVarIDList=[];
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
            end
        end
        
        function DefineTable(obj)
            Type=strings(0,0);
            Path=strings(0,0);
            Num=zeros(0,0);
            Size=[0,0];
            obj.Row=1;
            obj.T=struct("CurrArr",[],"ArrType",[],"ID",[],"ParID",[],"Depth",[],"Type",Type,"Path",Path,"Num",Num,"Size",Size,"Name",'');
        end
        
        function LoopStruct(obj)
            Arr=obj.CurrArr;
            obj.Fields = fieldnames(Arr);
            obj.Sz=size(Arr);
            
            for i=1:obj.Sz(2)
                if obj.Sz(2)>1
                    AddSepNode(obj);
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
%             name=char(sprintf('%d - %s [%d,%d]',obj.ID,obj.CurPath,obj.VarSz(1),obj.VarSz(2)));
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
            obj.T(obj.Row).CurrArr=obj.CurrArrIdx;
            obj.T(obj.Row).ID=obj.Row;
            obj.T(obj.Row).ArrType=obj.CurrArrName;
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
%                 if obj.Child==1
            obj.Row=obj.Row+1;
%                 end
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

