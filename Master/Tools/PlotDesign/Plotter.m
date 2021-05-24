classdef Plotter < Node
    %VAREXP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        PlotObj;
        TreeNode;
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
        
        function Populate(obj,stash)
%             obj.Inspector.T=stash.Inspector;
        end
    end
    
    methods %GUI

        
        function InitializeOption(obj)
            SetParent(obj,'project');
            Clear(obj);
%             g=uigridlayout(obj.GuiParent);
%             g.RowHeight = {22,'1x'};
%             g.ColumnWidth = {'1x',50};
% %             
% 
%             
%             la=uilabel(g,'Text','Variables used in experiment:');
%             la.Layout.Row=1;
%             la.Layout.Column=1;
%             
%             but1=uibutton(g,'Text','Check variables',...
%                 'ButtonPushedFcn',@obj.CheckVar);
%                         
%             but1.Layout.Row=1;
%             but1.Layout.Column=2;
%             
%             p = uipanel(g,'Title','Options','FontSize',12);
%             p.Layout.Row=2;
%             p.Layout.Column=[1 2];
%             
%             g2=uigridlayout(p);
%             g2.RowHeight = {'1x'};
%             g2.ColumnWidth = {'1x','1x'};
%             
% 
%             
%             uit=uitable(g2);
%             uit.Layout.Row=1;
%             uit.Layout.Column=1;
%             uit.Data=GetEmptyVar(obj);
            

        end
        
        
    end
end

