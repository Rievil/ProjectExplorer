classdef Users < handle
    properties (SetAccess = public)
        UserOptions;
        UserID;
        UserName;
        Status=0;
    end
     
    properties (Access = private)
        Parent;
        Fig;
    end
    
    events
        ChangedUser;
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
                SetUserDetails(obj);
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
            NewUser.KeyFilename=[''];
            NewUser.SandBoxFolder=[''];
            
            %NewUser.SandBoxFolder=[uigetdir(cd,'Select folder for saving all work') '\'];
            %obj.UserOptions=UserOptions;
        end
    end
    
    methods %change options of user setup
        function SetUserDetails(obj)
            screenDim=get(0,'ScreenSize');
            obj.Fig=uifigure('Name','User details options','Position',[screenDim(3)/2-350,screenDim(4)/2-200,700,400]);
            
            uilabel(obj.Fig,'Text','PC Name:','Position',[20 370 210 20]);
            uilabel(obj.Fig,'Text',[obj.UserOptions.PCName],'Position',[235 370 310 20]);
            
            uilabel(obj.Fig,'Text','Current user:','Position',[20 350 210 20]);
            uilabel(obj.Fig,'Text',[obj.UserOptions.UserName],'Position',[235 350 310 20]);
            
            uilabel(obj.Fig,'Text','App master folder:','Position',[20 330 210 20]);
            uilabel(obj.Fig,'Text',[obj.UserOptions.MasterFolder],'Position',[235 330 210 20]);
            
            uilabel(obj.Fig,'Text','Key filename:','Position',[20 310 210 20]);
            field=uieditfield(obj.Fig,'text','value',[obj.UserOptions.KeyFilename],'Position',[235 310 310 20]);
            uibutton(obj.Fig,'Text','Select key','Position',[550 310 100 20],...
                'ButtonPushedFcn',@(src,event)ChangeUserField(obj,event),'UserData',{'KeyFilename',field});
            
            uilabel(obj.Fig,'Text','Sandbox:','Position',[20 290 210 20]);
            field2=uieditfield(obj.Fig,'text','value',[obj.UserOptions.SandBoxFolder],'Position',[235 290 310 20]);
            uibutton(obj.Fig,'Text','Select key','Position',[550 290 100 20],...
                'ButtonPushedFcn',@(src,event)ChangeUserField(obj,event),'UserData',{'SandBoxFolder',field2});
            
            uibutton(obj.Fig,'Text','Save settings','Position',[20 350-100 100 30],...
                'ButtonPushedFcn',@(src,event)SaveAndClose(obj,event));
        end
        
        function ChangeUserField(obj,event)
            switch event.Source.UserData{1}
                case 'KeyFilename'
                    [file,path]=uigetfile('*.txt','Select FileKey');
                    keyfilename=[path,file];
                    if exist(keyfilename,'file')
                        event.Source.UserData{2}.Value=keyfilename;
                        obj.UserOptions.KeyFilename=keyfilename;
                        obj.notify('ChangedUser');
                        Save(obj);
                    else
                        uialert(obj.Fig,'File doesnt exists','Select different file');
                        event.Source.UserData{2}.Value=obj.UserOptions.KeyFilename;
                    end
                case 'SandBoxFolder'
                    folder=[uigetdir(cd,'Select folder for saving all work') '\'];
                    if exist(folder,'dir')
                        obj.UserOptions.SandBoxFolder=folder;
                        event.Source.UserData{2}.Value=folder;
                        Save(obj);
                    else
                        uialert(obj.Fig,'Folder doesnt exists','Select different folder');
                        event.Source.UserData{2}.Value=obj.UserOptions.SandBoxFolder;
                    end
                otherwise
            end
        end    
        
        function SaveAndClose(obj,event)
            if obj.Parent.DbConn.Status==1
                close(obj.Fig);
                Save(obj);
                OpenStructure(obj.Parent);
            end
        end
    end
end