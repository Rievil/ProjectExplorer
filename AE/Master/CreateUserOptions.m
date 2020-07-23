function [UserOptions]=CreateUserOptions(MasterFolder)
    UserOptions=struct;
    %space for parameters of user defined options
    UserOptions.MasterFolder=MasterFolder;
    save ([MasterFolder '\UserOptions.mat'],'UserOptions');
end