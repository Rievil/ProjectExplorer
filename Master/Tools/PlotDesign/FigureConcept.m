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
        
        function obj2=MakeSpecificPlot(obj,name)
            switch name
                case 'PlotPlot'
                    obj2=PlotPlot(obj);
                otherwise
            end
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
            stash=struct;
            stash.ID=obj.ID;
            stash.Name=obj.Name;
            if isvalid(obj.PlotType)
                stash.PlotType=CoPack(obj.PlotType);
            end
        end
        
        function Populate(obj,stash) 

            obj.ID=stash.ID;
            obj.Name=stash.Name;
            if isvalid(stash.PlotType)
                obj2=obj.MakeSpecificPlot(stash.PlotType.Name);
                obj2.CoPopulate(stash.PlotType);
                obj2.PlotType=obj2;
            end
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

