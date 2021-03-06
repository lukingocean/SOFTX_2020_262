function keyboard_zoom(plus_or_minus,main_figure)

layer=get_current_layer();

if isempty(layer)
    return;
end

axes_panel_comp=getappdata(main_figure,'Axes_panel');
ah=axes_panel_comp.main_axes;

x_lim=get(ah,'XLim');
y_lim=get(ah,'YLim');

curr_disp=get_esp3_prop('curr_disp');


[trans_obj,idx_freq]=layer.get_trans(curr_disp);


xdata_tot=trans_obj.get_transceiver_pings();
ydata_tot=trans_obj.get_transceiver_samples();

[x_lim,y_lim]=compute_xylim_zoom(x_lim,y_lim,'VerticalScrollCount',plus_or_minus,...
    'x_lim_tot',[xdata_tot(1) xdata_tot(end)],'y_lim_tot',[ydata_tot(1) ydata_tot(end)]);


if diff(x_lim)<=0||diff(y_lim)<=0
    return;
end

set(ah,'XLim',x_lim,'YLim',y_lim);


end