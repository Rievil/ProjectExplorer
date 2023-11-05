classdef Plotter < Node
    %VAREXP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        PlotObj;
        PlotGroups;
        
%         TreeNode;
        
        UITree;
        
        UIPanel;
        
%         UIAxisPreviewTab;
%         UIVarSpecSelectionTab;
%         UIPlotPropertiesTab;
%         UIExportTab;
%         UIOperationsTab;
    end
    
    properties (Dependent)
        Count;
    end
    
    
    methods
        function obj = Plotter(parent)
            obj.Parent=parent;
%             obj.Inspector=Inspector;
            
        end
        
        function count=get.Count(obj)
            count=numel(obj.PlotGroups);
        end

    end
    
    methods 
        function NewPlotGroup(obj)
            obj2=PlotGroup(obj);
            id=obj.Count+1;
            obj2.ID=id;
            obj2.SetName(char(sprintf('Plot group %d',id)));
            
            obj.PlotGroups{id}=obj2;
            FillNode(obj2);
        end
        
        function RemovePlotGroup(obj,id)
            obj.PlotGroups(id)=[];
            n=0;
            for i=1:obj.Count
                obj.PlotGroups{i}.ID=i;
            end
        end
        
        function delete(obj)
            delete(obj.TreeNode);
        end
    end
    
    methods %abstract
        function FillUITab(obj,Tab)
            p=OperLib.FindProp(obj,'UITab');
            SetGuiParent(obj,p);
            InitializeOption(obj);
        end
        
        function FillNode(obj)
            obj.TreeNode=uitreenode(obj.Parent.TreeNode,'Text','Plotter','NodeData',{obj,'plotter'});
        end
        
        function ClearIns(obj)
        end
        
        function stash=Pack(obj)
            stash=struct;
            
            if ~isempty(obj.PlotGroups)
                for i=1:numel(obj.PlotGroups)
                    TMP=Pack(obj.PlotGroups{i});
                    stash.PlotGroups{i}=TMP;
                end
            end
        end
        

        
        function Populate(obj,stash)
%             obj.Inspector.T=stash.Inspector;
            if isfield(stash,'PlotGroups')
                for i=1:size(stash.PlotGroups,2)
                    obj2=PlotGroup(obj);
                    obj2.Populate(stash.PlotGroups{i});
                    obj.PlotGroups{i}=obj2;
                end
            end
        end
        
        function node=AddNode(obj)
            
        end
        
        function Tout=GetSampleData(obj,exp,sel)
            Tout=table;
            Variables=obj.Parent.Experiments(exp).VarExp.Forge.Variables;
            SPecGroup=obj.Parent.Experiments(exp).SpecGroup;
            idx=SPecGroup.GetSelIdx(sel);
            % Sel=SPecGroup.Selector.Specimens{sel};
            T=SPecGroup.Specimens(idx,:);
            for i=1:size(T,1)
                try
                    data=T.Data(i).Data;
                    Trow=T(i,1:3);
                    for j=1:numel(Variables)
                        Var=Variables(j);
                        x=Var.GetVariable(data);

                        finnames=strings(size(x,2),1);
                        for k=1:numel(finnames)
                            finnames(k,1)=string(sprintf('%s_%s',Var.Name,x.Properties.VariableNames{k}));
                        end
                        x.Properties.VariableNames=cellstr(finnames);
                        Trow=[Trow, x];


                    end

                    for g=1:size(Trow,2)
                        tmp=Trow{:,g};
                        switch class(tmp)
                            case 'categorical'
                                tmp=string(tmp);
                                Trow=[Trow(:,1:g-1),table(string(tmp),'VariableNames',{Trow.Properties.VariableNames{g}}),Trow(:,g+1:end)];
                        end
                    end

                    if size(Tout,2)>0
                        if size(Trow,2)==size(Tout,2)
                            Tout=[Tout; Trow];
                        end
                    else
%                         if size(Trow,2)==size(Tout,2)
                        Tout=[Tout; Trow];
%                         end
                    end
                catch ME
                    fprintf("Specimen ID:%d '%s' has problem, row: %d, reason: %s\n",T.ID(i),T.Key(i),i,string(ME.message));
                end
            end
        end
        
        function DrawTest(obj)
            var1=obj.Parent.Experiments(1).VarExp.Forge.Variables(1, 5);
            var2=obj.Parent.Experiments(1).VarExp.Forge.Variables(1, 4);
            fig=figure;
            hold on;
            ax=gca;
            T=obj.Parent.Experiments(1).SpecGroup.Specimens(obj.Parent.Experiments(1).SpecGroup.Sel,:);

            for i=1:size(T,1)
                data=T.Data{i};
                x=var1.GetVariable(data);
                
                y=var2.GetVariable(data);
                plot(ax,x,y);
            end
            
        end


    end
    
    methods %GUI

        
        function InitializeOption(obj)
            SetParent(obj,'project');
            Clear(obj);
            
            UITab=OperLib.FindProp(obj,'UIFig');
            
            g=uigridlayout(obj.GuiParent);
            g.RowHeight = {22,'1x'};
            g.ColumnWidth = {150,'1x'};
            
            
            label = uilabel(g,'Text','Figure concepts');
            label.Layout.Row=1;
            label.Layout.Column=1;
            
            label2 = uilabel(g,'Text','Figure concept properties');
            label2.Layout.Row=1;
            label2.Layout.Column=2;
            
            tree = uitree(g,'SelectionChangedFcn',@obj.MFigureNodeSelected,'Editable',true,'NodeTextChangedFcn',@obj.MNodeChangeName);
            tree.Layout.Row=2;
            tree.Layout.Column=1;
            obj.UITree=tree;
            
%             if obj.Count>0
            for i=1:obj.Count
                obj.PlotGroups{i}.FillNode;
            end
%             end
            
%             tabgroup=uitabgroup(g,'AutoResizeChildren',true);
%             tabgroup.Layout.Row=2;
%             tabgroup.Layout.Column=2;
            
            panel = uipanel(g,'Title','Axis preview');
            panel.Layout.Row=2;
            panel.Layout.Column=2;
            
            obj.UIPanel=panel;
            
%             tab2 = uitab(tabgroup,'Title','Variable and specimens selection');
%             tab3 = uitab(tabgroup,'Title','Plot properties');
%             tab4 = uitab(tabgroup,'Title','Export properties');
%             tab5 = uitab(tabgroup,'Title','Custom operations');
            
            
%             obj.UIAxisPreviewTab=tab1;
%             obj.UIVarSpecSelectionTab=tab2;
%             obj.UIPlotPropertiesTab=tab3;
%             obj.UIExportTab=tab4;
%             obj.UIOperationsTab=tab5;
            
%             obj.UITabGroup=tabgroup;
            
            cm = uicontextmenu(UITab,'UserData',obj);
            
            
            m1 = uimenu(cm,'Text','New plot group',...
                'MenuSelectedFcn',@obj.MNewPlotGroup);
            
            obj.UITree.ContextMenu=cm;
        end
        
        
    end
    
    methods %callbacks
        function MSetFigConcept(obj,src,~)
           disp('MSetFigConcept'); 
        end
        
        function MFigureNodeSelected(obj,src,~)
            node=src.SelectedNodes;
            obj2=node.NodeData{1};
            objName=node.NodeData{2};
            switch lower(objName)
                case 'figureconcept'
                    SetGui(obj2,obj.UIPanel);
                    DrawGui(obj2);
                case 'plotgroup'
                    
                otherwise
            end
            disp('MFigureNodeSelected');
        end
          
        function MNewPlotGroup(obj,src,~)
            NewPlotGroup(obj);
        end
        
        function MNodeChangeName(obj,src,evnt)
%             disp(r'MNodeChangeName');
            obj2=evnt.Node.NodeData{1};
            obj2.SetName(evnt.Text);
        end
        
    end
end

