classdef Press < DataFrame
   
    properties
       Name char;
    end
    
    properties (Access = private)
    end
    
    methods %main methods
        function obj = Press(~)
            obj@DataFrame;
        end
        

        function Tab=TabRows(obj)
            Tab=obj.Data;
        end
        
        function obj2=Copy(obj)
            obj2=Press;
        end
        
        function Data=PackUp(obj)
            VarNames=obj.Data.Properties.VariableNames;
            Data=table;
            n=1;
            for Name=VarNames
                Data{1,n}={obj.Data{:,n}};
                Data.Properties.VariableNames(n)=Name;
                n=n+1; 
            end
        end
        
    end
    
    methods %reading methods
                %will read data started from dataloader
        function Out=Read(obj,filename)
            obj.Filename=filename;
            INData=readtable(filename,'Sheet','Test Curve Data');    
            INData=ResamplePressData(obj,INData);
            
            DCount=size(INData,2);
            
            T=table;
            n=0;
            for i=1:2:DCount
                Arr=table2array(INData(:,[i i+1]));
                Arr(isnan(Arr(:,1)),:)=[];
                PR=Press;
                PR.Data=table(Arr(:,1),Arr(:,2),'VariableNames',{'Time','Force'});
                n=n+1;
                T.Press(n)=PR;
            end
            obj.Data=T;
            Out=T;
        end
        
    end
    %private methods for operating the variables
    methods (Access = private) 
        function [T]=ResamplePressData(obj,inT)
            T=table;
            TargetFreq=2;
            for i=1:2:size(inT,2)-1
                Time=inT{:,i};
                OrgFreq=1/(Time(2)-Time(1));
                if OrgFreq<TargetFreq
                    
                    [N,D] = rat(TargetFreq/OrgFreq);                                       % Rational Fraction Approximation
                    Check = [TargetFreq/OrgFreq, N/D] ;


                    tmpTime=resample(inT{:,i},N,D);
                    tmpArr=resample(inT{:,i+1},N,D);
                    
                    T{:,i}=tmpTime;
                    T{:,i+1}=tmpArr;
                else
                    T{:,i}=inT{:,i};
                    T{:,i+1}=inT{:,i+1};
                end
            end
        end
    end
    
    %Gui for data type selection 
    methods (Access = public)   
        %set property
        function SetVal(obj,val,idx)
            obj.TypeSet{idx}=val;
        end       
        %adrow in table
        function TypeAdRow(obj,Value,idx,Target)
            obj.TypeSet{idx}=Value;
            dim=size(Target.Data);
            if dim(1)~=Value
                if Value>dim(1)
                    Target.Data=[Target.Data; MTBlueprint(obj)];
                    Target.Data{end,4}=Value;
                else
                    Target.Data(end,:)=[];
                end
                obj.TypeSet{Target.UserData{2}}=Target.Data;
            end
        end
        %will initalize gui for first time
        function InitializeOption(obj)
            
            Clear(obj);

            %Target=DrawUITable(obj,MTBlueprint(obj),@SetVal);
            %DrawSpinner(obj,[1 20],Target,@TypeAdRow);
            DrawLabel(obj,['Stupid format at the moment \n Select composition of main table: by spinner select number of columns \n',...
                           'and choose the type of each column, column position in source file.\n',...
                           'IMPORTANT: there can be only one KeyColumn'],[300 60]);
        end
    end
    
    %Gui for plotter
    methods 
        function han=PlotType(obj,ax)
            yyaxis(ax,'left');
            hold(ax,'on');
            plot(ax,obj.Data{:,1},obj.Data{:,2});
            xlabel(ax,'Time \it t \rm [s]');
            ylabel(ax,'Force \it F \rm [N]');
        end
    end
end

