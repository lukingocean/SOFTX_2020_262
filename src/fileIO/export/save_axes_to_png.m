function save_axes_to_png(main_figure,axes_to_copy,path_echo,fileN)

layer=get_current_layer();
if isempty(layer)
    return;
end
% multi_freq_disp_tab_comp=setappdata(main_figure,tab_tag);
% 
% axes_to_copy=multi_freq_disp_tab_comp.ax;

pos=getpixelposition(axes_to_copy);
new_fig=new_echo_figure(main_figure,'Units','Pixels','Position',[0 0 pos(3) pos(4)],...
    'Name','','Tag','save_curve');

new_axes=copyobj(axes_to_copy,new_fig);
set(new_axes,'Units','normalized','outerposition',[0 0 1 1]);

% text_obj=findobj(new_fig,'-property','Fontsize');
% set(text_obj,'Fontsize',10);
% 
% line_obj=findobj(new_fig,'-property','Linewidth');
% set(line_obj,'Linewidth',1);
set(new_fig,'Visible','off');
drawnow;
switch fileN
    case '-clipboard'
         print(new_fig,'-clipboard','-dbitmap');
         %hgexport(new_fig,'-clipboard');
    otherwise
        if isempty(path_echo)
            [path_echo,~,~]=fileparts(layer.Filename{1});
        end
        
        if isempty(fileN)
            layers_Str=list_layers(layer,'nb_char',80);
            fileN=[layers_Str{1} '.png'];
        end
        
        print(new_fig,fullfile(path_echo,fileN),'-dpng','-r300');
end
close(new_fig);

end