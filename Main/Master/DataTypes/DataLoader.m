classdef DataLoader < handle
    %DATALOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        TypeTable;
        ArrTypes;
        BruteFolder char;
        MasterFolder char;
    end
    
    methods
        %consruktor
        function obj = DataLoader(MasterFolder)
            obj.MasterFolder=MasterFolder;
        end

        function ReadData(obj)
            if ismember(obj.TypeTable{:,4},"MainTable")
                
            else
                
            end
        end
    end

    methods (Access = public) %set get methods
        %Get Types
        function CTypes=GetTypes(obj)
            STRTypes=strings(["MainTable","Press","Zedo"]);
            CTypes = categorical(STRTypes,'Ordinal',true);
        end
        
        %Set input data types from typetable
        function SetDataTypes(TypeTable,ArrTypes)
            obj.TypeTable=TypeTable;
            obj.ArrTypes=ArrTypes;
        end
        
        %set brute folder
        function SetBruteFolder(BruteFolder)
            obj.BruteFolder=BruteFolder;
        end
    end
end

