%% zoom_in_callback_mini_ax.m
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
% * |evt|: TODO: write description and info on variable
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
function zoom_in_callback_mini_ax(~,evt,main_figure)

mini_ax_comp=getappdata(main_figure,'Mini_axes');
curr_disp=get_esp3_prop('curr_disp');

 [cmap,col_ax,col_lab,col_grid,col_bot,col_txt,~]=init_cmap(curr_disp.Cmap);
ah=mini_ax_comp.mini_ax;

current_fig=gcf;

switch current_fig.SelectionType
    case 'normal'
        mode='rectangular';
    otherwise
        return;
end


clear_lines(ah);

xdata=get(mini_ax_comp.mini_echo,'XData');
ydata=get(mini_ax_comp.mini_echo,'YData');

cp = ah.CurrentPoint;

switch mode
    case 'rectangular'
        xinit = cp(1,1);
        yinit = cp(1,2);
    case 'horizontal'
        xinit = xdata(1);
        yinit = cp(1,2);
    case 'vertical'
        xinit = cp(1,1);
        yinit = ydata(1);
end


if xinit<xdata(1)||xinit>xdata(end)||yinit<ydata(1)||yinit>ydata(end)
    return;
end

x_box=xinit;
y_box=yinit;
set(mini_ax_comp.patch_obj,'ButtonDownFcn','');

hp=line(x_box,y_box,'color',col_lab,'linewidth',1,'parent',ah);
%replace_interaction(main_figure,'interaction','WindowButtonMotionFcn','id',1);
replace_interaction(current_fig,'interaction','WindowButtonMotionFcn','id',2,'interaction_fcn',@wbmcb);
replace_interaction(current_fig,'interaction','WindowButtonUpFcn','id',2,'interaction_fcn',@wbucb);

    function wbmcb(~,~)
        cp = ah.CurrentPoint;
              
        switch mode
            case 'rectangular'
                X = [xinit,cp(1,1)];
                Y = [yinit,cp(1,2)];
            case 'horizontal'
                X = [xinit,xdata(end)];
                Y = [yinit,cp(1,2)];
            case 'vertical'
                X = [xinit,cp(1,1)];
                Y = [yinit,ydata(end)];
                
        end
        
        x_min=nanmin(X);
        x_min=nanmax(xdata(1),x_min);
        
        x_max=nanmax(X);
        x_max=nanmin(xdata(end),x_max);
        
        y_min=nanmin(Y);
        y_min=nanmax(y_min,ydata(1));
        
        y_max=nanmax(Y);
        y_max=nanmin(y_max,ydata(end));
        
        x_box=([x_min x_max  x_max x_min x_min]);
        y_box=([y_max y_max y_min y_min y_max]);
        
        set(hp,'XData',x_box,'YData',y_box);
        
        
    end

    function wbucb(src,~)
        delete(hp);
        %replace_interaction(main_figure,'interaction','WindowButtonMotionFcn','id',1,'interaction_fcn',{@update_info_panel,0});
        replace_interaction(current_fig,'interaction','WindowButtonMotionFcn','id',2);
        replace_interaction(current_fig,'interaction','WindowButtonUpFcn','id',2);

       
        if length(x_box)==1&&length(y_box)==1
            move_patch_mini_axis(src,evt,main_figure);        
        else
        
        y_min=nanmin(y_box);
        y_max=nanmax(y_box);
        
        y_min=nanmax(y_min,ydata(1));
        y_max=nanmin(y_max,ydata(end));
        
        x_min=nanmin(x_box);
        x_min=nanmax(xdata(1),x_min);
        
        x_max=nanmax(x_box);
        x_max=nanmin(xdata(end),x_max);
        
        
        if x_max==x_min||y_max==y_min
            x_lim=get(ah,'XLim');
            y_lim=get(ah,'YLim');
            dx=abs(diff(x_lim));
            dy=diff(y_lim);
            
            x_lim(1)=x_lim(1)+dx/4;
            y_lim(1)=y_lim(1)+dy/4;
            x_lim(2)=x_lim(2)-dx/4;
            y_lim(2)=y_lim(2)-dy/4;
            
        else
            x_lim=[x_min x_max];
            y_lim=[y_min y_max];
        end
        
        patch_obj=mini_ax_comp.patch_obj;
        new_vert=patch_obj.Vertices;
        new_vert(:,1)=[x_lim(1) x_lim(2) x_lim(2) x_lim(1)];
        new_vert(:,2)=[y_lim(1) y_lim(1) y_lim(2) y_lim(2)];
        
       
        axes_panel_comp=getappdata(main_figure,'Axes_panel');
        set(axes_panel_comp.main_axes,'XLim',x_lim);
        set(axes_panel_comp.main_axes,'YLim',y_lim);
        set(patch_obj,'Vertices',new_vert);
        
        end
        drawnow;
        set(mini_ax_comp.patch_obj,'ButtonDownFcn',{@move_patch_mini_axis_grab,main_figure});
    end

end