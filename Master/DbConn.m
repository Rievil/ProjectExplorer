classdef DbConn < handle
    %DBCONN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Opts;
        Conn;
        IPAdress;
        ClientName;
        PortNumber;
        ConnectionName;
        DriverPath;
        ClientPCName;
        ClientPassword;
        KeyFilename;
        DatabaseName;
        AuthType;        
        RootFolder;
        MasterFolder;
    end
    
    properties (Access = private)
        Parent;
    end
    
    methods
        function obj = DbConn(parent)
            %DBCONN Construct an instance of this class
            %   Detailed explanation goes here
            obj.Parent=parent;
            
            vendor = "Microsoft SQL Server";

            obj.Opts = configureJDBCDataSource('Vendor',vendor);
            obj.ConnectionName='Project explorer Client';
            obj.IPAdress='147.229.25.228';
            obj.DatabaseName='Projects';
            obj.DriverPath=[obj.Parent.MasterFolder '\Databases\sqljdbc4.jar'];
            obj.PortNumber=1433;

            obj.Opts = setConnectionOptions(obj.Opts, ...
                'DataSourceName',obj.ConnectionName, ...
                'Server',obj.IPAdress, ...
                'PortNumber',obj.PortNumber,...
                'DatabaseName',obj.DatabaseName,...
                'JDBCDriverLocation',obj.DriverPath, ...
                'AuthType','Server');  
            
            CheckForAccess(obj);
        end
        
        function status=TestConnect(obj)
            status = testConnection(obj.Opts,obj.ClientName,obj.ClientPassword);
        end
        
        function SaveConnection(obj)
            saveAsJDBCDataSource(obj.Opts)
        end
        
        
        function CheckForAccess(obj)
            if isempty(obj.Parent.Users.UserOptions.KeyFilename)
                GetKeyLocation(obj);
                if ReadKey(obj,1)
                    obj.Parent.Users.UserOptions.KeyFilename=obj.KeyFilename;
                    Save(obj.Parent.Users);
                end
            else
                %there is already keyfilename
                obj.KeyFilename=obj.Parent.Users.UserOptions.KeyFilename;
                if ReadKey(obj,0)
                    
                end
            end
            
            if ~CheckConnectionName(obj)
                SaveConnection(obj);
                bool=false;
            else
                bool=true;
            end
            
            status=TestConnect(obj);
            if status==true
                warning('Succesfully connected to database');
            else
                warning('Can''t connect to database, is VPN on?');
            end
        end
        
        function bool=CheckConnectionName(obj)
            v=ver('MATLAB'); 
            currVersion=str2double(replace(v.Release,{'(R',')'},''));
            if v.Release=="(R2018a)"
                list= getdatasources;
                
                %Code
            elseif v.Release=="(R2019b)"
                %Code
                list= getdatasources;
            end
            
            bool=false;
            for ConnName=list
                if string(ConnName)==obj.ConnectionName
                    bool=true;
                    break;
                end
            end
        end
        
        function GetKeyLocation(obj)
            [file,path]=uigetfile('.txt','Select KeyFilename');
            obj.KeyFilename=[path, file];
        end

        
        function bool=ReadKey(obj,frun)
            try
                fileID = fopen(obj.KeyFilename);
                txt = fscanf(fileID,'%s');
                fclose(fileID);
                struct = jsondecode(txt);
                
                obj.ClientName=struct.Name;
                obj.ClientPassword=struct.Password;
                
                bool=true;
                if frun==true
                    warning('Key Setup correctly');
                end
            catch ME
                switch ME.identifier
                    case 'MATLAB:json:ExpectedValue'
                        error('The key is not in JSON format');
                    case 'MATLAB:nonExistentField'
                        error('Filed "Name" or "Password" is spelled wrong or is missing');
                    otherwise
                        error(['Other error: ',ME.identifier]);
                end
                bool=false;
            end
        end
        

    end
end

