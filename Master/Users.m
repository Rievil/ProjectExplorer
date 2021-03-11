classdef Users < handle
    properties (SetAccess = public)
        UserOptions;
        UserID;
        UserName;
    end
     
    properties (Access = private)
        Parent;
        Fig;
    end
    
    methods (Access = public)
        %start the object
        function obj=Users(parent)
            
            obj.Parent=parent;
% 
            if isfile([obj.Parent.RootFolder '\UserOptions.mat'])
                %load UserOptions structure
                Load(obj);
            else
                %ask user to create DefaultOptions structure
                obj.UserOptions=CreateNewUserOptions(obj);
                Save(obj);
            end
        end
             
        %save user options into matlab root
        function Save(obj)
            val=obj.UserOptions;
            save ([obj.Parent.RootFolder '\UserOptions.mat'],'val');
        end
        
        %save user options into matlab root
        function Load(obj)
            load([obj.Parent.RootFolder '\UserOptions.mat']);
            obj.UserOptions=val;
        end
    end  
    
    methods (Access = private)
        %create new user options in case its new instalation
        function [NewUser]=CreateNewUserOptions(obj)
            %space for parameters of user defined options
            NewUser=struct;
            
            NewUser.ID=[];
            NewUser.PCName=obj.Parent.ClientPCName;
            NewUser.UserName=obj.Parent.CurrentUser;
            NewUser.MasterFolder=obj.Parent.MasterFolder;
            NewUser.KeyFilename=[];
            NewUser.SandBoxFolder=[uigetdir(cd,'Select folder for saving all work') '\'];
            
            %NewUser.SandBoxFolder=[uigetdir(cd,'Select folder for saving all work') '\'];
            %obj.UserOptions=UserOptions;
        end
    end
    
    methods 
        function SetUserDetails(obj)
            screenDim=get(0,'ScreenSize');
            obj.Fig=uifigure('Name','User details options','Position',[screenDim(3)/2-350,screenDim(4)/2-200,700,400]);
            
            ef1 = uilabel(obj.Fig,'Text',['PC Name:           ' obj.UserOptions.PCName],'Position',[20 370 310 20]);
            ef1 = uilabel(obj.Fig,'Text',['Current user:      ' obj.UserOptions.UserName],'Position',[20 350 310 20]);
            ef1 = uilabel(obj.Fig,'Text',['App master folder: ' obj.UserOptions.MasterFolder],'Position',[20 330 310 20]);
            ef1 = uilabel(obj.Fig,'Text',['Key filename:      ' obj.UserOptions.KeyFilename],'Position',[20 310 310 20]);
            
        end
        
        
    end
end