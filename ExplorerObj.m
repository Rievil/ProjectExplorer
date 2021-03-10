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
    
    properties
        RootFolder;
        MasterFolder;
        CurrentUser;
        ClientPCName;
        KeyFileName;
    end
    
    events
        GetConn;
    end
    
    methods
        function obj = ExplorerObj(type)
            
            GetCurrPc(obj);
            
            obj.Users=Users(obj);            
            obj.DbConn=DbConn(obj);
%             obj.Core=CoreObj;
            obj.GetConn=addlistener();
            if type==true
%                 obj.App=ProjectExplorer(obj);
            end  
        end
        
        function GetCurrPc(obj)
            obj.RootFolder=matlabroot;                        
            obj.MasterFolder=strrep(which('ExplorerObj'),'\ExplorerObj.m','');
            obj.CurrentUser=getenv('USERNAME');
            obj.ClientPCName=getenv('COMPUTERNAME');
        end
    end
    
    methods %events

    end
end

