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
        Parent;
        
    end
    
    methods
        function obj = DbConn(parent)
            %DBCONN Construct an instance of this class
            %   Detailed explanation goes here
            obj.Parent=parent;
            GetCurrentPc(obj);
            GetKeyLocation(obj);
        end
        
        function GetCurrentPc(obj)
            obj.ClientPCName=getenv('COMPUTERNAME');
        end
        
        function SetupConnection(obj)
            vendor = "Microsoft SQL Server";

            obj.Opts = configureJDBCDataSource('Vendor',vendor);
            obj.ConnectionName='Project explorer Client';
            obj.IPAdress='147.229.25.228';
            obj.PortNumber=1433;
            obj.DatabaseName='Projects';

            
            obj.Opts = setConnectionOptions(obj.Opts, ...
                'DataSourceName',obj.ConnectionName, ...
                'Server',obj.IPAdress, ...
                'PortNumber',obj.PortNumber,...
                'DatabaseName',obj.DatabaseName,...
                'JDBCDriverLocation',obj.DriverPath, ...
                'AuthType','Server');

            status = testConnection(obj.Opts,obj.ClientName,obj.ClientPassword);
            saveAsJDBCDataSource(obj.Opts)
        end
        
        function bool=CheckForAccess(obj)
            
        end
        
        function GetKeyLocation(obj)
            [file,path]=uigetfile('.txt','Select KeyFilename');
            obj.KeyFilename=[path, file];
            bool=ReadKey(obj);
        end
        
        function bool=IsFirstRun(obj)
            app.MasterFolder=strrep(which('ProjectExplorer'),'App\ProjectExplorer.mlapp','');
        end
        
        function bool=ReadKey(obj)
            try
                fileID = fopen(obj.KeyFilename);
                txt = fscanf(fileID,'%s');
                fclose(fileID);
                struct = jsondecode(txt);
                obj.ClientName=struct.Name;
                obj.ClientPassword=struct.Password;
                bool=true;
                warning('Key Setup correctly');
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

