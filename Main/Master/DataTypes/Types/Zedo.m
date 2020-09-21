classdef Zedo < DataFrame
    %MainTable is a PILOT type for all other possible measurments, ts
    %doesnt has to be present, but is higly recomended for the clarity and
    %clear structure of loaded data. PILOT type means, that it will guid
    %all other types which are present id datatypetable. PILOT has the key variable,
    %by which all other types will be sorted out. This design 
    properties
       
    end
    
    properties (Access = private)
        
    end
    
    methods
        function obj = Zedo(~)
            obj@DataFrame;
        end
        
        %will read data started from dataloader
        function Data=Read(obj,filename)
        end
        
        
    end

    %Gui for data type selection 
    methods (Access = public)   
        %set property
        function SetVal(obj,val,idx)
            obj.TypeSet{idx}=val;
        end       
        
        %add card to zedo
        %Key(obj,han.Value,obj.Count,Target);
        function AddCard(obj,n,~,Parent)
            %(obj,Parent,Type,Key)
            DrawUITreeNode(obj,Parent,['Card ' char(num2str(n))],@UpdateCardInfo);
            
        end
        
        %add channel
        function AddChannel(obj,Parent,n)
            DrawUITreeNode(obj,Parent,['Channel ' char(double2str(n))],@UpdateCardInfo);
        end
        
        %function edit card
        function UpdateCardInfo(obj,value,node)
            
        end
        
        %adrow in table
        function TypeAdRow(obj,Value,idx,Target)
            obj.TypeSet{idx}=Value;
            dim=size(Target.Data);
            if dim(1)~=Value
                if Value>dim(1)
                    Target.Data=[Target.Data; OperLib.MTBlueprint];
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
            
            Target=DrawUITree(obj,@SetVal);
            DrawSpinner(obj,[1 20],Target,@AddCard);
            DrawUIEditField(obj,"Channel 1",@UpdateCardInfo);
            
            DrawLabel(obj,['Select composition of main table: by spinner select number of columns \n',...
                           'and choose the type of each column, column position in source file.',...
                           'IMPORTANT: there can be only one KeyColumn'],[300 60]);
        end
    end
end

