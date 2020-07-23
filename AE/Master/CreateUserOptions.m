function [UserOptions]=CreateUserOptions(MasterFolder)
    UserOptions=struct;
    %space for parameters of user defined options
    UserOptions.MasterFolder=MasterFolder;
    UserOptions.SandBoxFolder='empty';
    save ([MasterFolder 'UserOptions.mat'],'UserOptions');
end