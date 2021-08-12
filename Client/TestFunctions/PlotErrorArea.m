function T=PlotErrorArea(ax,cell,varargin)
    minx=0;
    maxx=0;
    
    miny=0;
    maxy=0;
    
    allx=[];
    ally=[];

    for i=1:size(cell,1)
        x=cell{i,1};
        y=cell{i,2};
        
        if min(x)<minx
            minx=min(x);
        end
        
        if max(x)>maxx
            maxx=max(x);
        end
        
        if min(y)<miny
            miny=min(y);
        end
        
        if max(y)>maxy
            maxy=max(y);
        end
        
        allx=[allx; x];
        ally=[ally; y];
    end
    T=table(allx,ally,'VariableNames',{'x','y'});
    T=sortrows(T,'x');
    
    lx=linspace(minx,maxx,1000)';
    
%     [yupper,ylower] = envelope(unique(T.y),300);
%     plot(ax,yupper);
%     plot(ax,ylower);
%     ylow=interp1(T.x,ylower,lx);
%     yhigh=interp1(T.x,yupper,lx);
%     sca=scatter(ax,T.x,T.y,'.');
    [fitobj,gof]=fit(T.x,T.y,'poly6','Robust', 'LAR');
%     ci = confint(fitobj,0.60);
    
    newy=fitobj(lx);
    
    p11 = predint(fitobj,lx,0.95,'observation','on');
%     plot(fitobj,cdate,pop,'predfunc');
    ml=plot(ax,lx,newy,'Marker','none','HandleVisibility','off');
    
    ll=plot(ax,lx,p11(:,1),'--','Marker','none','HandleVisibility','off');
    hl=plot(ax,lx,p11(:,2),'--','Marker','none','HandleVisibility','off');
    
    while numel(varargin)>0
        switch lower(varargin{1})
            case 'linewidth'
                ml.LineWidth=varargin{2};
%                 ll.LineWidth=varargin{2};
%                 hl.LineWidth=varargin{2};
            case 'color'
                ml.Color=varargin{2};
                ll.Color=varargin{2};
                hl.Color=varargin{2};
%                 sca.MarkerFaceColor=varargin{2};
            case 'marker'
                
            case 'markersize'
                
            case 'markerfacecolor'
                
            case 'linestyle'
                ml.LineStyle =varargin{2};
            case 'displayname'
                ml.HandleVisibility='on';
                ml.DisplayName=varargin{2};
                
        end
        varargin([1,2])=[];
        
    end
    
    
    
end