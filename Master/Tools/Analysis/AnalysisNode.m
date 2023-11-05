classdef AnalysisNode < Node
    %ANALYSISNODE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Property1
    end
    
    methods
        function obj = AnalysisNode(parent)
            obj.Parent=parent;
        end
    end

    methods %abstract
        function FillUITab(obj,Tab)
            p=OperLib.FindProp(obj,'UITab');
            SetGuiParent(obj,p);
            InitializeOption(obj);
        end
        
        function FillNode(obj)
            obj.TreeNode=uitreenode(obj.Parent.TreeNode,'Text','Analysis','NodeData',{obj,'analysis'});
        end
        
        function ClearIns(obj)
        end
        
        function stash=Pack(obj)
            stash=struct;
            
            if ~isempty(obj.PlotGroups)
                for i=1:numel(obj.PlotGroups)
                    TMP=Pack(obj.PlotGroups{i});
                    stash.PlotGroups{i}=TMP;
                end
            end
        end
        

        
        function Populate(obj,stash)
%             obj.Inspector.T=stash.Inspector;
            if isfield(stash,'PlotGroups')
                for i=1:size(stash.PlotGroups,2)
                    obj2=PlotGroup(obj);
                    obj2.Populate(stash.PlotGroups{i});
                    obj.PlotGroups{i}=obj2;
                end
            end
        end
        
        function node=AddNode(obj)
            
        end
        
        function Tout=GetSampleData(obj,exp,sel)
           
        end
    end

    methods %gui
        function InitializeOption(obj)
            SetParent(obj,'project');
            Clear(obj);
            
            UITab=OperLib.FindProp(obj,'UIFig');
            g=uigridlayout(obj.GuiParent);
            g.RowHeight = {22,'1x'};
            g.ColumnWidth = {150,'1x'};
            
        end

    end

end

