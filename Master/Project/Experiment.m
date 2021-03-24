classdef Experiment < Node
    %EXPERIMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ID;
        ExpFolder char;
        TreeNode;
        Status;
        Name='--#New Experiment#--';
        TypeSettings;
        TypeFig;
        
        %meas purpose is for reading a new data, changing it to specimens
        %with properties and then saving to specimens
        Meas; %this can be erased, and can be sizely
        MeasCount; 
        
        
        Specimens; %this is efficiently stored measurements
        SpecimensCount;
        Parent; %ProjectObj
    end
    
    events
        eReload;
    end
    
    properties
%         TypeSelWin;
        eEditTypes;
        DrawNode;
    end
    
    methods
        function obj = Experiment(parent,ID)
%             obj@Node;
            obj.Parent=parent;
            obj.ID=ID;
            obj.Status=0;
            
        end
        

        

        
        function Reload(obj)
               obj.notify('eReload');
        end
        
        function EditExperiment(obj)
            obj.TypeFig=AppTypeSelector(obj);
        end
%         function StartTypeEditor(obj)
%             obj.TypeSelWin=AppTypeSelector(app.PNodeSelected,app.MasterFolder,obj);
%         end
        
        function CreateExpFolder(obj)
            obj.ExpFolder=[obj.Parent.ProjectFolder, obj.Name];
            mkdir([obj.Parent.Parent.SandBoxFolder, obj.ExpFolder]);
        end
        
        function SetTypeSettings(obj,table)
            obj.TypeSettings=table;
            obj.Status=1;
            CreateExpFolder(obj);
        end
        
        function InitializeOption(obj)
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
    
        
    %Abstract methods
    methods 
        function FillUITab(obj,Tab)

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
        
        function FillNode(obj)
            obj.TreeNode=uitreenode(obj.Parent.ExpMainNode,'Text',obj.Name,'NodeData',{obj,'experiment'},...
                'Icon',[OperLib.FindProp(obj,'MasterFolder') '\Master\Gui\Icons\nExp.gif']);
        end
        
        function node=AddNode(obj)
            MeasID=OperLib.FindProp(obj,'MeasID');
%             MeasID=numel(obj.Meas)+1; 
            
            MeasFolder=obj.ExpFolder;
            
            meas=MeasObj(MeasID,MeasFolder,obj);
            FillNode(meas);
            
            obj.Meas=[obj.Meas, meas];            
        end
    end
    
end

