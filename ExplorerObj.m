classdef ExplorerObj < handle
    %This object purpose is to start either aplication gui or create object
    %for exploring, storing projects data and using whole system in
    %general. There are two main regimes:
    %1. With GUI
    %2. With scripts
    
    
    properties
        App=[];
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
    
    properties (Access=private)
        Regime; %0 without app ; 1=with app
    end
    
    events
        GetConn;
    end
    
    methods
        function obj = ExplorerObj(type)
            obj.Regime=type;
            GetCurrPc(obj);
            
            obj.Users=Users(obj);            
            obj.DbConn=DbConn(obj,obj.Users);
            obj.Core=CoreObj(obj);

            OpenStructure(obj);
        end
        
        function OpenStructure(obj)
            if obj.DbConn.Status==true
%                 SetUserDetails(obj.Users);
                if obj.Regime==1
                    if isempty(obj.App)
                        obj.App=ProjectExplorer(obj);
                        obj.Core.App=obj.App;
                    end
                end
                CreateOverview(obj.Core);
            end
        end
        
        function GetCurrPc(obj)
            obj.RootFolder=matlabroot;                        
            obj.MasterFolder=strrep(which('ExplorerObj'),'\ExplorerObj.m','');
            obj.CurrentUser=getenv('USERNAME');
            obj.ClientPCName=getenv('COMPUTERNAME');
        end
    end
    
    methods 
        function result=ParentCare(obj,name)
            switch name
                case 'sandbox'
                    result=obj.Users.UserOptions.SandBoxFolder;
                case 'masterfolder'
                    result=obj.Users.UserOptions.MasterFolder;
                otherwise
                
                    
            end
        end
        
        function stash=Pack(obj)
            stash=Pack(obj.Core.ProjectOverview);
        end
    end
    
    

end

