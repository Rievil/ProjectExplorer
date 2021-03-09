classdef Users
    properties (SetAccess = public)
        UserOptions;
        
        MasterFolder; %link to mother app
        CurrentUserID; %current id of user
        CurrentUser; %current windows username
        ClientPCName; %current user pc    
        RootFolder; %matlab root folder        
        
        SandBoxFolder;
        
        UserID;
        UserName;
    end
     
    properties (Access = private)
        Parent;
    end
    
    methods (Access = public)
        %start the object
        function obj=Users(~)
            
            obj.RootFolder=matlabroot;            
            
            GetAppPath(obj);
            GetCurrentPc(obj);
            
            if isfile([obj.RootFolder '\UserOptions.mat'])
                %load UserOptions structure
                load(obj);
            else
                %ask user to create DefaultOptions structure
                obj.UserOptions=[obj.UserOptions; CreateNewUserOptions(obj)];
                SaveUserOptions(obj);
            end
        end
        
        function GetAppPath(obj)
            app.MasterFolder=strrep(which('ProjectExplorer'),'App\ProjectExplorer.mlapp','');
        end
        
        function GetCurrentPc(obj)
            obj.ClientPCName=getenv('COMPUTERNAME');
        end
        
        function GetPCUserName(obj)
            obj.CurrentUser=getenv('USERNAME');
        end
        
        %check what current user is
        function obj=CheckUser(obj)
            
            A=ismember({obj.UserOptions.User},obj.CurrentUser);
            if sum(A)>0
                %daný uživatel už existuje v seznamu
                obj.CurrentUserID=obj.UserOptions(A).ID;
            else
                %daný uživatel neexistuje v seznamu
                IDArr=double(obj.UserOptions.ID);
                obj.CurrentUserID=max(IDArr)+1;
                obj.UserOptions=[obj.UserOptions; CreateNewUserOptions(obj)];
            end            
            obj.MA.UserID=obj.CurrentUserID;
        end
                
        %save user options into masterfolder
        function Save(obj)
            tmp=parent;
            obj.Parent=[];
            save ([obj.RootFolder '\PEUser.mat'],'obj');
            obj.Parent=tmp;
        end
        
        function Load(obj2)
            load([obj2.RootFolder '\PEUser.mat'],'obj');
            obj2=obj;
        end
    end  
    
    methods (Access = private)
        %create new user options in case its new instalation
        function [NewUser]=CreateNewUserOptions(obj)
            %space for parameters of user defined options
            NewUser=struct;
            NewUser.ID=obj.CurrentUserID;
            NewUser.User=obj.CurrentUser;
            NewUser.MasterFolder=obj.MA.MasterFolder;
            NewUser.SandBoxFolder=[uigetdir(cd,'Select folder for saving all work') '\'];
            %obj.UserOptions=UserOptions;
        end
    end
end