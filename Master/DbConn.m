classdef DbConn < handle
    %DBCONN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Opts;
        Conn;
        IPAdress;
        ClientName;
        PortNumber;
        DriverPath;
        ClientPCName;
        KeyFilename;
        DatabaseName;
        AuthType;        
        RootFolder;
        MasterFolder;
        Status=0;
        UserListener;
        User;
        Parent;
    end
    
    properties (Access = private)
        ConnectionName;
        ClientPassword;
    end
    

    
    methods
        function obj = DbConn(parent,user)
            %DBCONN Construct an instance of this class
            %   Detailed explanation goes here
            obj.Parent=parent;
            obj.User=user;
            obj.UserListener = addlistener(obj.User,'ChangedUser',@obj.ChangedUser);
            
            vendor = "Microsoft SQL Server";
            
            %check if database toolbox
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
        
        function ChangedUser(obj,src,event)
            CheckForAccess(obj);
        end
        
        function CheckForAccess(obj)
            status=0;
            try
                GetKeyLocation(obj);
                if ReadKey(obj,0)
                    warning('Key filename does exists and works properly');
                else
                    warning('Key filename error');
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
                obj.Status=status;
            catch ME
                warning('KeyFilename hasn''t been selected yet')
                if status==0
                    warning('Can''t connect to database, is VPN on? Is filename working?');
                end
            end
        end
        
        function bool=CheckConnectionName(obj)
            v=ver('MATLAB'); 
            currVersion=str2double(replace(v.Release,{'(R',')'},''));
            switch v.Release
                case "(R2018a)"
                    list= getdatasources;
                case "(R2019b)"
                    list= getdatasources;
                case "(R2020b)"
                    list= getdatasources;
                otherwise
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
            obj.KeyFilename=obj.User.UserOptions.KeyFilename;
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
                        warning(['Other error: ',ME.identifier]);
                end
                bool=false;
            end
        end
        

    end
end

