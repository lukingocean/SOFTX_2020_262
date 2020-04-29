
classdef layer_cl < matlab.mixin.Copyable
    properties
        Unique_ID=generate_Unique_ID([]);
        Filename={''};
        Filetype='';
        Transceivers=transceiver_cl.empty();
        OriginCrest='';
        Lines=line_cl.empty();
        ChannelID={''};
        Frequencies=[];
        AvailableChannelIDs={''};
        AvailableFrequencies=[];
        GPSData=gps_data_cl();
        AttitudeNav=attitude_nav_cl();
        EnvData=env_data_cl();
        Curves=[];
        EchoIntStruct=[];
        SurveyData=survey_data_cl.empty();
        Algo = algo_cl.empty();
        NotchFilter=[];
        
    end
    
    
    methods
        function obj = layer_cl(varargin)
            p = inputParser;
            
            
            check_att_class=@(obj) isa(obj,'attitude_nav_cl');
            check_gps_class=@(gps_data_obj) isa(gps_data_obj,'gps_data_cl');
            check_curve_cl=@(obj) isempty(obj)|isa(obj,'curve_cl');
            check_echo_int_cl=@(echo_int_struct) isempty(echo_int_struct)|isstruct(echo_int_struct);
            check_env_class=@(env_data_obj) isa(env_data_obj,'env_data_cl')|isempty(env_data_obj);
            check_transceiver_class=@(transceiver_obj) isa(transceiver_obj,'transceiver_cl')|isempty(transceiver_obj);
            check_line_class=@(obj) isa(obj,'line_cl')|isempty(obj);
            
            addParameter(p,'Unique_ID',generate_Unique_ID([]),@ischar);
            addParameter(p,'Filename',{'No Data'},@(fname)(iscell(fname)));
            addParameter(p,'Filetype','',@(ftype)(ischar(ftype)));
            addParameter(p,'Transceivers',transceiver_cl.empty(),check_transceiver_class);
            addParameter(p,'Lines',[],check_line_class);
            addParameter(p,'Frequencies',[],@isnumeric);
            addParameter(p,'ChannelID',{},@iscell);
            addParameter(p,'AvailableChannelIDs',{},@iscell);
            addParameter(p,'AvailableFrequencies',[],@isnumeric);
            addParameter(p,'GPSData',gps_data_cl(),check_gps_class);
            addParameter(p,'Curves',[],check_curve_cl);
            addParameter(p,'EchoIntStruct',[],check_echo_int_cl);
            addParameter(p,'AttitudeNav',attitude_nav_cl(),check_att_class);
            addParameter(p,'EnvData',env_data_cl(),check_env_class);
            addParameter(p,'OriginCrest','');
             addParameter(p,'Algo',algo_cl.empty(),@(x) isa(x,'algo_cl')||isempty(x));
            addParameter(p,'SurveyData',{survey_data_cl()},@(obj) isa(obj,'survey_data_cl')|iscell(obj)|isempty(obj))
            
            parse(p,varargin{:});
            results=p.Results;
            
            
            props=fieldnames(results);
            
            for i=1:length(props)
                obj.(props{i})=results.(props{i});
            end
            
            if ~iscell(obj.Filename)
                obj.Filename={obj.Filename};
            end
            
            
            obj.Frequencies=zeros(1,length(obj.Transceivers));
            obj.ChannelID=cell(1,length(obj.Transceivers));
            for ifr=1:length(obj.Transceivers)
                obj.Frequencies(ifr)=obj.Transceivers(ifr).Config.Frequency;
                obj.ChannelID{ifr}=deblank(obj.Transceivers(ifr).Config.ChannelID);
            end
            if isempty(obj.AvailableChannelIDs)
                obj.AvailableChannelIDs=deblank(obj.ChannelID);
                obj.AvailableFrequencies=obj.Frequencies;
            end
            
            obj.EchoIntStruct.output_2D={};
            obj.EchoIntStruct.output_2D_type={};
            obj.EchoIntStruct.regs_tot=[];
            obj.EchoIntStruct.regCellInt_tot={};
            obj.EchoIntStruct.reg_descr_table=[];
            obj.EchoIntStruct.shz_height_est=[];
            obj.EchoIntStruct.idx_freq_out=[];
            obj.EchoIntStruct.survey_options=[];
            
        end
        
        function set_EnvData(layer_obj,env_data_obj)
            props=properties(env_data_obj);
            
            for ipp=1:numel(props)
                if isnumeric(env_data_obj.(props{ipp}))
                    if ~isnan(env_data_obj.(props{ipp}))
                        layer_obj.EnvData.(props{ipp})=env_data_obj.(props{ipp});
                    end
                else
                    layer_obj.EnvData.(props{ipp})=env_data_obj.(props{ipp});
                end
                
            end
        end
        
        function regenerate_ID_num(layer_obj)
            layer_obj.Unique_ID=generate_Unique_ID([]);
        end
        
        function setNotchFilter(obj,bandstops,load_bar_comp)
            obj.NotchFilter=bandstops;
            obj.notch_filter_layer('load_bar_comp',load_bar_comp);
        end
        
        
        function set.ChannelID(obj,cid)
            obj.ChannelID=deblank(cid);
        end
        
        function set.AvailableChannelIDs(obj,cid)
            obj.AvailableChannelIDs=deblank(cid);
        end
        
        function [f_min,f_max,f_nom,f_start,f_end]=get_freq_min_max_nom_start_end(layer_obj)
            nb_c=numel(layer_obj.Frequencies);
            f_min=nan(1,nb_c);
            f_max=nan(1,nb_c);
            f_nom=nan(1,nb_c);
            f_start=nan(1,nb_c);
            f_end=nan(1,nb_c);
            
            for it=1:nb_c
                f_min(it)=layer_obj.Transceivers(it).Config.FrequencyMinimum(1);
                f_max(it)=layer_obj.Transceivers(it).Config.FrequencyMaximum(1);
                f_nom(it)=layer_obj.Transceivers(it).Config.Frequency;
                f_start(it)=layer_obj.Transceivers(it).get_params_value('FrequencyStart',1);
                f_end(it)=layer_obj.Transceivers(it).get_params_value('FrequencyEnd',1);
            end
            
        end
        
        function save_svp(obj,fname)
                if isempty(fname)
                    fname=obj.Filename{1};
                    [p,f,~,]=fileparts(fname);
                    fname=fullfile(p,f);
                end
                obj.EnvData.save_svp([fname '.espsvp']);
        end
        
        function save_ctd(obj,fname)
                if isempty(fname)
                    fname=obj.Filename{1};
                    [p,f,~,]=fileparts(fname);
                    fname=fullfile(p,f);
                end
                obj.EnvData.save_ctd([fname '.espctd']);
        end
        
        
        function load_ctd(obj,fname,ori)
                if isempty(fname)
                    fname=obj.Filename{1};
                    [p,f,~,]=fileparts(fname);
                    fname=fullfile(p,f);
                end
                obj.EnvData.load_ctd([fname '.espctd']);
                switch ori
                    case {'constant' 'theoritical' 'profile'}
                        obj.EnvData.CTD.ori=ori;
                end
        end
        
        function load_svp(obj,fname,ori)
            if isempty(fname)
                fname=obj.Filename{1};
                [p,f,~,]=fileparts(fname);
                fname=fullfile(p,f);
            end
            
            obj.EnvData.load_svp([fname '.espsvp']);
            
            switch ori
                case {'constant' 'theoritical' 'profile'}
                    obj.EnvData.SVP.ori=ori;
            end
        end
        
        
        function fLim=get_flim(layer)
            fmin=+inf;
            fmax=-Inf;
            
            for it=1:length(layer.Frequencies)
                fmin=nanmin(fmin,nanmin([layer.Transceivers(it).get_params_value('FrequencyStart',[]);layer.Transceivers(it).get_params_value('FrequencyEnd',[])]));
                fmax=nanmax(fmax,nanmax([layer.Transceivers(it).get_params_value('FrequencyStart',[]);layer.Transceivers(it).get_params_value('FrequencyEnd',[])]));
            end
            fLim=[fmin fmax];
        end
        
        function reg_uid=get_layer_reg_uid(layer)
            reg_uid={};
            for it=1:length(layer.Frequencies)
                reg_uid=union(reg_uid,layer.Transceivers(it).get_reg_Unique_IDs());
            end
        end
        
        function t_uid=get_layer_tracks_uid(layer)
            t_uid={};
            for it=1:length(layer.Frequencies)
                if ~isempty(layer.Transceivers(it).Tracks)
                    if ~isempty(layer.Transceivers(it).Tracks.target_id)
                        t_uid=union(t_uid,layer.Transceivers(it).Tracks.uid);
                    end
                end
            end
        end
        
        function add_trans(layer,trans_obj)
            cids=cell(1,numel(trans_obj));
            freq=nan(1,numel(trans_obj));
            
            for i=1:numel(cids)
                cids{i}=trans_obj(i).Config.ChannelID;
                freq(i)=trans_obj(i).Config.Frequency;
            end
            layer.remove_transceiver('Channels',cids);
            new_freq=[layer.Frequencies,freq];
            new_cid=[layer.ChannelID cids];
            layer.Transceivers=[layer.Transceivers trans_obj];
            
            [~,idx_order]=sort(new_freq);
            layer.Transceivers=layer.Transceivers(idx_order);
            layer.Frequencies=new_freq(idx_order);
            layer.ChannelID=new_cid(idx_order);
        end
        
        function rm_memaps(layer,idx_memaps)
            if isempty(layer)
                return
            end
            if isempty(idx_memaps)
                idx_memaps=1:length(layer.Transceivers);
            end
            
            for kk=idx_memaps
                layer.Transceivers(kk).Data.remove_sub_data();
            end
        end
        
        
        function line_obj=get_first_line(layer_obj)
            if ~isempty(layer_obj.Lines)
                line_obj=layer_obj.Lines(1);
            else
                line_obj=[];
            end
        end
        
        function [trans_obj,idx_cid]=get_trans(layer,curr_disp)
            trans_obj=[];
            idx_cid=[];
            if isempty(layer)
                return;
            end
            switch class(curr_disp)
                case {'struct' 'curr_state_disp_cl'}
                    if (isfield(curr_disp,'ChannelID')||isprop(curr_disp,'ChannelID'))&&~isempty(curr_disp.ChannelID)
                        [idx_cid,found]=layer.find_cid_idx(deblank(curr_disp.ChannelID));
                    else
                        found=0;
                    end
                    if found==1
                        trans_obj=layer.Transceivers(idx_cid);
                    else
                        [idx_cid,found]=layer.find_freq_idx(curr_disp.Freq);
                        
                        if found==1
                            trans_obj=layer.Transceivers(idx_cid);
                        else
                            trans_obj=[];
                            idx_cid=[];
                        end
                    end
                case 'char'
                    [idx_cid,found]=layer.find_cid_idx(deblank(curr_disp));
                    if found==1
                        trans_obj=layer.Transceivers(idx_cid);
                    else
                        trans_obj=[];
                        idx_cid=[];
                    end
                case {'double' 'single' 'int16' 'int8' 'uint16' 'uint8'}
                    [idx_cid,found]=layer.find_freq_idx(curr_disp);
                    if found==1
                        trans_obj=layer.Transceivers(idx_cid);
                    else
                        trans_obj=[];
                        idx_cid=[];
                    end
            end
        end
        
        
        function fold_lay=get_folder(layer)
            [folders,~,~]=cellfun(@fileparts,layer.Filename,'UniformOutput',0);
            
            fold_lay=unique(folders);
            
            if length(fold_lay)>1
                warning('Files from multiple folder in one layer...') ;
            end
            
        end
        
        function memap_files=list_memaps(layers)
            memap_files={};
            ifile=0;
            for ilay=1:length(layers)
                for itr=1:length(layers(ilay).Transceivers)
                    for i_sub_data=1:length(layers(ilay).Transceivers(itr).Data.SubData)
                        for imap=1:length(layers(ilay).Transceivers(itr).Data.SubData(i_sub_data).Memap)
                            ifile=ifile+1;
                            memap_files{ifile}=layers(ilay).Transceivers(itr).Data.SubData(i_sub_data).Memap{imap}.Filename;
                        end
                    end
                end
            end
        end
        
        
        function rm_region_across_id(layer,ID)
            for i=1:length(layer.Transceivers)
                layer.Transceivers(i).rm_region_id(ID);
            end
        end
        
        
        function list=list_lines(obj)
            if isempty(obj.Lines)
                list={};
            else
                list=cell(1,length(obj.Lines));
                for i=1:length(obj.Lines)
                    [~,name,ext]=fileparts(obj.Lines(i).File_origin{1});
                    list{i}=sprintf('%s %s',obj.Lines(i).Name,[name ext]);
                end
            end
        end
        
        function rm_line_id(obj,ID)
            idx=get_lines_per_ID(obj,ID);
            if ~isempty(idx)
                obj.Lines(idx)=[];
            end
        end
        
        function idx=get_lines_per_ID(obj,ID)
            if isempty(obj.Lines)
                idx=[];
            else
                idx=find(strcmp({obj.Lines(:).ID},ID));
            end
        end
        
        function idx=get_lines_per_Tag(obj,tag)
            if isempty(obj.Lines)
                idx=[];
            else
                idx=find(strcmpi({obj.Lines(:).Tag},tag));
            end
        end
        
        function add_lines(obj,lines)
            for i=1:length(lines)
                if ~isempty(lines(i).Range)
                    idx_id=obj.get_lines_per_ID(lines(i).ID);
                    if isempty(idx_id)
                        line=lines(i);
                    else
                        lines_temp=[lines(i) obj.Lines(idx_id)];
                        line=lines_temp.concatenate_lines('ID');
                        line.ID=lines(i).ID;
                    end
                    obj.rm_line_id(line.ID);
                    if isempty(line.Data)
                        line.Data=nan(size(line.Range));
                    end
                    if any(~isnan(line.Range))
                        obj.Lines=[obj.Lines line];
                    end
                end
            end
            idx_offsets=obj.get_lines_per_Tag('Offset');
            if ~isempty(idx_offsets)
                lines_off=concatenate_lines(obj.Lines(idx_offsets),'Tag');
                obj.Lines(idx_offsets)=[];
                obj.Lines=[obj.Lines lines_off];
            end
        end
        
        function add_curves(obj,curves)
            for i=1:length(curves)
                obj.rm_curves_per_ID_and_type(curves(i).Unique_ID,curves(i).Type);
                obj.Curves=[obj.Curves curves(i)];
            end
        end
        
        function tags=get_curves_tag(obj)
            tags=cell(1,length(obj.Curves));
            for i=1:length(obj.Curves)
                tags{i}=obj.Curves(i).Tag;
            end
            tags=unique(tags);
        end
        
        function curves_obj=get_curves_per_type(layer_obj,type)
            if isempty(layer_obj.Curves)
                curves_obj=[];
            else
                curves_obj=layer_obj.Curves(strcmp({layer_obj.Curves(:).Type},type));
            end
            if ~isempty(layer_obj.NotchFilter)              
                for uic=1:numel(curves_obj)
                    switch curves_obj(uic).Type
                        case {'ts_f' 'sv_f'}
                            idx_nan=false(size(curves_obj(uic).XData));
                            for ib=1:size(layer_obj.NotchFilter,1)
                                idx_nan=idx_nan|(curves_obj(uic).XData*1e3>=layer_obj.NotchFilter(ib,1)&curves_obj(uic).XData*1e3<=layer_obj.NotchFilter(ib,2));  
                            end
                            curves_obj(uic).YData(idx_nan)=nan;
                    end
                end
            end
        end
        
        function rm_curves_per_ID(obj,ID)
            if ~isempty(obj.Curves)
                idx=strcmp({obj.Curves(:).Unique_ID},ID);
                obj.Curves(idx)=[];
            end
        end
        
        function rm_curves_per_ID_and_type(obj,ID,type)
            if ~isempty(obj.Curves)
                idx=strcmp({obj.Curves(:).Unique_ID},ID)&strcmp({obj.Curves(:).Type},type);
                obj.Curves(idx)=[];
            end
        end
        
        function idx=get_curves_per_tag(obj,tag)
            if isempty(obj.Curves)
                idx=[];
            else
                idx=find(strcmp({obj.Curves(:).Tag},tag));
            end
        end
        
        function clear_curves(obj)
            obj.Curves=[];
        end
        
        function delete(obj)
            
            if ~isdeployed
                c = class(obj);
                disp(['ML object destructor called for class ',c])
            end
        end
    end
    
end