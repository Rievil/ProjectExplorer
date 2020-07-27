classdef MeasObj < handle
    properties (SetAccess = public)
       Name string; %name of measuremnt
       Date datetime; %date when measruemnt took place
       MData; %measured data - object for type of measuremnt (currently only AEClassifier)
    end
    
    methods (Access = public)
    end
end