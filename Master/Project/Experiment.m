classdef Experiment < handle
    %EXPERIMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ID;
        ExpFolder char;
        TreeNode;
        Status;
        Name;
        TypeSettings;
        
        Meas; %this can be erased, and can be sizely
        MeasCount; %this is efficiently stored measurements
        
        
        Specimens;
        SpecimensCount;
        Parent; %ProjectObj
    end
    
    events
        eReload;
    end
    
    properties
        TypeSelWin;
        eEditTypes;
    end
    
    methods
        function obj = Experiment(parent,ID)
            obj.Parent=parent;
            obj.ID=ID;
            obj.Status=0;

        end
        
        function AddMeas(obj)
            MeasID=numel(obj.Meas)+1; 
            MeasFolder=obj.ExpFolder;
            meas=MeasObj(MeasID,MeasFolder,obj);
            obj.Meas=[obj.Meas, meas];
            
            node=uitreenode(obj.TreeNode,'Text',meas.Name,'NodeData',{meas,'meas'});
            meas.TreeNode=node;
        end
        
        function Reload(obj)
               obj.notify('eReload');
        end
        
        function StartTypeEditor(obj)
            obj.TypeSelWin=AppTypeSelector(app.PNodeSelected,app.MasterFolder,1);
        end
        
        function CreateExpFolder(obj)
            obj.ExpFolder=[obj.Parent.ProjectFolder, obj.Name];
            mkdir([obj.Parent.Parent.SandBoxFolder, obj.ExpFolder]);
        end
        
        function SetTypeSettings(obj,table)
            obj.TypeSettings=table;
            obj.Status=1;
            CreateExpFolder(obj);
        end
        
        function stash=Pack(obj)
            stash=struct;
            stash.Name=obj.Name;
            stash.TypeSettings=obj.TypeSettings;
            stash.Meas=[];
            n=0;
            for M=obj.Meas
                n=n+1;
                stash.Meas(n)=Pack(M);            
            end
        end
        
        function Remove(obj)
            if ~isempty(obj.ExpFolder)
                folder=[obj.Parent.Parent.SandBoxFolder, obj.ExpFolder];
                rmdir(folder,'s');
            end
            delete(obj.TreeNode);
        end
        
        function delete(obj)
            delete(obj.TreeNode);
        end
    end
end

