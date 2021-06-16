classdef Plotter < Node
    %VAREXP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        PlotObj;
        TreeNode;
        UIList;
        UITabGroup;
        UIAxisPreviewTab;
        UIVarSpecSelectionTab;
        UIPlotPropertiesTab;
        UIExportTab;
        UIOperationsTab;
    end
    
    methods
        function obj = Plotter(parent)
            obj.Parent=parent;
%             obj.Inspector=Inspector;
        end
        


    end
    
    methods %abstract
        function FillUITab(obj,Tab)
            p=OperLib.FindProp(obj,'UITab');
            SetGuiParent(obj,p);
            InitializeOption(obj);
        end
        
        function FillNode(obj)
%             iconfilename=[OperLib.FindProp(obj,'MasterFolder') 'Master\Gui\Icons\SpecGroup.gif'];
            obj.TreeNode=uitreenode(obj.Parent.TreeNode,'Text','Plotter','NodeData',{obj,'plotter'});
        end
        
        function stash=Pack(obj)
            stash=struct;
%             stash.Inspector=obj.Inspector.T;
%             obj.Inspector
        end
        
        function node=AddNode(obj)
            
        end

        function DrawTest(obj)
            var1=obj.Parent.Experiments.VarExp.Forge.Variables(1, 1);
            var2=obj.Parent.Experiments.VarExp.Forge.Variables(1, 2);
            fig=figure;
            hold on;
            ax=gca;
            T=obj.Parent.Experiments.SpecGroup.Specimens(obj.Parent.Experiments.SpecGroup.Sel,:);

            for i=1:size(T,1)
                data=T.Data{i};
                x=GetVariable(var1,data);
                y=GetVariable(var2,data);
                plot(ax,x,y);
            end
            
        end

        function Populate(obj,stash)
%             obj.Inspector.T=stash.Inspector;
        end
    end
    
    methods %GUI

        
        function InitializeOption(obj)
            SetParent(obj,'project');
            Clear(obj);
            
            
            g=uigridlayout(obj.GuiParent);
            g.RowHeight = {22,'1x'};
            g.ColumnWidth = {150,'1x'};
            
            
            label = uilabel(g,'Text','Figure concepts');
            label.Layout.Row=1;
            label.Layout.Column=1;
            
            label2 = uilabel(g,'Text','Figure concept properties');
            label2.Layout.Row=1;
            label2.Layout.Column=2;
            
            lbox=uilistbox(g,'ValueChangedFcn',@obj.MSetFigConcept);
            lbox.Layout.Row=2;
            lbox.Layout.Column=1;
            obj.UIList=lbox;
            
            tabgroup=uitabgroup(g,'AutoResizeChildren',true);
            tabgroup.Layout.Row=2;
            tabgroup.Layout.Column=2;
            
            tab1 = uitab(tabgroup,'Title','Axis preview');
            tab2 = uitab(tabgroup,'Title','Variable and specimens selection');
            tab3 = uitab(tabgroup,'Title','Plot properties');
            tab4 = uitab(tabgroup,'Title','Export properties');
            tab5 = uitab(tabgroup,'Title','Custom operations');
            
            
            obj.UIAxisPreviewTab=tab1;
            obj.UIVarSpecSelectionTab=tab2;
            obj.UIPlotPropertiesTab=tab3;
            obj.UIExportTab=tab4;
            obj.UIOperationsTab=tab5;
            
            obj.UITabGroup=tabgroup;

        end
        
        
    end
    
    methods %callbacks
        function MSetFigConcept(obj,src,~)
           disp('MSetFigConcept'); 
        end
    end
end

