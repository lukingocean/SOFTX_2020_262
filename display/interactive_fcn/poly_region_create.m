%% poly_region_create.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |main_figure|: TODO: write description and info on variable
% * |func|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-03-24: header (Alex Schimel)
% * 2017-03-24: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function poly_region_create(main_figure,func)

layer=get_current_layer();
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=get_esp3_prop('curr_disp');

ah=axes_panel_comp.main_axes;


switch main_figure.SelectionType
    case 'normal'
        
    otherwise

        return;
end
axes_panel_comp.bad_transmits.UIContextMenu=[];
axes_panel_comp.bottom_plot.UIContextMenu=[];
clear_lines(ah);
 [cmap,col_ax,col_line,col_grid,col_bot,col_txt,~]=init_cmap(curr_disp.Cmap);

[trans_obj,idx_freq]=layer.get_trans(curr_disp);


cp = ah.CurrentPoint;

xinit=nan(1,1e4);
yinit=nan(1,1e4);
xinit(1) = cp(1,1);
yinit(1)=cp(1,2);
u=2;
xdata=trans_obj.get_transceiver_pings();
ydata=trans_obj.get_transceiver_samples();

x_lim=get(ah,'xlim');
y_lim=get(ah,'ylim');

if xinit(1)<x_lim(1)||xinit(1)>xdata(end)||yinit(1)<y_lim(1)||yinit(1)>y_lim(end)
    return;
end
rr=trans_obj.get_transceiver_range();
hp=plot(ah,xinit,yinit,'color',col_line,'linewidth',1,'Tag','reg_temp');
txt=text(ah,cp(1,1),cp(1,2),sprintf('%.2f m',rr(nanmin(ceil(cp(1,2)),numel(rr)))),'color',col_line,'Tag','reg_temp');


replace_interaction(main_figure,'interaction','WindowButtonMotionFcn','id',2,'interaction_fcn',@wbmcb_ext);
replace_interaction(main_figure,'interaction','WindowButtonDownFcn','id',1,'interaction_fcn',@wbdcb_ext);


   function wbmcb_ext(~,~)
       
        cp=ah.CurrentPoint;
        
        if cp(1,2)<0
            return;
        end
        
        xinit(u)=cp(1,1);
        yinit(u)=nanmin(nanmax(ceil(cp(1,2)),1),numel(rr));
            
        
        if isvalid(hp)
            set(hp,'XData',xinit,'YData',yinit);
        else
            hp=plot(ah,xinit,yinit,'color',col_line,'linewidth',1,'Tag','reg_temp');
        end
        
        if isvalid(txt)
            set(txt,'position',[cp(1,1) yinit(u) 0],'string',sprintf('%.2f m',rr(yinit(u))));
        else
            txt=text(ah,cp(1,1),yinit(u),sprintf('%.2f m',rr(yinit(u))),'color',col_line,'Tag','reg_temp');
        end
   end

    function wbdcb_ext(~,~)
        
        switch main_figure.SelectionType
            case {'open' 'alt'}

                wbucb(main_figure,[]);
                replace_interaction(main_figure,'interaction','WindowButtonDownFcn','id',1,'interaction_fcn',{@create_region,main_figure,'Polygon',''});

%                 set(enabled_obj,'Enable','on');
                return;
        end
        
        check_xy();
        u=length(xinit)+1;
        
        if isvalid(hp)
            set(hp,'XData',xinit,'YData',yinit);
        else
            hp=plot(ah,xinit,yinit,'color',col_line,'linewidth',1,'Tag','reg_temp');
        end
        
        
    end

    function check_xy()
        xinit(isnan(xinit))=[];
        yinit(isnan(yinit))=[];
        x_rem=xinit>xdata(end)|xinit<xdata(1);
        y_rem=yinit>ydata(end)|yinit<ydata(1);

        xinit(x_rem|y_rem)=[];
        yinit(x_rem|y_rem)=[];
        
%         [x_f,IA,~] = unique(xinit);
%         y_f=yinit(IA);
    end

    function wbucb(main_figure,~)
        
        replace_interaction(main_figure,'interaction','WindowButtonMotionFcn','id',2);
        
        x_data_disp=linspace(xdata(1),xdata(end),length(xdata));
        xinit(isnan(xinit))=[];
        yinit(isnan(yinit))=[];
        xinit(xinit>xdata(end))=xdata(end);
        xinit(xinit<xdata(1))=xdata(1);
        
        yinit(yinit>ydata(end))=ydata(end);
        yinit(yinit<ydata(1))=ydata(1);
        
        poly_r=nan(size(yinit));
        poly_pings=nan(size(xinit));
        for i=1:length(xinit)
            [~,poly_pings(i)]=nanmin(abs(xinit(i)-double(x_data_disp)));
            [~,poly_r(i)]=nanmin(abs(yinit(i)-double(ydata)));
            
        end
        clear_lines(ah)
        delete(txt);
        delete(hp);
        if length(poly_pings)<=2
            return;
        end
        poly_pings=round([poly_pings poly_pings(1)]);
        poly_r=round([poly_r poly_r(1)]);

        feval(func,main_figure,poly_r,poly_pings);

        
    end

    
end
