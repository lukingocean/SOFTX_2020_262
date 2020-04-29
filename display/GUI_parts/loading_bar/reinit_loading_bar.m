function reinit_loading_bar(main_figure)
load_bar_comp=getappdata(main_figure,'Loading_bar');
if ~isempty(load_bar_comp)
    set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',100, 'Value',0, 'StringPainted',1);
    load_bar_comp.progress_bar.setText('');
end
end