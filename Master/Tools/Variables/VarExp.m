classdef VarExp < Node
    %VAREXP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Inspector;
        Forge;
%         TreeNode;
    end
    
    methods
        function obj = VarExp(parent)
            obj.Parent=parent;
            obj.Inspector=Inspector('parent',obj);
            obj.Forge=Forge(obj);
        end
        
        function row=GetEmptyVar(obj)
            row=table([],[],[],[],[]);
            row.Properties.VariableNames={'ID','Name','Coord','Size','Type'};
        end

    end
    
    methods %abstract
        function FillUITab(obj,Tab)
            p=OperLib.FindProp(obj,'UITab');
            SetGuiParent(obj,p);
            InitializeOption(obj);
        end
        
        function ClearIns(obj)
        end
        
        function FillNode(obj)
%             iconfilename=[OperLib.FindProp(obj,'MasterFolder') 'Master\Gui\Icons\SpecGroup.gif'];
            obj.TreeNode=uitreenode(obj.Parent.TreeNode,'Text','Variables','NodeData',{obj,'varexp'});
        end
        
        function stash=Pack(obj)
            stash=struct;
            stash.Inspector=obj.Inspector.T;
            stash.Forge=Pack(obj.Forge);
            
        end
        
        function node=AddNode(obj)
            
        end
        
        function Populate(obj,stash)
            obj.Inspector.T=stash.Inspector;
            Populate(obj.Forge,stash.Forge);
        end
    end
    
    methods %GUI
        function CheckVar(obj)
            
            SG=OperLib.FindProp(obj,'SpecGroup');
            
            for i=1:size(SG.Specimens,1)
                count=size(SG.Specimens.Data(i).Data,2);
                if count==size(SG.Parent.TypeSettings,1)
                    break;
                end
            end
            
            tst=SG.Specimens.Data(i).Data;
            obj.Inspector.Reset;
            for i=1:size(tst,2)
                obj.Inspector.AddArray('data',tst(i).data,'name',tst(i).type);
            end
            obj.Inspector.AddArray('parent',obj);
            obj.Inspector.FirstRun;
        end
        
        
        function InitializeOption(obj)
            SetParent(obj,'project');
            Clear(obj);
            g=uigridlayout(obj.GuiParent);
            g.RowHeight = {25,'1x','1x'};
            g.ColumnWidth = {'1x','2x',300};
%             
            
            p = uipanel(g,'Title','Variable operations','FontSize',12);
            p.Layout.Row=[2 3];
            p.Layout.Column=1;
            
%             SetGuiParent(obj.Forge,p);
            
%             la=uilabel(g,'Text','Designed variables per signle specimen:');
%             la.Layout.Row=1;
%             la.Layout.Column=1;
            
            obj.Forge.Fig=p;
            
            p2 = uipanel(g,'Title','Variable designer','FontSize',12);
            p2.Layout.Row=[2 3];
            p2.Layout.Column=[2 3];
            
            obj.Forge.Fig(2)=p2;
            
            DrawGui(obj.Forge);
            
%             but1=uibutton(g,'Text','Check variables',...
%                 'ButtonPushedFcn',@obj.CheckVar);
                        
%             but1.Layout.Row=1;
%             but1.Layout.Column=3;
            

            
%             g3=uigridlayout(p2);
%             g3.RowHeight = {25,25,'1x'};
%             g3.ColumnWidth = {150,'1x',150};
%             obj.Forge.VarPanel=p2;

%             but1=uibutton(g3,'Text','New variable',...
%                 'ButtonPushedFcn',@obj.AddVariable);
%             but1.Layout.Row=1;
%             but1.Layout.Column=1;
            
%             but2=uibutton(g3,'Text','Delete variable');
%             but2.Layout.Row=2;
%             but2.Layout.Column=1;
            
%             lbox = uilistbox(g,'ValueChangedFcn',@obj.Forge.SetVariable);
%             lbox.Layout.Row=2;
%             lbox.Layout.Column=1;
%             
%             obj.Forge.UIList=lbox;
%             
%             
%             if obj.Forge.Count>0
%                 obj.Forge.FillList;
%             else
%                 lbox.Items={''};
%             end
            

%             g2=uigridlayout(p);
%             g2.RowHeight = {'1x'};
%             g2.ColumnWidth = {'1x','1x'};

%             obj.Inspector.Fig=1;
%             SetGuiParent(obj.Inspector,p);
%             DrawGUI(obj.Inspector);
%             
%             panel=obj.Inspector.GUI(5);
%             obj.Forge.SetGui(panel);
%             DrawGui(obj.Forge);

        end
        
        
    end
    
    methods %callbacks
        function AddVariable(obj,src,~)
            obj.Forge.AddVariable;
            obj.Forge.FillList;
        end
        
        function RemoveVariable(obj,src,~)
            
        end
    end
end