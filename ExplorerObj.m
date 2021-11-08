classdef ExplorerObj < handle
    %This object purpose is to start either aplication gui or create object
    %for exploring, storing projects data and using whole system in
    %general. There are two main regimes:
    %1. With GUI
    %2. With scripts
    
    
    properties
%         App=[];
        DbConn;
        Core;
        Users;
        AppRunning=0;
    end
    
    properties
        RootFolder;
        MasterFolder;
        SandBoxFolder;
        CurrentUser;
        ClientPCName;
        KeyFileName;
    end
    
    properties (Access=private)
        Regime=0; %0 without app ; 1=with app
    end
    
    events
        GetConn;
    end
    
    methods %open functions
        function obj = ExplorerObj(type)
            arguments 
                type (1,1) logical;
            end
            
            obj.Regime=type;
            
            
            GetCurrPc(obj);
           
            obj.Users=Users(obj); 
            obj.DbConn=DbConn(obj,obj.Users);
            obj.Core=CoreObj(obj);
            
            
            obj.SandBoxFolder=obj.Users.UserOptions.SandBoxFolder;
            OpenStructure(obj);
        
        end
        
        function list=GetProjectList(obj)
            list=obj.Core.ProjectOverview.ProjectList;
        end
        
        function plt=GetProject(obj,varargin)
            names=obj.Core.ProjectOverview.ProjectList.Name;
            nums=1:1:numel(names);
            row=0;
            if numel(varargin)==1
                switch class(varargin{1})
                    case 'double'
                        if isnumeric(varargin{1}) && varargin{1}<=obj.Core.ProjectOverview.ProjectCount
                            row=varargin{1};
                            
                        end
                    case 'char'
                        A=contains(names,varargin{1});
                        if sum(A)==0
                            row=0;
                        elseif sum(A)==1
                            row=A;
                        elseif sum(A)>0
                            row=0;
                        end
                    case 'string'
                        A=contains(names,varargin{1});
                        if sum(A)==0
                            row=0;
                        elseif sum(A)==1
                            row=A;
                        elseif sum(A)>0
                            row=0;
                        end
                end
                
                if nums(row)>0 && obj.Core.ProjectOverview.ProjectList.State(row)==1
                    plt=obj.Core.ProjectOverview.Projects(row);
                    fprintf("--Retrived Project '%s'--\n",names(row));
                else
                    plt=[];
                    fprintf("Project '%s' is deactivated. Activate it before further work\n",names(varargin{1}));
                end
            else
                
            end
            
        end
        
    end
    
    methods (Access=private)
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
        
        
        function OpenStructure(obj)
            if obj.Regime==1 && obj.AppRunning==0
                

                AssociateApp(obj.Core);
                if obj.DbConn.Status==true
                    CreateOverview(obj.Core);
                end
            else
                if obj.DbConn.Status==true
                    CreateOverview(obj.Core);
                end
            end
        end
        
        function GetCurrPc(obj)
            obj.RootFolder=matlabroot;                        
            obj.MasterFolder=strrep(which('ExplorerObj'),'ExplorerObj.m','');
            
            obj.CurrentUser=getenv('USERNAME');
            obj.ClientPCName=getenv('COMPUTERNAME');
        end
    end
    
    

end

