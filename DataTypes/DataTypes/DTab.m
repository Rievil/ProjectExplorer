classdef DTab < RFile
    %Dtab is basic file, which should always be present in some form in the
    %brute folder
    %it contain the names of all specimens which were measured during the
    %seisssion + small values, such as dimensions, wheight, or dimensions +
    %important categorical values, which are used for description of 
    properties
        Property1
    end
    
    methods
        function obj = DTab(File)
            obj@RFile(File);
            %DTAB Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
    end
end

