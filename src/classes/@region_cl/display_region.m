%% display_region.m
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
% * |reg_obj|: TODO: write description and info on variable
% * |trans_obj|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |h_fig|: TODO: write description and info on variable
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
function h_fig = display_region(reg_obj,trans_obj,varargin)

%% input variable management

p = inputParser;

% default values
field_def='sv';
TS_def=-52;
[cax_d,~,~]=init_cax(field_def);
addRequired(p,'reg_obj',@(obj) isa(obj,'region_cl'));
addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl')|isstruct(obj));
addParameter(p,'line_obj',[],@(x) isa(x,'line_cl')||isempty(x));
addParameter(p,'Name',reg_obj.print(),@ischar);
addParameter(p,'Cax',cax_d,@isnumeric);
addParameter(p,'Cmap','ek60',@ischar);
addParameter(p,'alphadata',[],@isnumeric);
addParameter(p,'field',field_def,@ischar);
addParameter(p,'TS',TS_def,@isnumeric);
addParameter(p,'main_figure',[],@(h) isempty(h)|ishghandle(h));
addParameter(p,'parent',[],@(h) isempty(h)|ishghandle(h));
addParameter(p,'load_bar_comp',[]);

parse(p,reg_obj,trans_obj,varargin{:});

%%

h_fig=p.Results.parent;

field= p.Results.field;
if isa(trans_obj,'transceiver_cl')
           %profile on;
    %      output_reg_old=trans_obj.integrate_region(reg_obj);
%profile on;
    %output_reg_old=trans_obj.integrate_region_v4(reg_obj,'line_obj',p.Results.line_obj,'denoised',1); 
     output_reg=trans_obj.integrate_region(reg_obj,'line_obj',p.Results.line_obj,'denoised',1,'load_bar_comp',p.Results.load_bar_comp);

%      profile off;
%      profile viewer;
% output_reg_old=trans_obj.integrate_region_v4(reg_obj,'line_obj',p.Results.line_obj,'denoised',1); 
% output_reg_old=trans_obj.integrate_region_v3(reg_obj,'line_obj',p.Results.line_obj,'denoised',1); 
% compare_reg_output(output_reg,output_reg_old,reg_obj.Reference);
  
    tt=sprintf('%s %s %.0f kHz ' ,field,p.Results.Name,trans_obj.get_params_value('FrequencyStart',1)/1e3 );
    
else
    output_reg=trans_obj;
    tt=sprintf('%s %s' ,field,p.Results.Name );
    
end

if isempty(output_reg)
    h_fig=[];
    return;
end


curr_disp=get_esp3_prop('curr_disp');


%% getting data to display
switch field
    case 'fishdensity'
        var_disp=db2pow_perso((pow2db_perso(output_reg.sv_mean)-p.Results.TS));
        var_lin=(var_disp);
        var_scale='lin';
        ylab='(number/m3)';
    case {'sv' 'sp' 'spdenoised' 'svdenoised'}
        var_disp=pow2db_perso(output_reg.sv_mean);
        var_lin=db2pow_perso(var_disp);
        var_scale='db';
        ylab='dB';
end

if istall(var_disp)
    var_disp=gather(var_disp);
    var_lin=gather(var_lin);
end

%% color bounds and cmap
if ~isempty(curr_disp)
    if ismember('Cax',p.UsingDefaults)
        cax=curr_disp.getCaxField(field);
        cax_list=addlistener(curr_disp,'Cax','PostSet',@(src,envdata)listenCaxReg(src,envdata));
    else
        cax=p.Results.Cax;
        cax_list=[];
    end
    
    if ismember('Cmap',p.UsingDefaults)
        cmap_name=curr_disp.Cmap;
        cmap_list=addlistener(curr_disp,'Cmap','PostSet',@(src,envdata)listenCmapReg(src,envdata));
    else
        cmap_name=p.Results.Cmap;
        cmap_list=[];
    end
    
else
    cax=p.Results.Cax;
    cmap_name=p.Results.Cmap;
    cmap_list=[];
    cax_list=[];
end

%% remove data outside colour scale through alpha
if ~ismember('alphadata',p.UsingDefaults)&&all(size(var_disp)==size(p.Results.alphadata))
    alphadata=p.Results.alphadata;
else
    alphadata=double(var_disp>cax(1));
end

if ~any(~isnan(var_disp))
    h_fig=[];
    return;
end

%% X and Y disp

switch reg_obj.Cell_w_unit
    case 'pings'
        x_disp=output_reg.Ping_S;
    case 'meters'
        x_disp=(output_reg.Dist_S+output_reg.Dist_E)/2;
     case 'seconds'
        x_disp=(output_reg.Time_S+output_reg.Time_E)/2;       
end



%% create new figure here
if isempty(h_fig)
h_fig=new_echo_figure(p.Results.main_figure,'Name',tt,'Tag',[tt reg_obj.tag_str()],...
    'Units','normalized','Position',[0.1 0.2 0.8 0.6],'Group','Regions','Windowstyle','Docked','Toolbar','esp3','MenuBar','esp3');
end
%% main region display

% axes
ax_in=axes('Parent',h_fig,'Units','Normalized','position',[0.2 0.25 0.7 0.65],'xticklabel',{},'yticklabel',{},'nextplot','add','box','on','TickLength',[0 0],'GridAlpha',0.05);

% title
title(ax_in,tt);

switch reg_obj.Reference
    case 'Surface'
        y_disp=(output_reg.Depth_min);
    case {'Transducer', 'Line'}
        y_disp=output_reg.Range_ref_min;
    case {'Bottom'}        
        y_disp=-(output_reg.Range_ref_min);
end


if istall(x_disp)
   x_disp=gather(x_disp); 
end

if istall(y_disp)
   y_disp=gather(y_disp); 
end


% data

mat_size=size(var_disp);
if  ~any(mat_size==1)
    reg_plot=imagesc(ax_in,x_disp,y_disp(:,1),var_disp);
    %set(reg_plot,'alphadata',alphadata,'facealpha','flat','edgecolor','none','AlphaDataMapping','none');
    set(reg_plot,'alphadata',alphadata,'AlphaDataMapping','none');
    create_context_menu_int_plot(reg_plot)
    uimenu(reg_plot.UIContextMenu,'Label','Hide vertical profile','Callback',{@hide_axes_cback,'vert'},'Checked','off');
    uimenu(reg_plot.UIContextMenu,'Label','Hide horizontal profile','Callback',{@hide_axes_cback,'horz'},'Checked','off');
end
ymin=nanmin(y_disp(~isinf(y_disp)));
ymax=nanmax(y_disp(~isinf(y_disp)));

xmin=nanmin(x_disp);
xmax=nanmax(x_disp);

% ticks and grid

ax_in.XTick=unique(x_disp(~isnan(x_disp)));
ax_in.YTick=sort((ymin:reg_obj.Cell_h:ymax));

grid(ax_in,'on');

% colour
caxis(ax_in,cax);
cb=colorbar(ax_in,'Position',[0.92 0.25 0.03 0.65],'PickableParts','none');
cb.UIContextMenu=[];
[cmap,col_ax,~,col_grid,~,~,~]=init_cmap(cmap_name);
colormap(ax_in,cmap);
set(ax_in,'GridColor',col_grid,'Color',col_ax);

%% linear or dB scales for bottom and side displays

switch var_scale
    case 'lin'
        horz_plot=nanmean(var_lin,1);
        vert_plot=nanmean(var_lin,2);
    case 'db'
        horz_plot=pow2db_perso(nanmean(var_lin,1));
        vert_plot=pow2db_perso(nanmean(var_lin,2));
end

%% bottom display

% axes
ax_horz=axes('Parent',h_fig,'Units','Normalized','position',[0.2 0.1 0.7 0.15],'nextplot','add','box','on');

% data
plot(ax_horz,x_disp,horz_plot,'r');

% grid, labels, ticks, etc
grid(ax_horz,'on');
ylabel(ax_horz,ylab)
%ax_horz.XTick=get(ax_in,'XTick');
ax_horz.XTickLabelRotation=90;

switch reg_obj.Cell_w_unit
    case 'meters'
        ax_horz.XAxis.TickLabelFormat='%.0fm';
    case 'pings'
        ax_horz.XAxis.TickLabelFormat='%.0f';
    case 'seconds'
        ax_horz.XTickLabels=cellfun(@(x) datestr(x,'HH:MM:SS'),num2cell(ax_horz.XTick),'un',0);
end

ax_horz.XAxis.ExponentMode='manual';
ax_horz.XAxis.Exponent=0;
ax_horz.XAxis.TickDirection='out';
%% side display

% axes
ax_vert=axes('Parent',h_fig,'Units','Normalized','position',[0.05 0.25 0.15 0.65],'xaxislocation','top','nextplot','add','box','on','DeleteFcn',@delete_axes);

% data
plot(ax_vert,vert_plot,nanmean(y_disp,2),'r');

% grid, labels, ticks, etc
xlabel(ax_vert,ylab)


switch reg_obj.Reference
    case 'Surface'
        ylabel(ax_vert,'Depth');
        axis(ax_in,'ij');
        axis(ax_vert,'ij');
    case 'Bottom'
        ylabel(ax_vert,'Distance Above bottom');
    case 'Transducer'
        ylabel(ax_vert,'Distance from transducer face');
        axis(ax_in,'ij');
        axis(ax_vert,'ij');
    case 'Line'
        ylabel(ax_vert,'Distance From line');
        axis(ax_in,'ij');
        axis(ax_vert,'ij');
end

grid(ax_vert,'on');

ax_vert.YAxis.TickLabelFormat='%.0gm';
ax_vert.YAxis.TickDirection='out';
%% link axes of main display and bottom/side plots
linkaxes([ax_in ax_vert],'y');
linkaxes([ax_in ax_horz],'x');


%% final adjust axes
if xmax>xmin
    set(ax_in,'Xlim',[xmin xmax]);
end
if ymax>ymin
    set(ax_in,'Ylim',[ymin ymax]);
end
%% nest functions

    function hide_axes_cback(src,evt,ax_str)
       switch ax_str 
           case 'horz'
               ax= ax_horz;
               ax_s=ax_vert;
               id= 4;
               cbar_h=1;
           case 'vert'
               ax= ax_vert;
               ax_s= ax_horz;
               id = 3;
               cbar_h=0;
           otherwise
          return;
       end
       
       switch src.Checked
           case 'off'
               src.Checked = 'on';
               dd=0.15;           
           case 'on'
               src.Checked = 'off';
               dd=-0.15  ;  
       end
       
       ax.Position(id) = ax.Position(id)-dd;
       ax_in.Position(id-2) =ax_in.Position(id-2)-dd;
       ax_in.Position(id) =ax_in.Position(id)+dd;
       ax_s.Position(id-2) =ax_s.Position(id-2)-dd;
       ax_s.Position(id) =ax_s.Position(id)+dd;
       cb.Position(id) = cb.Position(id)+cbar_h*dd;
       cb.Position(id-2) = cb.Position(id-2)-cbar_h*dd;
    end
% Figure close request callback for region display
    function delete_axes(src,~)
        if ~isdeployed
            disp('delete_axes reg listeners')
        end
        delete(cmap_list) ;
        delete(cax_list) ;
        delete(src);
    end

% Listener for colourmap
    function listenCmapReg(src,evt)
        if ~isdeployed
            disp('listenCmapReg')
        end
        [cmap,col_ax,~,col_grid,~,~,~]=init_cmap(evt.AffectedObject.Cmap);
        try
            if isvalid(ax_in)
                colormap(ax_in,cmap);
                set(ax_in,'GridColor',col_grid,'Color',col_ax);
            end
        catch
            
            delete(cmap_list);
            delete(cax_list);
        end
    end

% Listener for alpha values to limit data shown
    function listenCaxReg(src,evt)
        cax=evt.AffectedObject.getCaxField(field);
        if ~isdeployed
            disp('listenCaxReg')
        end
        if exist('ax_in','var')>0
            
            if isvalid(ax_in)
                caxis(ax_in,cax);
                alphadata=double(var_disp>cax(1));
                set(reg_plot,'alphadata',alphadata)
            end
        else
             delete(cmap_list);        
           delete(cax_list);
        end
        
            
    end


end



