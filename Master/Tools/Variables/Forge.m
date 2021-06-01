classdef Forge < Item
    %FORGE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Variables (1,:);
        UIVarName;
        UIVarDesc;
        VarPanel;
        
        UIList;
        CurrVariable;
        
        OperatorPanel;
        
%         eChange;
        OperatorPicker;
    end
    
    properties (Dependent)
        VarList;
        Count;
    end
    
    methods
        function obj = Forge(parent)
            obj@Item;
            obj.Parent=parent;
            obj.OperatorPicker=OpPicker(obj);
        end
        
        function Operations(obj)
            InterCat={'1D Interpolation','2D Interpolation'};
            ArrCat={'Normalize','Limit'};
            TimeCat={'ToNumber','ToTime','Reduce to start time'};
        end
        
        function list=ListOperators(obj)
            list={'Adress','ConCat','Inter'};
        end
        
        function Smith=AddVariable(obj)
            
            Smith=VarSmith(obj);
            SetParent(Smith,obj);
            if obj.FigBool==1
                SetGui(Smith,obj.Fig(2));
            end
            obj.Variables=[obj.Variables, Smith];
%             obj.Count=numel(obj.Variables);
            SetVariable(obj,obj.Count);
            
%             obj.eReload=addlistener(obj.Parent,'eReload',@obj.ReLoadData);
        end
        
        function num=get.Count(obj)
            num=numel(obj.Variables);    
        end
        
        function RemoveVariable(obj)
            if obj.Count>0
                if obj.CurrVariable>0 && obj.CurrVariable<=obj.Count
                    obj.Variables(obj.CurrVariable).delete;
                    obj.Variables(obj.CurrVariable)=[];
                else
                    obj.Variables(obj.Count).delete;
                    obj.Variables(obj.Count)=[];
                end
%                 obj.Count=numel(obj.Variables);
                obj.FillList;
            end
        end
        
        function SetVariable(obj,num)
            if obj.FigBool==1
                obj.CurrVariable=num;
                obj.UIVarName.Value=obj.Variables(obj.CurrVariable).Name;
                obj.UIVarDesc.Value=obj.Variables(obj.CurrVariable).Description;
                SetGui(obj.Variables(obj.CurrVariable),obj.Fig(2));
                DrawGui(obj.Variables(obj.CurrVariable));
            end
        end
        
        function VarChangeName(obj,newname)
            if obj.CurrVariable>0
                obj.Variables(obj.CurrVariable).Name=newname;
            end
        end
        
        function row=GetEmptyVariable(obj)
            num=zeros(1,1);
            name=strings(1,1);
            bool=logical(zeros(1,1));
            
            row=table(num,name,bool,'VariableNames',{'ID','Name','Index'});
%             row.Properties.VariableNames={'ID','Name','Index'};
        end
        
        function type=DrawPickFig(obj)
            OpenWindow(obj.OperatorPicker);
            DrawGui(obj.OperatorPicker);
%             type=obj.OperatorPicker.Type;
        end
        
        function list=get.VarList(obj)
            list=strings(obj.Count,1);
            for i=1:obj.Count
                list(i,1)=obj.Variables(i).Name;
            end
        end
        
        function FillList(obj)
            obj.UIList.Items=obj.VarList;
            obj.UIList.ItemsData=1:1:obj.Count;
        end
    end
    
        methods %abstract
            function DrawGui(obj)
                ClearGUI(obj);
                g=uigridlayout(obj.Fig(1));
                g.ColumnWidth = {'1x'};
                g.RowHeight = {'1x',25,25,25,25,25,'1x'};
                
                lbox = uilistbox(g,'ValueChangedFcn',@obj.MSetVariable);
                lbox.Layout.Row=1;
                lbox.Layout.Column=1;
                obj.UIList=lbox;
                

                
                
                but1=uibutton(g,'Text','New variable','ButtonPushedFcn',@obj.MAddVariable);
                but1.Layout.Row=2;
                but1.Layout.Column=1;
                
                but1=uibutton(g,'Text','Remove variable','ButtonPushedFcn',@obj.MRemoveVariable);
                but1.Layout.Row=3;
                but1.Layout.Column=1;
                
                lbl= uilabel(g,'Text','Name of variable:');
                lbl.Layout.Row=4;
                lbl.Layout.Column=1;
                
                nametext=uieditfield(g,'ValueChangedFcn',@obj.MVarNameChange);
                nametext.Layout.Row=5;
                nametext.Layout.Column=1;
                obj.UIVarName=nametext;
                

                
                lbl2= uilabel(g,'Text','Variables description:');
                lbl2.Layout.Row=6;
                lbl2.Layout.Column=1;
                
                textarea = uitextarea(g,'Value','','ValueChangedFcn',@obj.SetDescription);
                textarea.Layout.Row=7;
                textarea.Layout.Column=1;
                obj.UIVarDesc=textarea;
                
                if obj.Count>0
                    FillList(obj);
                    if obj.CurrVariable>0 && obj.CurrVariable<=obj.Count
                        SetGui(obj.Variables(obj.CurrVariable),obj.Fig(2));
                        DrawGui(obj.Variables(obj.CurrVariable));
                        nametext.Value=obj.Variables(obj.CurrVariable).Name;
                        lbox.Value=obj.CurrVariable;
                        obj.UIVarDesc.Value=obj.Variables(obj.CurrVariable).Description;
                    else
                        SetGui(obj.Variables(1),obj.Fig(2));
                        DrawGui(obj.Variables(1));
                        nametext.Value=obj.Variables(1).Name;
                    end
                else
                    lbox.Items={''};
                    lbox.ItemsData=[];
                end
                
                obj.FigBool=1;
            end
        
        
            function stash=Pack(obj)
                stash=struct;
                stash.Count=obj.Count;
                stash.CurrVariable=obj.CurrVariable;
                n=0;
                for VS=obj.Variables
                    n=n+1;
                    TMP=Pack(VS);  
                    stash.Variables(n)=TMP;
                end
            end
            
            function Populate(obj,stash)
%                 obj.Count;
                obj.CurrVariable=stash.CurrVariable;
                for i=1:stash.Count
                    Smith=AddVariable(obj);
                    Smith.Populate(stash.Variables(i));
                end
            end
        end
        
        methods %callbacks
            function MSetVariable(obj,src,~)
                SetVariable(obj,src.Value);
            end
            
            function MAddVariable(obj,src,~)
                obj.AddVariable;
                obj.FillList;
                obj.UIList.Value=obj.Count;
            end
            
            function MRemoveVariable(obj,src,~)
                obj.RemoveVariable;
                obj.FillList;
            end
            
            function MVarNameChange(obj,src,~)
                if obj.Count>0 && obj.CurrVariable>0
                    VarChangeName(obj,src.Value);
                    FillList(obj);
                end
            end
            
            function SetDescription(obj,src,~)
                if obj.CurrVariable>0
                    obj.Variables(obj.CurrVariable).Description=src.Value;
                end
            end
        end
end

