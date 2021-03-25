classdef Users < OperLib
    properties (SetAccess = public)
        UserOptions;
        UserID;
        UserName;
        Status=0;
        Parent;
    end
     
    properties (Access = private)
        Fig;
    end
    
    events
        ChangedUser;
    end
    
    methods (Access = public)
        %start the object
        function obj=Users(parent)
            obj@OperLib;
            
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
            
            NewUser.Alias=[''];
            NewUser.AliasPass=[''];
            
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
            
            
            uilabel(obj.Fig,'Text','Alias:','Position',[20 270 210 20]);
            field3=uieditfield(obj.Fig,'text','value',[obj.UserOptions.Alias],'Position',[235 270 310 20]);
            uibutton(obj.Fig,'Text','Select key','Position',[550 270 100 20],...
                'ButtonPushedFcn',@(src,event)ChangeUserField(obj,event),'UserData',{'Alias',field3});
            
            
            uibutton(obj.Fig,'Text','Save settings','Position',[20 220 100 30],...
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
                case 'Alias'
                    Connect(obj);
                    obj.UserOptions.Alias=event.Source.UserData{2}.Value;
                    [bool,user]=DBCheckForAlias(obj,obj.UserOptions.Alias);
                    if bool 
                        f = warndlg(sprintf('%s already exists!',user.Alias{1}),'Warning');
                    else
                        DBAddUser(obj);
                        [~,user]=DBCheckForAlias(obj,obj.UserOptions.Alias);
                        Save(obj);
                        f = warndlg(sprintf('User %s created',user.Alias{1}),'Warning');
                    end
                    Disconnect(obj);
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
    
    methods %db
        function DBAddUser(obj)
            data=table(string(obj.UserOptions.Alias),"test","test",'VariableNames',{'Alias','UserName','Password'});
            DBWrite(obj,'Users',data);
        end
        
        function [bool,user]=DBCheckForAlias(obj,alias)
            querry=['SELECT * FROM Users WHERE Alias=''',char(alias),''' ;'];
            user=DBFetch(obj,querry);
            if size(user,1)==0
                bool=false;                
            else
                bool=true;
                obj.UserID=user.ID;
            end
        end
        
        function AddUserProject(obj)
        end
        
        
    end
end