%% import_regs_from_evr_callback.m
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
function import_regs_from_evr_callback(~,~,main_figure)

layer=get_current_layer();

if isempty(layer)
    return;
end


curr_disp=get_esp3_prop('curr_disp');
[trans_obj,~]=layer.get_trans(curr_disp);
[path_f,~,~]=fileparts(layer.Filename{1});

[Filename,PathToFile]= uigetfile({fullfile(path_f,'*.evr')}, 'Pick a .evr','MultiSelect','off');
if ~ischar(Filename)
    return;
end

regions=create_regions_from_evr(fullfile(PathToFile,Filename),trans_obj.get_transceiver_range(),trans_obj.Time);

if ~isempty(regions)
    trans_obj.add_region(regions);
    
    display_bottom(main_figure);
    
    display_regions(main_figure,'both');
    curr_disp=get_esp3_prop('curr_disp');
    curr_disp.setActive_reg_ID({});

    set_alpha_map(main_figure,'main_or_mini',union({'main','mini'},curr_disp.ChannelID));
    
end

end