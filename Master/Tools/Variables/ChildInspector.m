classdef ChildInspector < Inspector
    properties
        Parent;
        MainParent;
%         Depth=0;
    end
    
    methods
        function obj=ChildInspector(InArr,parent)
            obj@Inspector('data',InArr);
            obj.Child=1;            
            obj.Parent=parent;
            obj.Node=obj.Parent.ChildNode;
            obj.MainParent=FindParent(obj);
            obj.IconPath=obj.Parent.IconPath;
            Run(obj);
        end
        
        function parent=FindParent(obj)
            obj.Depth=1;
            parent=obj.Parent;
            while parent.Child==1
                parent=parent.Parent;
                obj.Depth=obj.Depth+1;
            end
        end
    end
end