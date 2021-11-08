classdef AcousticEmission < DataFrame
    %ACOUSTIC  Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = AcousticEmission(parent)
            obj@DataFrame(parent);
        end
        
    end
    
    methods (Access=public)
        function loctype=LocType(obj)
            loctype=categorical(["~","1D","2D","3D"],'Ordinal',true);
        end
    end
    
    %Data parts (channels, sensors, etc.)
    methods
        function chann=GetChannel(obj)
            chann=struct("CardKey",[],"Card",[],"CardID",[],"Channel",[],"ChannelID",[],...
                "Records",[]);
        end
        
        function result=ReadDb(obj)
        end
       
    end
end

