function update_file_panel(main_figure)
if isappdata(main_figure,'file_tab')
    return;
end

layer=get_current_layer();
if isempty(layer)
    return;
end

[path_f,~]=layer.get_path_files();


file_tab_comp=getappdata(main_figure,'file_tab');
file_tab_comp.FileChooser.setCurrentDirectory(java.io.File(path_f{1}));
cla(file_tab_comp.map_axes);
setappdata(main_figure,'file_tab',file_tab_comp);

end
