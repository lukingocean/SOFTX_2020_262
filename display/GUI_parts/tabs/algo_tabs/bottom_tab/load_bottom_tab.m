
%% Function
function load_bottom_tab(main_figure,algo_tab_panel)

tab_main=uitab(algo_tab_panel,'Title','Bottom Detect');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Version 1%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
algo_name= 'BottomDetection';

load_algo_panel('main_figure',main_figure,...
        'panel_h',uipanel(tab_main,'Position',[0 0 0.5 1]),...
        'algo_name',algo_name,...
        'title','Version 1',...
        'save_fcn_bool',true);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

algo_name= 'BottomDetectionV2';
load_algo_panel('main_figure',main_figure,...
        'panel_h',uipanel(tab_main,'Position',[0.5 0 0.5 1]),...
        'algo_name',algo_name,...
        'title','Version 2',...
        'save_fcn_bool',true);

end
