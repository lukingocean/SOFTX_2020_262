%% load_bot_reg_data_fig_from_db.m
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
function load_bot_reg_data_fig_from_db(main_figure)

layer=get_current_layer();

if isempty(layer)
    return;
else
    [path_xml,reg_bot_file_str,bot_file_str]=layer.create_files_str();
end

nb_bot=1;
nb_reg=1;
for ip=1:length(path_xml)
    db_file=fullfile(path_xml{ip},'bot_reg.db');
    
    if exist(db_file,'file')==0
        initialize_reg_bot_db(db_file);
    end
    
    dbconn=sqlite(db_file,'connect');
    
    regions_db_temp=dbconn.fetch(sprintf('select Version,Filename,Comment,Save_time from region where Filename is "%s" order by datetime(Save_time)',reg_bot_file_str{ip}));
    bottom_db_temp=dbconn.fetch(sprintf('select Version,Filename,Comment,Save_time from bottom where Filename is "%s" order by datetime(Save_time)',bot_file_str{ip}));
    dbconn.close();
    
    if ~isempty(bottom_db_temp)
        botDataSummary(nb_bot:nb_bot+size(bottom_db_temp,1)-1,1)=bottom_db_temp(:,1);
        botDataSummary(nb_bot:nb_bot+size(bottom_db_temp,1)-1,2)=bottom_db_temp(:,2);
        botDataSummary(nb_bot:nb_bot+size(bottom_db_temp,1)-1,3)=bottom_db_temp(:,3);
        botDataSummary(nb_bot:nb_bot+size(bottom_db_temp,1)-1,4)=bottom_db_temp(:,4);
    end
    if ~isempty(regions_db_temp)
        regDataSummary(nb_reg:nb_reg+size(regions_db_temp,1)-1,1)=regions_db_temp(:,1);
        regDataSummary(nb_reg:nb_reg+size(regions_db_temp,1)-1,2)=regions_db_temp(:,2);
        regDataSummary(nb_reg:nb_reg+size(regions_db_temp,1)-1,3)=regions_db_temp(:,3);
        regDataSummary(nb_reg:nb_reg+size(regions_db_temp,1)-1,4)=regions_db_temp(:,4);
    end
    nb_bot=nb_bot+size(bottom_db_temp,1);
    nb_reg=nb_reg+size(regions_db_temp,1);
end

if nb_reg==1
    regDataSummary=[];
end

if nb_bot==1
    botDataSummary=[];
end



reg_bot_data_fig=new_echo_figure(main_figure,...
    'Units','pixels',...
    'Position',[0 0 1000 300],...
    'Resize','off',...
    'MenuBar','none',...
    'Name','Region Bottom Version','Tag','reg_bot_ver','WindowStyle','modal');


% Column names and column format
columnname = {'Version' 'File' 'Comment' 'Date'};
columnformat = {'numeric' 'char' 'char','char'};

% Create the uitable
uicontrol(reg_bot_data_fig,'Style','Text','String','BOTTOM','Units','Normalized','Position',[0.1 0.95 0.3 0.05],'Fontweight','bold','Background','w');
bot_data_table.table_main = uitable('Parent',reg_bot_data_fig,...
    'Data', botDataSummary,...
    'ColumnName', columnname,...
    'ColumnFormat', columnformat,...
    'CellSelectionCallback',@selec_ver_cback,...
    'CellEditCallback',{@insert_comment,main_figure},...
    'ColumnEditable', [false false true false],...
    'Units','Normalized','Position',[0 0 0.5 0.95],...
    'RowName',[],'tag','bot');
pos_t = getpixelposition(bot_data_table.table_main);
set(bot_data_table.table_main,'ColumnWidth',...
    num2cell(pos_t(3)*[0.1 0.35 0.35 0.2]));

rc_menu = uicontextmenu(ancestor(bot_data_table.table_main,'figure'),'tag','bot');
uimenu(rc_menu,'Label','Load Selected bottom version','Callback',{@import_bot_reg_cback,main_figure});
uimenu(rc_menu,'Label','Remove Selected bottom version','Callback',{@remove_selected_version,main_figure});
bot_data_table.table_main.UIContextMenu =rc_menu;
%set_single_select_mode_table(bot_data_table.table_main) ;

% Create the uitable
uicontrol(reg_bot_data_fig,'Style','Text','String','REGIONS','Units','Normalized','Position',[0.6 0.95 0.3 0.05],'Fontweight','bold','Background','w');
reg_data_table.table_main = uitable('Parent',reg_bot_data_fig,...
    'Data', regDataSummary,...
    'ColumnName', columnname,...
    'ColumnFormat', columnformat,...
    'CellSelectionCallback',@selec_ver_cback,...
    'CellEditCallback',{@insert_comment,main_figure},...
    'ColumnEditable', [false false true false],...
    'Units','Normalized','Position',[0.5 0 0.5 0.95],...
    'RowName',[],'tag','reg');
pos_t = getpixelposition(reg_data_table.table_main);
set(reg_data_table.table_main,'ColumnWidth',...
    num2cell(pos_t(3)*[0.1 0.35 0.35 0.2]));

%set_single_select_mode_table(reg_data_table.table_main) ;

rc_menu = uicontextmenu(ancestor(reg_data_table.table_main,'figure'),'tag','reg');
uimenu(rc_menu,'Label','Load Selected region version','Callback',{@import_bot_reg_cback,main_figure});
uimenu(rc_menu,'Label','Remove Selected region version','Callback',{@remove_selected_version,main_figure});
reg_data_table.table_main.UIContextMenu =rc_menu;

setappdata(reg_bot_data_fig,'bot_data_table',bot_data_table);
setappdata(reg_bot_data_fig,'reg_data_table',reg_data_table);
setappdata(reg_bot_data_fig,'bot_ver_select',[]);
setappdata(reg_bot_data_fig,'reg_ver_select',[]);


end

function selec_ver_cback(src,event)

reg_bot_data_fig=ancestor(src,'figure');

if size(event.Indices,1)>0
    version=unique(cell2mat(src.Data(unique(event.Indices(:,1)),1)));
else
    version=[];
end
switch src.Tag
    case 'reg'
        setappdata(reg_bot_data_fig,'reg_ver_select',version);
    case 'bot'
        setappdata(reg_bot_data_fig,'bot_ver_select',version);
end


end

function insert_comment(src,evt,main_figure)
layer=get_current_layer();
reg_bot_data_fig=ancestor(src,'figure');

[path_xml,reg_file_str,bot_file_str]=layer.create_files_str();

switch src.Tag
    case 'bot'
        tb=getappdata(reg_bot_data_fig,'bot_data_table');
        str_w='bottom';
        files=bot_file_str;
        str_file='Bot_XML';
    case 'reg'
        
        tb=getappdata(reg_bot_data_fig,'reg_data_table');
        str_w='region';
        files=reg_file_str;
        str_file='Reg_XML';
end
ver=tb.table_main.Data{evt.Indices(1),1};
Comment=tb.table_main.Data{evt.Indices(1),3};
idx_ver=cellfun(@(x) x==ver,tb.table_main.Data(:,1));
tb.table_main.Data(idx_ver,3)={Comment};
for ip=1:length(path_xml)
    db_file=fullfile(path_xml{ip},'bot_reg.db');
    
    dbconn=sqlite(db_file,'connect');
    
    data_db=dbconn.fetch(sprintf('select Filename,%s,Save_time,Comment,Version from %s WHERE Filename is "%s" AND Version = %f',...
        str_file,str_w,files{ip},ver));
    dbconn.exec(sprintf('delete from %s WHERE Filename is "%s" AND Version = %f',str_w,files{ip},ver));
    dbconn.insert(str_w,{'Filename' str_file 'Save_time' 'Comment' 'Version'},...
        {data_db{1} data_db{2} data_db{3} Comment ver});
    
    dbconn.close();
end
end

function remove_selected_version(src,~,main_figure)

layer=get_current_layer();
reg_bot_data_fig=ancestor(src,'figure');

if isempty(layer)
    return;
end

[path_xml,reg_file_str,bot_file_str]=layer.create_files_str();
switch src.Parent.Tag
    case 'bot'
        ver=getappdata(reg_bot_data_fig,'bot_ver_select');
        str_w='bottom';
        files=bot_file_str;
    case 'reg'
        ver=getappdata(reg_bot_data_fig,'reg_ver_select');
        str_w='region';
        files=reg_file_str;
end
war_str = sprintf('WARNING: The selected %s version(s) will be deleted from the database. Proceed?',str_w);

choice = question_dialog_fig(main_figure,'',war_str);

% Handle response
switch choice
    case 'Yes'
    otherwise
        return;
end

for ip=1:length(path_xml)
    db_file=fullfile(path_xml{ip},'bot_reg.db');
    
    dbconn=sqlite(db_file,'connect');
    %test=dbconn.fetch(sprintf('select * from %s WHERE Filename is "%s" AND Version = %f',str_w,file_str{ip},ver));
    for iv=1:numel(ver)
        dbconn.exec(sprintf('delete from %s WHERE Filename is "%s" AND Version = %f',str_w,files{ip},ver(iv)));
    end
    dbconn.close();
end

load_bot_reg_data_fig_from_db(main_figure);
end

%%
function import_bot_reg_cback(src,~,main_figure)

layer=get_current_layer();
reg_bot_data_fig=ancestor(src,'figure');

curr_disp=get_esp3_prop('curr_disp');
if isempty(layer)
    return;
end

switch src.Parent.Tag
    case 'bot'
        ver=getappdata(reg_bot_data_fig,'bot_ver_select');
        str_w='Bottom';
    case 'reg'
        ver=getappdata(reg_bot_data_fig,'reg_ver_select');
        str_w='Region';
end
war_str = sprintf('WARNING: This will replace the currently defined %s and the latest saved version (xml) with this database version. Proceed?',str_w);

choice=question_dialog_fig(main_figure,'',war_str);

% Handle response
switch choice
    case 'Yes'
    otherwise
        return;
end

switch src.Parent.Tag
    case 'bot'
        layer.load_bot_regs('bot_ver',ver,'reg_ver',[]);
        display_bottom(main_figure);
    case 'reg'
        layer.load_bot_regs('bot_ver',[],'reg_ver',ver);
        display_regions(main_figure,'all');
        curr_disp.setActive_reg_ID({});
end

set_alpha_map(main_figure,'main_or_mini',union({'main','mini'},layer.ChannelID));

order_stacks_fig(main_figure,curr_disp);

end
