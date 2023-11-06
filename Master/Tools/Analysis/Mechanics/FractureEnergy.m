classdef FractureEnergy < Item & GeneralAnalysis

    properties
    end
    
    methods
        function obj = FractureEnergy(parent)
            obj@Item;
            obj@GeneralAnalysis;
            obj.Parent=parent;
        end
        

    end

    methods %Abstract
        function DrawGui(obj)

        end
        
        function stash=Pack(obj)

        end
        
        function Populate(obj)

        end
    end
end

