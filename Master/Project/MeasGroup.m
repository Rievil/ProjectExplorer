classdef MeasGroup < Node
    %MEASGROUP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Meas=[];
        Count=0;
%         TreeNode;
    end
    
    events
        eReload;
    end
    
    methods
        function obj = MeasGroup(parent)
            obj.Parent=parent;
        end
        
        function Reload(obj)
           obj.notify('eReload');
        end
        
        function NewMeas(obj)
            obj2=AddMeas(obj);
            obj2.ID=OperLib.FindProp(obj,'MeasID');
            SetName(obj2);
            FillNode(obj2);
        end
        
        function obj2=AddMeas(obj)
            obj2=MeasObj(obj);
            obj.Meas=[obj.Meas, obj2];
            obj.Count=numel(obj.Meas);
        end
        
        function DeleteMeas(obj,ID)
            for i=1:numel(obj.Meas)
                if obj.Meas(i).ID==ID
                    obj.Meas(i)=[];
                    break;
                end
            end
        end
        
%         function ClearMeas(obj,ID)
%             for i=1:numel(obj.Meas)
%                 if obj.Meas(i).ID==ID
%                     obj.Meas(i)=[];
%                     break;
%                 end
%             end
%         end
        
        function MenuAddMeas(obj,src,~)
%             disp('test');
            NewMeas(obj);
        end
        
        function MenuReload(obj,src,~)
            Reload(obj);
        end
        
    end
    
    methods %abstract
        function FillUITab(obj,Tab)
        end
        
        function FillNode(obj)
            iconfilename=[OperLib.FindProp(obj,'MasterFolder') 'Master\Gui\Icons\MeasGroup.gif'];
            obj.TreeNode=uitreenode(obj.Parent.TreeNode,'Text','Measurements','NodeData',{obj,'measgroup'},...
                'Icon',iconfilename);
            
            UITab=OperLib.FindProp(obj,'UIFig');
            cm = uicontextmenu(UITab);
            m1 = uimenu(cm,'Text','New meas',...
                'MenuSelectedFcn',@obj.MenuAddMeas);
            m2 = uimenu(cm,'Text','Reload all',...
                'MenuSelectedFcn',@obj.MenuReload);
            
            obj.TreeNode.ContextMenu=cm;
            
        end
        
        function ClearIns(obj)
        end
        
        function stash=Pack(obj)
            stash=struct;
            stash.Count=obj.Count;
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
        end
        
        function node=AddNode(obj)
            
        end
        
        function Populate(obj,stash)
            obj.Count=stash.Count;
            if obj.Count>0
                n=0;
                obj.Meas=[];
                for Me=stash.Meas
                    n=n+1;
                    obj2=AddMeas(obj);
                    Populate(obj2,Me);
                end
            end
        end
    end
end

