classdef PlotGroup < Item
    %First node in plotter tree, all plots are orginized to plotgroups,
    %where next is figureconcept, and its child figures (1 | n), plotgroup
    %is important, for there is one plotter for whole project, data from
    %multiple experiments may appear in same figure
    
    
    properties
        ID;
        FigureConcepts;
        TreeNode;
        Name;
    end
    
    properties (Dependent)
        Count;
    end
    
    methods
        function obj = PlotGroup(parent)
            obj.Parent=parent;
        end
        
        function SetName(obj,name)
            obj.Name=name;
        end
        
        function count=get.Count(obj)
            count=numel(obj.FigureConcepts);
        end
        
        function FillNode(obj)
            tree=obj.Parent.UITree;
            UITab=OperLib.FindProp(obj,'UIFig');
            
            iconfilename=[OperLib.FindProp(obj,'MasterFolder') 'Master\Gui\Icons\PlotGroup.gif'];
            obj.TreeNode=uitreenode(tree,'Text',obj.Name,'NodeData',{obj,'plotgroup'},...
                'Icon',iconfilename,'CreateFcn',@obj.MChangeName);
            
            cm = uicontextmenu(UITab,'UserData',obj);
            
            
            m1 = uimenu(cm,'Text','Remove plot group',...
                'MenuSelectedFcn',@obj.MRemovePlotGroup);
            m2 = uimenu(cm,'Text','New figure concept',...
                'MenuSelectedFcn',@obj.MNewFigureConcept);
            
            obj.TreeNode.ContextMenu=cm;
            
            for i=1:obj.Count
                obj.FigureConcepts{i}.FillNode;
            end
        end
        
        function Remove(obj)
            obj.Parent.RemovePlotGroup(obj.ID);
            delete(obj.TreeNode);
            delete(obj);
        end
        
        function NewConceptFigure(obj)
            obj2=FigureConcept(obj);
            id=obj.Count+1;
            obj2.ID=id;
            obj2.SetName(char(sprintf('Figure concept %d',id)));
            
            obj.FigureConcepts{id}=obj2;
            FillNode(obj2);
        end
        
        function RemoveConceptFigure(obj,id)
            obj.FigureConcepts(id)=[];
            n=0;
            for i=1:obj.Count
                obj.FigureConcepts{i}.ID=i;
            end
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
        function MRemovePlotGroup(obj,src,~)
            Remove(obj);
        end
        
        function MNewFigureConcept(obj,src,~)
%             disp('MNewFigureConcept');
            NewConceptFigure(obj);
        end
        
        function delete(obj)
            for i=1:obj.Count
                delete(obj.FigureConcepts);
            end
        end
        
        function MChangeName(obj,src,~)
            disp('MChangeName');
        end
    end
end

