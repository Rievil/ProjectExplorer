classdef VarExp < Node
    %VAREXP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Inspector;
        TreeNode;
    end
    
    methods
        function obj = VarExp(parent)
            obj.Parent=parent;
            obj.Inspector=Inspector;
        end
        
        

    end
    
    methods %abstract
        function FillUITab(obj,Tab)
            p=OperLib.FindProp(obj,'UITab');
            SetGuiParent(obj,p);
            InitializeOption(obj);
        end
        
        function FillNode(obj)
%             iconfilename=[OperLib.FindProp(obj,'MasterFolder') 'Master\Gui\Icons\SpecGroup.gif'];
            obj.TreeNode=uitreenode(obj.Parent.TreeNode,'Text','Variables','NodeData',{obj,'varexp'});
        end
        
        function stash=Pack(obj)
            stash=struct;
            stash.Inspector=obj.Inspector.T;
%             obj.Inspector
        end
        
        function node=AddNode(obj)
            
        end
        
        function Populate(obj,stash)
            obj.Inspector.T=stash.Inspector;
        end
    end
    
    methods %GUI
        function CheckVar(obj,evnt,src)
            SG=OperLib.FindProp(obj,'SpecGroup');
            tst=SG.Specimens.Data{1};
            obj.Inspector.Reset;
            for i=1:size(tst,2)
                obj.Inspector.AddArray('data',tst(i).data,'name',tst(i).type);
            end
            obj.Inspector.Run3;
        end
        
        function InitializeOption(obj)
            SetParent(obj,'project');
            Clear(obj);
            g=uigridlayout(obj.GuiParent);
            g.RowHeight = {22,'1x'};
            g.ColumnWidth = {'1x',30};
            
            la=uilabel(g,'Text','Variables used in experiment:');
            la.Layout.Row=1;
            la.Layout.Column=1;
            
            p = uipanel(g,'Title','Options','FontSize',12);
            p.Layout.Row=2;
            p.Layout.Column=[1 2];
            
            but1=uibutton(g,'Text','Check variables',...
                'ButtonPushedFcn',@obj.CheckVar);
            
            but1.Layout.Row=1;
            but1.Layout.Column=2;
            
            SetGuiParent(obj.Inspector,p);
            obj.Inspector.Fig=1;
            DrawGUI(obj.Inspector);
            Show(obj.Inspector);
        end
    end
end

