classdef PlotSimple < Item
    
    %PLOTSIMPLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        UIPanel;
        UIAxPanel;
        UIAxes;
        UITableOption;
        Axes;
        AxisCount=0;
        TableOptions;
        View;
        DoubleYAxis=false;
    end
    
    properties (Dependent)
%         View;
    end
    
    methods
        function obj = PlotSimple(parent)
            obj.Parent=parent;
        end
        
        function setView(obj)
            view(obj.UIAxes,obj.View);
        end
%         function count=get.Count(obj)
%         end
        
         function T=AddAxis(obj,label)
            obj.AxisCount=size(obj.TableOptions,2);
             
            TickDir=categorical({'out','in'});
            Label=string(label);
            MinorTick=categorical({'on','off'});
            Exponent=0;
            AxisType=categorical({'x','y','z','x2','y2','z2'});
            FontName=categorical(listfonts);
            Scale=categorical({'linear','log'});
%             HLim=1;
            idx=FontName=='Arial';
            
            
            Value={AxisType(1),Label,MinorTick(1),TickDir(1),Exponent,Scale(1)}';
            
            Names={'AxisType','Label','MinorTick','TickDir','Exponent','Scale'}';
            
            T=table(Names,Value,'VariableNames',{'Names',char(sprintf('Axis %d',obj.AxisCount))});
            
         end
         
         function AplyAllFormating(obj)
             if ~isempty(obj.TableOptions)
                 for i=2:size(obj.TableOptions,2)
                     ApplyFormating(obj,i);
                 end
             end
         end
         
         function ApplyFormating(obj,column)
             axis=obj.TableOptions{1,column}{1};
             
             switch axis
                 case 'x'
                     hanName=get(obj.UIAxes,'XAxis');
                     obj.Axes{column-1}=hanName;
                 case 'y'
%                      yyaxis(app.UIAxes,'left');
%                      hanName=get(obj.UIAxes,'YAxis');
%                         if obj.DoubleYAxis==true
%                             yyaxis(obj.UIAxes,'left');
%                         end
                     hanNameTMP=get(obj.UIAxes,'YAxis');
                     hanName=hanNameTMP(1);
                     obj.Axes{column-1}=hanNameTMP(1);
                 case 'z'
                     hanName=get(obj.UIAxes,'ZAxis');
                     obj.Axes{column-1}=hanName;
                 case 'x2'
%                      ax2 = axes(t);
%                      hanName=get(obj.UIAxes,'ZAxis');
%                      obj.Axes{column-1}=hanName;
                 case 'y2'
                     yyaxis(obj.UIAxes,'right');
                     hanNameTMP=get(obj.UIAxes,'YAxis');
                     hanName=hanNameTMP(2);
                     obj.DoubleYAxis=true;
                     
                 case 'z2'
             end
             
             for i=2:size(obj.TableOptions,1)
                 name=obj.TableOptions.Names{i};
                 value=obj.TableOptions{i,column}{1};
                 switch name
                     case 'Label'
                        hanName.Label.String=value;
                        
                     case 'MinorTick'
                         hanName.MinorTick=char(value);
                     case 'Exponent'
                         hanName.Exponent=value;
                     case 'FontName'
                         hanName.FontName=lower(value);
                     case 'Scale'
                         hanName.Scale=char(value);
%                          hanName.DirTick=value;
                     
                 end
             end
         end
    end
    
    methods %abstract
        function DrawGui(obj)
            obj.AxisCount=0;
            obj.SetGui(obj.UIAxPanel);
            ClearGUI(obj);
            g=uigridlayout(obj.UIAxPanel);
            g.RowHeight = {'1x'};
            g.ColumnWidth = {'1x'};
            
            uiax=uiaxes(g,'ButtonDownFcn',@obj.MViewSet,'BusyAction','queue');
            uiax.Layout.Row=1;
            uiax.Layout.Column=1;
            
            obj.UIAxes=uiax;
            
            obj.SetGui(obj.UIPanel);
            ClearGUI(obj);
            
            g2=uigridlayout(obj.UIPanel);
            g2.RowHeight = {25,'1x','1x'};
            g2.ColumnWidth = {'1x','1x'};
            
            
            if isempty(obj.TableOptions)
                T1=AddAxis(obj,"axis 1");
                T2=AddAxis(obj,"axis 2");

                T = join(T1,T2,'Key','Names');
                obj.TableOptions=T;
            else
                T=obj.TableOptions;
            end
            
            larr=logical(zeros(1,size(T,2)));
            larr(2:end)=true;
                
            
            AplyAllFormating(obj);
                
            table=uitable(g2,'Data',T,'ColumnEditable',larr,'CellEditCallback',...
                @obj.MChangeAxProperty);
            table.Layout.Row=2;
            table.Layout.Column=[1 2];
            
            
            obj.UITableOption=table;
            
            btn1 = uibutton(g2,'Text','Add axis','ButtonPushedFcn',@obj.MAddAxis);
            btn1.Layout.Row=1;
            btn1.Layout.Column=1;
            
            btn2 = uibutton(g2,'Text','Remove axis','ButtonPushedFcn',@obj.MRemoveAxis);
            btn2.Layout.Row=1;
            btn2.Layout.Column=2;
%           
            if isempty(obj.View)
                obj.View=[45 45];
            end
            
            view(obj.UIAxes,obj.View);
            

            
%             dimtype=uidropdown(g2,'Items',{'2D','3D','Zoom plot'},...
%                      'Value',1,'ItemsData',[1 2 3]);
            
        end
        
        function stash=Pack(obj) 
            stash=struct;
            stash.Name=obj.Name;
            stash.Specific=CoPack(obj);
        end
        
        function Populate(obj,stash) 
            obj.Name=stash.Name;
            CoPopulate(obj,stash.Specific);
        end
    end
     
    methods %callbacks
        function MChangeAxProperty(obj,src,evnt)
            obj.TableOptions=src.Data;
%             row=evnt.Indices(1);
            column=evnt.Indices(2);
            ApplyFormating(obj,column);
        end
        
        function MAddAxis(obj,src,~)
            T2=AddAxis(obj,"New Axis");
            T = join(obj.TableOptions,T2,'Key','Names');
            obj.TableOptions=T;
            obj.UITableOption.Data=T;
            ApplyFormating(obj,size(T,2));
            
            larr=logical(zeros(1,size(obj.TableOptions,2)));
            larr(2:end)=true;
            obj.UITableOption.ColumnEditable=larr;
        end
        
        function MRemoveAxis(obj,src,~)
            
            if size(obj.TableOptions,2)>2
                obj.TableOptions(:,end)=[];
                obj.UITableOption.Data=obj.TableOptions;
                
                larr=logical(zeros(1,size(obj.TableOptions,2)));
                larr(2:end)=true;
                obj.UITableOption.ColumnEditable=larr;
                delete(obj.Axes{end});
                obj.Axes{end}=[];
            end
        end
        
        function MViewSet(obj,src,evnt)
            disp('test');
%             obj.View=src.View;
%             obj.View=src.View;
        end
    end
end

