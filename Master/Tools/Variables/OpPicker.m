classdef OpPicker < Item
    %OPPICKER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        List;
        Type;
        SelBool=false;
        VarSmith;
        UITree;
        CurrOperator;
        UITextArea;
    end
    
    events
        eOperator;
    end
    
    methods
        function obj = OpPicker(parent)
            obj@Item;
            obj.Parent=parent;

        end
        
        function List=CreateList(obj)
            obj.List=struct;
            obj.List(1).Name='Variables';
            obj.List(1).Functions={'Variables'};
            obj.List(1).Class={'OPVarTake'};
            
            obj.List(2).Name='Matematics';
            obj.List(2).Functions={'1DInterpolate','Sorting','Unique','Concat'};
            obj.List(2).Class={'OPInter','OPSort','OPUnique','OPNumConcat'};
            
            obj.List(3).Name='Statistics';
            obj.List(3).Functions={'Mean','Min','Max','Standart deviation'};
            obj.List(3).Class={'OPMean','OPMin','OPMax','OPStdt'};
            
            obj.List(4).Name='Acoustic operations';
            obj.List(4).Functions={'Cummulative','Localize'};
            obj.List(4).Class={'OPCumm','OPLokalize'};
            
            obj.List(5).Name='String operations';
            obj.List(5).Functions={'Concat'};
            obj.List(5).Class={'OPStrConcat'};
        end
        
        function FillList(obj)
            CreateList(obj);
            for i=1:size(obj.List,2)
                father=uitreenode(obj.UITree,'Text',obj.List(i).Name,'NodeData',0);
                for j=1:numel(obj.List(i).Functions)
                    uitreenode(father,'Text',obj.List(i).Functions{j},'NodeData',obj.List(i).Class{j});
                end
            end
        end
        
        function SetSmith(obj,smith)
            obj.VarSmith=smith;
        end
        
        function OpenWindow(obj)
            obj.Fig=uifigure('Name','Pick the operator');
            obj.Fig.CloseRequestFcn=@obj.MOutType;
        end
        
        function PickOperator(obj)
            Last=obj.VarSmith.LastOperator;
            
            test=exist(obj.CurrOperator);
            if test>0
                obj2=OpPicker.GetType(obj.CurrOperator);
                obj2.VarSmith=obj.VarSmith;
                SetParent(obj2,Last);
                obj.Type=obj2;
            else
                obj.Type=[];
                obj.CurrOperator=0;
            end
        end
        
        function CloseWindow(obj)
            close(obj.Fig)
            obj.Type=[];
        end
        
        function close(obj)
            if obj.SelBool==0
                obj.Type=[];
            end
        end
        
        function MOutType(obj,src,~)
%             if obj.SelBool==0
%                 obj.Type='';
%             end
%             disp('test');
            obj.Type=[];
            delete(obj.Fig);
        end
    end
    
    methods %abstract
        function DrawGui(obj)
            OpenWindow(obj);
            ClearGUI(obj);
            g=uigridlayout(obj.Fig);

            g.ColumnWidth = {350,'1x'};
            g.RowHeight = {'1x',25};
            
            tree=uitree(g,'SelectionChangedFcn',@obj.MOperatorSelected);
            tree.Layout.Row=1;
            tree.Layout.Column=1;
            obj.UITree=tree;
            
            p=uipanel(g,'Title','Operator description');
            p.Layout.Row=1;
            p.Layout.Column=2;
            FillList(obj);
            
            but1=uibutton(g,'Text','Select operator','ButtonPushedFcn',@obj.MSelectOperator);
            but1.Layout.Row=2;
            but1.Layout.Column=2;
            
            g2=uigridlayout(p);

            g2.ColumnWidth = {'1x'};
            g2.RowHeight = {'1x'};
            
            obj.UITextArea=uitextarea(g2,'Editable','off');
            obj.UITextArea.Layout.Row=1;
            obj.UITextArea.Layout.Column=1;
        end
        
        function stash=Pack(obj)
            
        end
        
        function Populate(obj)
            
        end
    end
    
    methods %callbacks
        function MOperatorSelected(obj,src,~)
            obj.CurrOperator=src.SelectedNodes.NodeData;
            if obj.CurrOperator~=0
                PickOperator(obj);
                if ~isempty(obj.Type)
                    obj.UITextArea.Value=obj.Type.Description;
                else
                    obj.UITextArea.Value={'... under construction ... please be patient'};
                end
            end
        end
        
        function MSelectOperator(obj,src,~)
            if obj.CurrOperator~=0

                obj.Type.ChAddOperator(obj.Type);

            end
            close(obj.Fig);
        end
    end
    
    methods (Static)
        function obj2=GetType(name)
            obj2=feval(name);
        end
    end
        
end

