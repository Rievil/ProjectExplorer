classdef OPVarTake < Operator
    %INTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Adress;
        AdressLabel;
        Inspector;
        UITable;
        CurrAdress;
    end

    properties (Dependent)
        Count;
        VarList;
    end

    
    methods
        function obj = OPVarTake(~)
            obj@Operator;
            obj.Name='OPVarTake';
            obj.Title='Select variables';

            obj.Description={'Select variables from measurements using Variable inspector.';...
                'You can select multiple variables of uniform shape:';
                '   -same number of rows, or same number of columns';
                '   -select what type of variables and categorize them.'};
            
        end
        
        function list=get.VarList(obj)
            list=strings(obj.Count,1);
            for i=1:obj.Count
                list(i,1)=obj.Adress{i}.Label;
            end
        end


        function num=get.Count(obj)
            num=numel(obj.Adress);
        end

        function AddAdress(obj,adress)
            id=obj.Count+1;
            obj.Adress{id}=adress;
            DrawInput(obj);
        end


    end
    
    methods %abstract
        function DrawGui(obj)
            g=uigridlayout(obj.Fig);

            g.ColumnWidth = {150,'1x',100,100};
            g.RowHeight = {25,'2x','1x',25};
            
            lbl = uilabel(g,'Text','Select variables from measurements:');
            lbl.Layout.Row=1;
            lbl.Layout.Column=1;
            
            but1=uibutton(g,'Text','Add adress','ButtonPushedFcn',@obj.MAddAdress);
            but1.Layout.Row=1;
            but1.Layout.Column=3;

            but1=uibutton(g,'Text','Remove adress','ButtonPushedFcn',@obj.MRemoveAdress);
            but1.Layout.Row=1;
            but1.Layout.Column=4;
            
            uit=uitable(g,'CellSelectionCallback',@obj.MCellSelected,...
                        'CellEditCallback',@obj.MCellEdit);
            obj.UITable=uit;

            if obj.Count>0
                DrawInput(obj);
            end

            uit.Layout.Row=2;
            uit.Layout.Column=[1 4];
            
            
        end
        
        function DrawInput(obj)
            T=table;
            for i=1:numel(obj.Adress)
                T=[T; GetRow(obj.Adress{i})];
%                 if numel(obj.AdressLabel)>0
%                     if i<=numel(obj.AdressLabel)
%                         T=[T; table(obj.AdressLabel(i),obj.Adress{i}.OrigName,obj.Adress{i}.Type,obj.Adress{i}.Size,...
%                             'VariableNames',{'Label','Name','Type','Size'})];
%                     else
%                         T=[T; table(string(sprintf('Adress %d',i)),obj.Adress{i}.OrigName,obj.Adress{i}.Type,obj.Adress{i}.Size,...
%                             'VariableNames',{'Label','Name','Type','Size'})];
%                     end
%                 else
%                     T=[T; table(string(sprintf('Adress %d',i)),obj.Adress{i}.OrigName,obj.Adress{i}.Type,obj.Adress{i}.Size,...
%                         'VariableNames',{'Label','Name','Type','Size'})];
%                 end

                
            end

            if numel(obj.Adress)>0
                obj.AdressLabel=T.Label;
                obj.UITable.Data=T;
                obj.UITable.ColumnEditable =[true,false,false,false,false];
            else
                obj.UITable.Data=[];
            end
        end
        
        function RunTool(obj,data)
            for i=1:numel(obj.Adress)
                obj.Output{i}=GetVar(obj.Adress{i},data);
            end
        end
        
        function stash=Pack(obj)
            stash=struct;
            for i=1:obj.Count
                stash.Adress(i)=Pack(obj.Adress{i});
            end
        end
        
        function Populate(obj,stash)
            if isfield(stash,'Adress')
                for i=1:size(stash.Adress,2)
                    adress=Adress(obj);
                    Populate(adress,stash.Adress(i));
                    obj.Adress{i}=adress;
                end
            end
        end
    end
    
    methods %callbacks
        function MAddAdress(obj,src,~)
            obj.Inspector=GetInspector(obj);
            obj.Inspector.Fig=0;
            varExp=GetVarExp(obj);
%             CheckVar(obj,evnt,src);
            CheckVar(varExp);
            
        end
        
        function MCellEdit(obj,src,evnt)
            obj.CurrAdress=evnt.Indices(1);
            obj.Adress{obj.CurrAdress}.Label=join(string(src.Data.Label(obj.CurrAdress)));
        end

        function MRemoveAdress(obj,src,~)
            if obj.CurrAdress>0 && obj.CurrAdress<=obj.Count
                delete(obj.Adress{obj.CurrAdress});
                obj.Adress(obj.CurrAdress)=[];
                obj.AdressLabel(obj.CurrAdress)=[];
                DrawInput(obj);
            end
        end
        
        function MCellSelected(obj,src,evnt)
            obj.CurrAdress=evnt.Indices(1);
        end
        
        
    end
end

