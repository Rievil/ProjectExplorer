classdef RLoader
    %RLoader will look into given folder, and with set key, will load each
    %file AND folder, according to the specified class data type
    %each data shares different clases, whcih can compute different outputs
    %folder from which the class will load all the thata with the key from
    properties
        BruteFolder char;  
        Key tab;
    end
    
    methods
        function obj = RLoader(Folder)
            obj.BruteFolder=Folder;
            
        end

    end
end

