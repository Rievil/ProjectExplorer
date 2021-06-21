classdef PlotObj < Item
    %Plot obj is superobj for all plot types (plot, scatter, etc. ...)
    
    properties

    end
    
    methods
        function obj = PlotObj(parent)
            obj.Parent=parent;

        end
        

    end
    
    methods (Abstract)
        CoPack(obj);
        CoPopulate(obj,stash);
    end
    
    methods %abstract
        function DrawGui(obj)
            ClearGUI(obj);
            g=uigridlayout(obj.Fig(1));

        end
        
        function stash=Pack(obj) 
            
            stash.Specific=CoPack(obj);
        end
        
        function Populate(obj,stash) 
            
            CoPopulate(obj,stash.Specific);
        end
    end
end

