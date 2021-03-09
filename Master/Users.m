classdef Users
    properties (SetAccess = public)
        UserOptions;
        MA; %link to mother app
        CurrentUserID; %current id of user
        CurrentUser; %current user
        RootFolder;
    end
    
    methods (Access = public)
        %start the object
        function obj=Users(MA)
            obj.RootFolder=matlabroot;
            obj.MA=MA;
            obj.CurrentUser=getenv('COMPUTERNAME');
            
            if isfile([obj.MA.MasterFolder 'UserOptions.mat'])
                %load UserOptions structure
                load([obj.MA.MasterFolder 'UserOptions.mat'],'-mat','UserOptions');
                obj.UserOptions=UserOptions;
            else
                %ask user to create DefaultOptions structure
                obj.UserOptions=[obj.UserOptions; CreateNewUserOptions(obj)];
                SaveUserOptions(obj);
            end
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
        function SaveUserOptions(obj)
            UserOptions=obj.UserOptions;
            save ([obj.MA.MasterFolder 'UserOptions.mat'],'UserOptions');
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