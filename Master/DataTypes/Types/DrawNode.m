classdef DrawNode < handle
    %DRAWNODE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
            
    end
    

    
    methods
        function obj = DrawNode(~)        
            obj.GUIParents=struct('Parent',[],'Class',[],'Name',[]);
        end
        
        function AddParent(obj,parent,name)
            sz=size(obj.GUIParents.Parent,2);            
            obj.GUIParents(sz+1).Parent=parent;
            obj.GUIParents(sz+1).Class=class(parent);
            obj.GUIParents(sz+1).Name=lower(name);
        end
        
        function p=GetParent(obj,in)
            sz=size(obj.GUIParents,1);
            switch class(in)
                case 'char'
                    %getting by name
                    for i=1:sz
                        if strcmp(in,obj.GUIParents(i).Name)
                            find=i;
                            break;
                        else 
                            find=0;
                        end
                    end
                case 'double'
                    %getting by number
                    find=in;
            end
            
            if find<=sz && find>0
                p=obj.GUIParents(n).Parent;            
            else
                warning('You try to get parent index which was not defined!');
                p=[];
            end
        end
        
    end
end

