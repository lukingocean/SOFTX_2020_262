
function save_display_algos_config_callback(~,~,main_figure,name)
curr_disp=get_esp3_prop('curr_disp');

layer=get_current_layer();
if isempty(layer)
    return;
end
update_algos('algo_name',{name});

idx_algo=find(strcmpi({layer.Algo(:).Name},name),1);

if ~isempty(idx_algo)
    algos=layer.Algo;
else
    [trans_obj,idx_freq]=layer.get_trans(curr_disp);
    algos=trans_obj.Algo;
    [idx_algo,found]=find_algo_idx(trans_obj,name);
    if found==0
        return;
    end
end
algo_panels = getappdata(main_figure,'Algo_panels');
if isempty(algo_panels)
    return;
end

panel_obj=algo_panels.get_algo_panel(name);

if isempty(panel_obj)
    return;
end

if ~isempty(panel_obj.default_params_h)
    names=get(panel_obj.default_params_h,'String');
    name_set=names(get(panel_obj.default_params_h,'value'));
    write_config_algo_to_xml(algos(idx_algo),{name_set},0);
else
    write_config_algo_to_xml(algos(idx_algo),{'--'},0);
end

end