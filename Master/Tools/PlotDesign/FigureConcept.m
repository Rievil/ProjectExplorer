classdef FigureConcept < Item
    %FigureConcept is specific object, which will draw variables to figures
    %It may have 1 outfigure, or n-outfigures, with fixed plot type
    %It can be easily copied
    %It has language versions, where labels and formating is versioned
    
    properties
        ID;
        Name;
        PlotType;
        TreeNode;
    end
    
    methods
        function obj = FigureConcept(parent)
            obj.Parent=parent;
        end
        
        function SetName(obj,name)
            obj.Name=name;
        end
        
        function Remove(obj)
            obj.Parent.RemoveConceptFigure(obj.ID);
            delete(obj.TreeNode);
            delete(obj);
        end
        
         function FillNode(obj)
            parentnode=obj.Parent.TreeNode;
            UITab=OperLib.FindProp(obj,'UIFig');
            
            iconfilename=[OperLib.FindProp(obj,'MasterFolder') 'Master\Gui\Icons\FigureConcept.gif'];
            obj.TreeNode=uitreenode(parentnode,'Text',obj.Name,'NodeData',{obj,'figureconcept'},...
                'Icon',iconfilename);
            
            cm = uicontextmenu(UITab,'UserData',obj);
            
            
            m1 = uimenu(cm,'Text','Remove figure concept',...
                'MenuSelectedFcn',@obj.MRemoveFigureConcept);
            m2 = uimenu(cm,'Text','New plot',...
                'MenuSelectedFcn',@obj.MNewPlot);
            
            obj.TreeNode.ContextMenu=cm;
        end

    end
    
    methods %abstract
        function DrawGui(obj)
            ClearGUI(obj);
            g=uigridlayout(obj.Fig(1));

        end
        
        function stash=Pack(obj) 
            
        end
        
        function Populate(obj,stash) 
            
        end
    end
    
    methods %callbacks
        function MRemoveFigureConcept(obj,src,~)
            Remove(obj);
%             disp('MRemoveFigureConcept');
        end
        
        function MNewPlot(obj,src,~)
            disp('MNewPlot');
        end
    end
    
end

