classdef Node < OperLib & GUILib
    %NODE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Parent;
        TreeNode;
        
    end
    
    methods (Abstract)
        FillUITab(obj,Tab);
        FillNode(obj);
        stash=Pack(obj);
        node=AddNode(obj);
        Populate(obj);
        ClearIns(obj);
    end
    
    methods
        function obj = Node(~)
            obj@OperLib;
            obj@GUILib;

        end
        
        function save(obj)
            fprintf("Saved object '%s'",class(obj));
        end
        
        function delete(obj)
            fprintf("Delted object '%s'",class(obj));
        end
        
        function saveobj(obj)
            fprintf("Saved saveobj object '%s'",class(obj));
        end
%         function Clear(obj)
%             delete(obj.TreeNode);
%             obj.TreeNode=[];
%             ClearIns(obj);
%         end
        
%         function FillGhostNode(obj,label)
%             treenode=uitreenode(obj.Parent.TreeNode,...
%             'Text',obj.Name,...
%             'NodeData',{obj,label}); 
%             obj.TreeNode=treenode;
%         end
        
        
%         function sobj = saveobj(obj)
%             switch class(obj)
%                 case 'experiment'
%                 case 'projectoverview'
%                 case 'projectobj'
%                 case 'measobj'
%                 otherwise
%             end
%         end
        
        
    end
end

