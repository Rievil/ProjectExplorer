classdef VarSmith < Item
    %SMITH Summary of this class goes here
    %   Detailed explanation goes here
    %'ID','Name','Coord','Size','Type'
    
    properties
        Operators;

        CurrOperator=0;
        ID;
        Name (1,1) string;
        Description cell;
        Coord;
        Size;
        Type;
        UIList;
        UIOpPanel;
        Index;
    end
    
    properties (Dependent)
        OperList;
        Count;
        LastOperator;
    end
    
    properties 
        eOperator;
    end
    
    methods
        function obj = VarSmith(parent)
            obj.Parent=parent;
            obj.ID=numel(obj.Parent.Variables)+1;
            obj.Name=sprintf('Variable %d',obj.ID);
            obj.Description={''};
%             obj.eOperator=addlistener(obj.Parent.OperatorPicker,'eReload',@obj.ReLoadData);
        end
        
        function obj2=get.LastOperator(obj)
            count=obj.Count;
            if count>0
                obj2=obj.Operators{count};
            else
                obj2=obj;
            end
        end
        
        function num=get.Count(obj)
            num=numel(obj.Operators);
        end
        
        function result=GetVariable(obj,data)
            obj.Operators{1}.RunCh(data);
            result=obj.Operators{obj.Count}.Output{:};
        end
        
        function OpenPicker(obj)
            Picker=obj.Parent.OperatorPicker;
            SetSmith(Picker,obj);
            DrawGui(Picker);
%             DrawPickFig(obj.Parent);
        end
        
        function AddOperator(obj,operator)
            SetGui(operator,obj.UIOpPanel);
            
            id=obj.Count+1;
            if id>1
                obj.Operators{id-1}.Children=operator;
                obj.Operators{id-1}.ChildrenBool=1;
            end

            obj.Operators{id}=operator;
            FillList(obj);
            if obj.FigBool==true
                DrawGui(obj.Operators{id});
                obj.UIList.Value=id;
            end
%             SetOperator(obj,obj.Count)
        end
          
        function list=get.OperList(obj)
            list=strings(obj.Count,1);
            for i=1:obj.Count
                list(i,1)=obj.Operators{i}.Title;
            end
        end
        
        function FillList(obj)
            obj.UIList.Items=obj.OperList;
            obj.UIList.ItemsData=1:1:obj.Count;
%             if obj.CurrOperator=0;
%                 obj.CurrOperator=1;
%             end
        end
        
        function RemoveOperator(obj)
            if obj.CurrOperator>0 && obj.CurrOperator<=obj.Count
                if obj.CurrOperator==obj.Count
                delete(obj.Operators{obj.CurrOperator});
                obj.Operators(obj.CurrOperator)=[];
                
                else
                    dif=obj.Count-obj.CurrOperator;
                    order=flip(obj.Count-dif:1:obj.Count);%linspace(obj.Count,obj.Count-dif,obj.Count-dif);
                    for i=order
                        delete(obj.Operators{i});
                        obj.Operators(i)=[];
                    end
                end
                obj.CurrOperator=0;
                FillList(obj);
            end
        end
        
        function SetOperator(obj,ID)
           obj.CurrOperator=ID; 
           obj.Operators{obj.CurrOperator}.SetGui(obj.UIOpPanel);
           obj.Operators{obj.CurrOperator}.OpDrawGui;
        end
    end
    
    methods %abstract
        function DrawGui(obj)
                ClearGUI(obj);
                g=uigridlayout(obj.Fig(1));

                g.ColumnWidth = {80,80,'3x'};
                g.RowHeight = {25,'1x'};
                
                lbox = uilistbox(g,'ValueChangedFcn',@obj.MSetOperator);
                lbox.Layout.Row=2;
                lbox.Layout.Column=[1 2];
                
                obj.UIList=lbox;
                
                p=uipanel(g,'Title','Operator settings');
                p.Layout.Row=[1 2];
                p.Layout.Column=3;
                obj.UIOpPanel=p;
                
                if obj.Count>0
                    FillList(obj);
                    if obj.CurrOperator>0
                        SetGui(obj.Operators{obj.CurrOperator},obj.UIOpPanel);
                        DrawGui(obj.Operators{obj.CurrOperator});
%                         nametext.Value=obj.Operators(obj.CurrOperator).Name;
                        lbox.Value=obj.CurrOperator;
%                         obj.UIVarDesc.Value=obj.Operators(obj.CurrOperator).Description;
                    else
                        SetGui(obj.Operators{1},obj.UIOpPanel);
                        DrawGui(obj.Operators{1});
%                         nametext.Value=obj.Operators(1).Name;
                    end
                else
                    lbox.Items={''};
                    lbox.ItemsData=[];
                end
                
                but2=uibutton(g,'Text','New operator','ButtonPushedFcn',@obj.MOpenPicker);
                but2.Layout.Row=1;
                but2.Layout.Column=1;
                
                but3=uibutton(g,'Text','Remove operator','ButtonPushedFcn',@obj.MRemoveOperator);
                but3.Layout.Row=1;
                but3.Layout.Column=2;
                
                
               
        end
        
        function stash=Pack(obj) 
            stash=struct;
            stash.ID=obj.ID;
            stash.Name=obj.Name;
            stash.Count=obj.Count;
            stash.Description=obj.Description;
            stash.Operators={};
            stash.CurrOperator=obj.CurrOperator;
            

            for n=1:obj.Count
                TMP=OpPack(obj.Operators{n});
                stash.Operators{n}=TMP;
            end
        end
        
        function Populate(obj,stash) 
            obj.ID=stash.ID;
            obj.Name=stash.Name;
            obj.Description=stash.Description;
            if isfield(stash,'CurrOperator')
                obj.CurrOperator=stash.CurrOperator;
            end
            
            n=0;
            for i=1:stash.Count
                n=n+1;
                obj2=OpPicker.GetType(stash.Operators{i}.Name);
                Last=obj.LastOperator;
                obj2.VarSmith=obj;
                SetParent(obj2,Last);
                OpPopulate(obj2,stash.Operators{i});
                AddOperator(obj,obj2);
            end
        end
    end
    
    methods %callbacks
        
        function MSetOperator(obj,src,~)
            ID=src.Value;
            obj.SetOperator(ID);
        end
        
        function MOpenPicker(obj,src,~)
            OpenPicker(obj);
        end
        
        function MRemoveOperator(obj,src,~)
            RemoveOperator(obj);
        end
    end
        
end

