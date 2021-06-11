classdef OPInter < Operator
    %INTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        MainX=1;
        SupX=1;
        SupY=1;
        Type;
        PointReq;
        SelType;
        arrMX;
        arrSX;
        arrSY;
        UIAxes;
        Test=false;
    end
    
    properties (Dependent)
        MainY;
    end
    
    methods
        function obj = OPInter(~)
            obj@Operator;
            obj.Name='OPInter';
            obj.Title='1D interpolace';
            
            obj.Type={'spline','linear','nearest','next','previous','pchip','cubic','makima'};
            obj.PointReq=[2,2,2,2,4,3,2,4];
            
            obj.Description={'X1 ... for what base value you want interpolate';
                'X2 ... base value of know series';
                'Y2 ... target variable you want to get values for X1 points'};
        end

        function SelectType(obj,id)
            TypeCount=numel(obj.Type);
            if id>0 && id <=TypeCount
                obj.SelType=id;
            end
        end
        
        function SetMainX(obj,id)
%             [var2, index] = unique(obj.Parent.Output(); 
            obj.MainX=id;
        end
        
        function SetSupX(obj,id)
%             [var2, index] = unique(var); 
            obj.SupX=id;
        end
        
        function SetSupY(obj,id)
%             [var2, index] = unique(var); 
            obj.SupY=id;
        end
        
        function GetArr(obj)
            obj.arrMX=obj.Parent.Output{obj.MainX};
            obj.arrSX=seconds(obj.Parent.Output{obj.SupX});
            obj.arrSY=obj.Parent.Output{obj.SupY};
            obj.Test=false;
        end

        function DrawSample(obj)
            SG=OperLib.FindProp(obj.VarSmith,'SpecGroup');
            T=SG.Specimens.Data{1};
            
            RunTool(obj.Parent,T);

            GetArr(obj);
            
            DrawPlot(obj);
        end
        
        function DrawPlot(obj)
            try
                MY=obj.MainY;
                cla(obj.UIAxes);

                plot(obj.UIAxes,obj.arrSX,obj.arrSY,'-k','DisplayName',obj.Parent.Adress{obj.SupX}.Label);

                scatter(obj.UIAxes,obj.arrMX,MY,'o','filled','DisplayName',obj.Parent.Adress{obj.MainX}.Label);
                legend(obj.UIAxes,'Location','northwest');
                
                xname=sprintf('%s: %s',obj.Parent.Adress{obj.MainX}.ArrType,...
                                obj.Parent.Adress{obj.MainX}.OrigName);

                yname=sprintf('%s: %s',obj.Parent.Adress{obj.SupY}.ArrType,...
                                obj.Parent.Adress{obj.SupY}.OrigName);

                xlabel(obj.UIAxes,xname);
                ylabel(obj.UIAxes,yname);

                obj.Test=true;
            catch ME
                obj.Test=false;
                Fig=OperLib.FindProp(obj.VarSmith,'UIFig');
                uiconfirm(Fig,char(ME.message),'Error','Icon','error')
            end
        end

        function arr=get.MainY(obj)            
            arr = interp1(obj.arrSX,obj.arrSY,obj.arrMX,char(obj.Type(obj.SelType)));
        end
        

    end
    
    methods %abstract
        function DrawGui(obj)
            g=uigridlayout(obj.Fig);
            g.RowHeight = {25,25,25,25,'1x'};
            g.ColumnWidth = {250,250,'1x'};
            
            lbl= uilabel(g,'Text','Type of interpolation');
            lbl.Layout.Row=1;
            lbl.Layout.Column=1;
            
            if obj.SelType>0
                n=obj.SelType;
            else
                n=1;
            end
            drtype = uidropdown(g,'Items',obj.Type,'ItemsData',1:1:numel(obj.Type),'Value',n,...
                    'ValueChangedFcn',@obj.MSelectType);

            drtype.Layout.Row=1;
            drtype.Layout.Column=2;
            
            varList=obj.Parent.VarList;
            if isempty(varList)
                varList="";
            end
            
            lbl1= uilabel(g,'Text','Main variable XQ:');
            lbl1.Layout.Row=2;
            lbl1.Layout.Column=1;
            
            if obj.MainX>0
                n=obj.MainX;
            else
                n=1;
            end
            
            drmx = uidropdown(g,'Items',varList,'ItemsData',1:1:numel(varList),'Value',n,...
                    'ValueChangedFcn',@obj.MSetMainX);
            drmx.Layout.Row=2;
            drmx.Layout.Column=2;

            lbl2= uilabel(g,'Text','Variable X:');
            lbl2.Layout.Row=3;
            lbl2.Layout.Column=1;

            if obj.SupX>0
                n=obj.SupX;
            else
                n=1;
            end

            drsx = uidropdown(g,'Items',varList,'ItemsData',1:1:numel(varList),'Value',n,...
                    'ValueChangedFcn',@obj.MSetSupX);
            drsx.Layout.Row=3;
            drsx.Layout.Column=2;

            lbl3= uilabel(g,'Text','Variable V:');
            lbl3.Layout.Row=4;
            lbl3.Layout.Column=1;

            if obj.SupY>0
                n=obj.SupY;
            else
                n=1;
            end
            drsy = uidropdown(g,'Items',varList,'ItemsData',1:1:numel(varList),'Value',n,...
                    'ValueChangedFcn',@obj.MSetSupY);
            drsy.Layout.Row=4;
            drsy.Layout.Column=2;

            ax=uiaxes(g);
            hold(ax,'on');
            ax.Layout.Row=5;
            ax.Layout.Column=[1 4];
            obj.UIAxes=ax;

            but1=uibutton(g,'Text','Check process','ButtonPushedFcn',@obj.MChekInter);
            but1.Layout.Row=3;
            but1.Layout.Column=4;
            
            if obj.Test==true
                DrawPlot(obj);
            end
        end
        
        
        function arr=RunTool(obj,~)
            GetArr(obj);
            obj.Output={obj.MainY};
        end
        
        function stash=Pack(obj)
            stash=struct;
            stash.MainX=obj.MainX;
            stash.SupX=obj.SupY;
            stash.Type=obj.Type;
            stash.SelType=obj.SelType;
            
        end
        
        function Populate(obj,stash)
            obj.MainX=stash.MainX;
            obj.SupY=stash.SupX;
            obj.Type=stash.Type;
            obj.SelType=stash.SelType;
        end
    end
    methods %callbackes
        function MSelectType(obj,src,~)
            SelectType(obj,src.Value);
%             TypeCount=numel(obj.Type);
%             if id>0 && id <=TypeCount
%                 obj.SelType=obj.Type{id};
%             end
        end
        
        function MSetMainX(obj,src,~)
            SetMainX(obj,src.Value);
        end
        
        function MSetSupX(obj,src,~)
            SetSupX(obj,src.Value);
        end
        
        function MSetSupY(obj,src,~)
            SetSupY(obj,src.Value);
        end
        
        function MChekInter(obj,src,~)
            DrawSample(obj);
        end
    end
end

