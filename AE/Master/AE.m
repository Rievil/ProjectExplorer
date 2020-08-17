classdef AE < MeasObj
    properties (SetAccess = public)
    end
    
    methods (Access = public)
        function obj=AE(ID,ProjectFolder,SandBox)
            obj@MeasObj(ID,ProjectFolder,SandBox);
            obj.Data=AEZedo;
   
            PrepareAnalysis(obj.Data,'Samples','all','FullTime','hitdetector',0,'Signals','true')
            obj.Date=obj.Data.MeasurementDate;
            
            InitSel(obj);
            
            saveobj(obj);
        end
        
        %initiate selector

        
        %Saving of object
        function saveobj(obj)
            %sobj = saveobj@MeasObj(obj); 
            warning ('off','all');
            meas=obj;
            save([obj.SandBox obj.ProjectFolder 'Meas_' char(num2str(obj.ID)) '.mat'],'meas');
            warning ('on','all');
        end
    end
end