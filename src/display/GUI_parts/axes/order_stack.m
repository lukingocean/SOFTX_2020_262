    %% order_stack.m
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
% * |echo_ax|: TODO: write description and info on variable
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
% * 2017-04-02: header (Alex Schimel).
% * YYYY-MM-DD: first version (Yoann Ladroit). TODO: complete date and comment
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function order_stack(echo_ax,varargin)

p = inputParser;

%profile on;
addRequired(p,'echo_ax',@ishandle);
addParameter(p,'bt_on_top',0);

parse(p,echo_ax,varargin{:});
echo_im=findobj(echo_ax,'tag','echo');
bt_im=findobj(echo_ax,'tag','bad_transmits');
lines=findobj(echo_ax,'Type','Line','-not','tag','region');
text_disp=findobj(echo_ax,'Type','Text');
regions=findobj(echo_ax,'tag','region');
%region_text=findobj(echo_ax,'tag','region_text','-and','visible','on');
select_area=getappdata(ancestor(echo_ax,'Figure'),'SelectArea');
if ~isempty(select_area)
    select_area=select_area.patch_h;
    if ~isempty(select_area)
        if ~isvalid(select_area)
            select_area=[];
        end
    end
end
zoom_area=findobj(echo_ax,'tag','zoom_area','-or','Tag','disp_area');

switch echo_ax.Tag
    case 'main'
        if p.Results.bt_on_top==0
            uistack([text_disp;lines;select_area;regions;bt_im;echo_im],'top');
        else
            uistack([bt_im,zoom_area;text_disp;lines;select_area;regions;echo_im],'top');
        end
    case 'mini'
        uistack([zoom_area;bt_im;text_disp;lines;regions;echo_im],'top');
end

echo_ax.Layer='top';
end