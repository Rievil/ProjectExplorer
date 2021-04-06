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
        
        VarTable;
        
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
        function obj = Experiment(parent)
%             obj@Node;
            obj.Parent=parent;
%             obj.ID=ID;
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
            stash.MeasCount=obj.MeasCount;
%             stash.Meas=struct;
            n=0;
            for M=obj.Meas
                n=n+1;
                TMP=Pack(M);  
                stash.Meas(n)= TMP;         
            end
            if n==0
                stash.Meas=struct;
            end
            
            SandBox=OperLib.FindProp(obj,'SandBoxFolder');
            MasterFolder=OperLib.FindProp(obj,'MasterFolder');
            
            Filename=[SandBox,obj.ExpFolder,'\Experiment.mat'];
            save(Filename,'stash');
            
        end
        
        function Populate(obj,stash)

            obj.Name=stash.Name;
            obj.TypeSettings=stash.TypeSettings;
            obj.MeasCount=stash.MeasCount;
            FillNode(obj);
            
            if obj.MeasCount>0
                n=0;
                for Me=stash.Meas
                    n=n+1;
                    obj2=AddMeas(obj);
                    Populate(obj2,Me);
                end
            end
        end
        
        function FillNode(obj)
            iconfilename=[OperLib.FindProp(obj,'MasterFolder') 'Master\Gui\Icons\nExp.gif'];
            obj.TreeNode=uitreenode(obj.Parent.ExpMainNode,'Text',obj.Name,'NodeData',{obj,'experiment'},...
                'Icon',iconfilename);
        end
        function obj2=AddMeas(obj)
            obj2=MeasObj(obj);
            obj.Meas=[obj.Meas, obj2];   
            obj.MeasCount=numel(obj.Meas);
        end
        
        function node=AddNode(obj) 
            node=AddMeas(obj);
            node.ID=OperLib.FindProp(obj,'MeasID');
            SetName(node);
            
            FillNode(node);
        end
    end
    
end

