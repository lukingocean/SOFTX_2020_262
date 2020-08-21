function export_gps_to_csv_callback(~,~,main_figure,IDs,filename_append)

% get current layers
layers = get_esp3_prop('layers');
if isempty(layers)
    return;
end

% find layers to export
if ~iscell(IDs)
    IDs = {IDs};
end
if isempty(IDs{1})
    % empty IDs means do all layers
    layers_to_export = layers;
else
    % else, find the layers with input IDs
    idx = [];
    for id = 1:length(IDs)
        [idx_temp,found] = find_layer_idx(layers,IDs{id});
        if found == 0
            continue;
        end
        idx = union(idx,idx_temp);
    end
    layers_to_export = layers(idx);
end

% process per layer
for ilay = 1:length(layers_to_export)
    
    layer = layers_to_export(ilay);
    trans_obj = layer.Transceivers(1);
    gps_obj = trans_obj.GPSDataPing;
    filenames = layer.Filename;
    
    % process per file in layer
    for ifil = 1:length(filenames)
        
        % input file info
        input_fullfile = filenames{ifil};
        [path_f,fileN,~] = fileparts(input_fullfile);
        
        % get index of pings in dataset from this file
        idx_ping = find(trans_obj.Data.FileId==ifil);
        
        % output file name
        output_fullfile = fullfile(path_f,[fileN,filename_append,'.csv']);
        
        try
            % export
            gps_obj.save_gps_to_file(output_fullfile,idx_ping);
            
            % display
            disp_perso(main_figure,sprintf('Position for file %s exported as %s',input_fullfile,output_fullfile));
            
            % open resulting file
            open_txt_file(output_fullfile);
            
        catch err
            print_errors_and_warnings([],'error',err);
            warndlg_perso(main_figure,'',sprintf('Could not export GPS for file %s',input_fullfile));
        end
        
    end
end
