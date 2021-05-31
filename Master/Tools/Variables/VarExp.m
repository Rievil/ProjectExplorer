classdef VarExp < Node
    %VAREXP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Inspector;
        Forge;
        TreeNode;
    end
    
    methods
        function obj = VarExp(parent)
            obj.Parent=parent;
            obj.Inspector=Inspector('parent',obj);
            obj.Forge=Forge;
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
        
        function FillNode(obj)
%             iconfilename=[OperLib.FindProp(obj,'MasterFolder') 'Master\Gui\Icons\SpecGroup.gif'];
            obj.TreeNode=uitreenode(obj.Parent.TreeNode,'Text','Variables','NodeData',{obj,'varexp'});
        end
        
        function stash=Pack(obj)
            stash=struct;
            stash.Inspector=obj.Inspector;
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

            
            la=uilabel(g,'Text','Designed variables per signle specimen:');
            la.Layout.Row=1;
            la.Layout.Column=1;
            
            but1=uibutton(g,'Text','Check variables',...
                'ButtonPushedFcn',@obj.CheckVar);
                        
            but1.Layout.Row=1;
            but1.Layout.Column=3;
            
            p2 = uipanel(g,'Title','Variable operations','FontSize',12);
            p2.Layout.Row=3;
            p2.Layout.Column=1;
            g3=uigridlayout(p2);
            g3.RowHeight = {'1x',25};
            g3.ColumnWidth = {'1x'};
            
            
             
            uit=uitable(g);
            uit.Layout.Row=2;
            uit.Layout.Column=1;
            uit.Data=GetEmptyVar(obj);
            
            p = uipanel(g,'Title','Variable designer','FontSize',12);
            p.Layout.Row=[2 3];
            p.Layout.Column=[2 3];
            
            g2=uigridlayout(p);
            g2.RowHeight = {'1x'};
            g2.ColumnWidth = {'1x','1x'};
            
            
            
            obj.Inspector.Fig=1;
            SetGuiParent(obj.Inspector,p);
            DrawGUI(obj.Inspector);
            DrawNodes(obj.Inspector);
            
            panel=obj.Inspector.GUI(5);
            obj.Forge.SetGui(panel);
            DrawGui(obj.Forge);
            
            
%             uit=uitable(g2);
%             uit.Layout.Row=1;
%             uit.Layout.Column=1;
%             uit.Data=GetEmptyVar(obj);
            

        end
        
        
    end
end