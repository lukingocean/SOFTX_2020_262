function import_bot_from_evl_callback(~,~,main_figure)
layer=get_current_layer();

if isempty(layer)
return;
end
    
curr_disp=get_esp3_prop('curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);
[path_f,~,~]=fileparts(layer.Filename{1});

[Filename,PathToFile]= uigetfile({fullfile(path_f,'*.evl')}, 'Pick a .evl','MultiSelect','off');
if isempty(Filename)
    return;
end

trans_obj.setBottom_from_evl(fullfile(PathToFile,Filename))

set_current_layer(layer);
display_bottom(main_figure);
set_alpha_map(main_figure,'main_or_mini',union({'main','mini'},layer.ChannelID));
order_stacks_fig(main_figure);
end