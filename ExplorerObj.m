classdef ExplorerObj < handle
    %This object purpose is to start either aplication gui or create object
    %for exploring, storing projects data and using whole system in
    %general. There are two main regimes:
    %1. With GUI
    %2. With scripts
    
    
    properties
        App;
        DbConn;
        Core;
        Users;
    end
    

    
    methods
        function obj = ExplorerObj(type)
            
            if type==true
                obj.App=ProjectExplorer(obj);
            end
            
            obj.Users=Users(obj);
            
            obj.DbConn=DbConn(obj);
            obj.Core=CoreObj;
        end
        
    end
end

