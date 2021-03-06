%% measure_distance.m
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
% * |src|: TODO: write description and info on variable
% * |main_figure|: TODO: write description and info on variable
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
% * 2017-03-28: header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function measure_distance(src,~,main_figure)

if check_axes_tab(main_figure)==0
    return;
end

layer=get_current_layer();
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=get_esp3_prop('curr_disp');
ah=axes_panel_comp.main_axes;



clear_lines(ah)

% obj_meas=findobj(ah,'Tag','measurement_text','-or','Tag','measurement');
% delete(obj_meas);
[cmap,col_ax,text_col,col_grid,col_bot,col_txt,line_col]=init_cmap(curr_disp.Cmap);
 

[trans_obj,idx_freq]=layer.get_trans(curr_disp);

xdata=trans_obj.get_transceiver_pings();
ydata=trans_obj.get_transceiver_samples();
range_t=trans_obj.get_transceiver_range();
gps_data=trans_obj.GPSDataPing;

xinit=nan(1,1e2);
yinit=nan(1,1e2);
x_dist=zeros(1,1e2);
y_dist=zeros(1,1e2);
lat=nan(1,1e2);
lon=nan(1,1e2);
calc_dist=zeros(1,1e2);
straight_dist=zeros(1,1e2);

cp = ah.CurrentPoint;
click_num=1;
x_lim=get(ah,'xlim');
y_lim=get(ah,'ylim');
if cp(1,1)<x_lim(1)||cp(1,1)>x_lim(end)||cp(1,2)<y_lim(1)||cp(1,2)>y_lim(end)
    return;
end

switch src.SelectionType
    case {'normal'}
        hp=plot(ah,xinit,yinit,'color',line_col,'linewidth',1,'Tag','measurement','linestyle','--');
        ht=text(ah,xinit,yinit,'','Tag','measurement_text','Color',text_col);
        add_point(cp(1,1),cp(1,2));
        click_num=2;
 
        replace_interaction(main_figure,'interaction','WindowButtonMotionFcn','id',2,'interaction_fcn',@wbmcb);
        replace_interaction(main_figure,'interaction','WindowButtonDownFcn','id',1,'interaction_fcn',@wbdf);

    otherwise
        return;
end
    function wbmcb(~,~)
        cp=ah.CurrentPoint;
        add_point(cp(1,1),cp(1,2));
    end

    function wbdf(src,~)
        
        switch src.SelectionType
            case {'alt'}
                delete(hp);
                delete(ht)
                replace_interaction(main_figure,'interaction','WindowButtonMotionFcn','id',2);
                replace_interaction(main_figure,'interaction','WindowButtonDownFcn','id',1,'interaction_fcn',{@measure_distance,main_figure});
                
                return;
        end
        
        cp=ah.CurrentPoint;
        click_num=click_num+1;
        add_point(cp(1,1),cp(1,2));
        
    end

    function add_point(xadd,yadd)
        if xadd<xdata(1)||xadd>xdata(end)||yadd<1||yadd>ydata(end)
            return;
        end

        [~,idx_ping]=nanmin(abs(xdata-xadd));
        [~,idx_r]=nanmin(abs(ydata-yadd));
        
        
        xinit(click_num)=xadd;
        yinit(click_num)=yadd;
        x_dist(click_num)=gps_data.Dist(idx_ping);
        y_dist(click_num)=range_t(idx_r);

        lat(click_num)=gps_data.Lat(idx_ping);
        lon(click_num)=gps_data.Long(idx_ping);
        
        if click_num>1            
            calc_dist(click_num)=sqrt((x_dist(click_num)-x_dist(click_num-1))^2+(y_dist(click_num)-y_dist(click_num-1))^2);
            straight_dist(click_num)=sqrt((1000*lat_long_to_km(lat(click_num-1:click_num),lon(click_num-1:click_num)))^2+(y_dist(click_num)-y_dist(click_num-1))^2);
            str_dist=sprintf('Integrated dist: %.2fm\n Straigth line dist: %.2fm\n',nansum(calc_dist),nansum(straight_dist));
        else
            str_dist='';
        end
        set(ht,'Position',[xadd yadd],'String',str_dist);
        set(hp,'XData',xinit,'YData',yinit);
        set(hp,'XData',xinit,'YData',yinit);
        
    end
end
