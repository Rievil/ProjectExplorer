classdef DataOperation < handle
    %DATAOPERATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties

    end
    
    methods
        function obj = DataOperation(~)
        end
        
        function list=GetVarList(obj,exp)
            list=obj.Experiments(exp).VarExp.Forge.VarList
        end
        
        function list=GetSpecList(obj,exp)
            list=obj.Experiments(exp).SpecGroup.SpecimenList
        end
        
        function list=GetSelList(obj,exp)
            list=GetSelList(obj.Experiments(exp).SpecGroup);
        end
        
        function T=GetSampleData(obj,varargin)
            while numel(varargin)>0
                switch lower(varargin{1})
                    case 'exp'
                        exp=varargin{2};
                    case 'sel'
                        switch class(varargin{2})
                            case 'double'
                                sel=obj.Experiments(exp).SpecGroup.Selector.Specimens{varargin{2}};
                            case 'string'
                                
                                sel=obj.Experiments(exp).SpecGroup.GetSelIdx(varargin{2});
                            case 'char'
                                 sel=obj.Experiments(exp).SpecGroup.GetSelIdx(string(varargin{2}));
                            otherwise
                        end
                        
%                         sel=varargin{2};
                    case 'var'
                        var=varargin{2};
                    case 'spec'
                        sel=FindSpec(obj.Experiments(exp).SpecGroup,varargin{2});
                    otherwise
                end
                varargin([1,2])=[];
            end
            
            T=GetData(obj,exp,sel,var);
        end


    end
    
    methods (Access=private)
        function Tout=GetData(obj,exp,Sel,var)
            
            Tout=table;
            list=obj.Experiments(exp).VarExp.Forge.VarList;
            
            A=contains(list,var);
            
            Variables=obj.Experiments(exp).VarExp.Forge.Variables(A);
%             SPecGroup=obj.Experiments(exp).SpecGroup;
            
            T=obj.Experiments(exp).SpecGroup.Specimens(Sel,:);
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
    end
end

