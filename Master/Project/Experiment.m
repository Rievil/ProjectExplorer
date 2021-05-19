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
        MeasGroup;
        Meas; %this can be erased, and can be sizely
        MeasCount; 
        
        Specimens; %this is efficiently stored measurements
        SpecimensCount;
        
        VarTable;
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
        function obj = Experiment(parent)
            obj.Parent=parent;
            obj.Status=0;
            
            %ovládací prvky meas
            AddMeasGroup(obj);
        end
        
        
        function AddMeasGroup(obj)
%             obj2=MeasGroup(obj);
            obj.MeasGroup=MeasGroup(obj)
        end
        

        

        
        function EditExperiment(obj)
            obj.TypeFig=AppTypeSelector(obj);
        end
        

        
        function CreateExpFolder(obj)
            SandBox=OperLib.FindProp(obj,'SandBoxFolder');            
            obj.ExpFolder=[OperLib.FindProp(obj,'ProjectFolder'), 'E_',num2str(obj.ID)];
            mkdir([SandBox, obj.ExpFolder]);
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

            stash.MeasGroup=Pack(obj.MeasGroup);
        end
        
        function Populate(obj,stash)
            obj.Name=stash.Name;
            obj.TypeSettings=stash.TypeSettings;

            FillNode(obj);
            Populate(obj.MeasGroup,stash.MeasGroup);
        end
        
        function FillNode(obj)
            iconfilename=[OperLib.FindProp(obj,'MasterFolder') 'Master\Gui\Icons\nExp.gif'];
            obj.TreeNode=uitreenode(obj.Parent.ExpMainNode,'Text',obj.Name,'NodeData',{obj,'experiment'},...
                'Icon',iconfilename);
            FillNode(obj.MeasGroup);
        end
        
        function AddNode(obj) 
            NewMeas(obj.MeasGroup);
        end
    end
    
end

