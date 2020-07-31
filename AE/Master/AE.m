classdef AE < MeasObj
    properties (SetAccess = public)
    end
    
    methods (Access = public)
        function obj=AE(ID,ProjectFolder,SandBox)
            obj@MeasObj(ID,ProjectFolder,SandBox);
            obj.Data=AEClassifier(2);
            
            obj.Data.BruteFolder=obj.BruteFolder;
            
            DataSweep(obj.Data);
            
            saveobj(obj);
        end
        
        function saveobj(obj)
            %sobj = saveobj@MeasObj(obj); 
            warning ('off','all');
            meas=obj;
            save([obj.SandBox obj.ProjectFolder 'Meas_' char(num2str(obj.ID)) '.mat'],'meas');
            warning ('on','all');
        end
    end
end