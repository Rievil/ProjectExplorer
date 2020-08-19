classdef Users < handle
    properties (SetAccess = public)
        UserOptions struct;
        MasterFolder;
    end
    methods (Access = public)
        function CreateNewUserOptions(obj)
            UserOptions=struct;
            %space for parameters of user defined options
            UserOptions.ID=1;
            UserOptions.User=getenv('COMPUTERNAME');
            UserOptions.MasterFolder=app.MasterFolder;
            UserOptions.SandBoxFolder=[];
            obj.UserOptions=UserOptions;
            save ([obj.MasterFolder 'UserOptions.mat'],'UserOptions');
        end
    end
end