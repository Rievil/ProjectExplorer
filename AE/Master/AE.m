classdef AE < MeasObj
    properties (SetAccess = public)
    end
    
    methods (Access = public)
        function obj=AE(ID,ProjectFolder,SandBox)
            obj@MeasObj(ID,ProjectFolder,SandBox);
            obj.Data=AEZedo(2);
            
            obj.Data.BruteFolder=obj.BruteFolder;            
            DataSweep(obj.Data);       
            PrepareAnalysis(obj.Data,'Samples','all','FullTime','hitdetector',0,'Signals','true')
            
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