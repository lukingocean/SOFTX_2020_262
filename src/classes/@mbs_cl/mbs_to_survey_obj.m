function survey_in_obj=mbs_to_survey_obj(mbs_obj,varargin)

p = inputParser;

addRequired(p,'mbs_obj',@(x) isa(x,'mbs_cl'));
addParameter(p,'type','raw');
parse(p,mbs_obj,varargin{:});

survey_in_obj=survey_input_cl();


header_fields=fieldnames(mbs_obj.Header);
opt_fields=fieldnames(survey_in_obj.Options);
inf_fields=fieldnames(survey_in_obj.Infos);

for ifh=1:length(header_fields)
    idx_opt=find(strcmpi(opt_fields,header_fields{ifh}));
    idx_info=find(strcmpi(inf_fields,header_fields{ifh}));
    
    if ~isempty(idx_opt)
        survey_in_obj.Options.(opt_fields{idx_opt})=mbs_obj.Header.(header_fields{ifh});
    end
    if ~isempty(idx_info)
        survey_in_obj.Infos.(inf_fields{idx_info})=mbs_obj.Header.(header_fields{ifh});
    end
    
end

for ifo=1:length(opt_fields)
    if ischar(survey_in_obj.Options.(opt_fields{ifo}))
        if strcmpi(strtrim(survey_in_obj.Options.(opt_fields{ifo})),'yes')
            survey_in_obj.Options.(opt_fields{ifo})=1;
        elseif strcmpi(strtrim(survey_in_obj.Options.(opt_fields{ifo})),'no')
            survey_in_obj.Options.(opt_fields{ifo})=0;
        end
    end
end

for ifi=1:length(inf_fields)
    if ischar(survey_in_obj.Infos.(inf_fields{ifi}))
        if strcmpi(strtrim(survey_in_obj.Infos.(inf_fields{ifi})),'yes')
            survey_in_obj.Infos.(inf_fields{ifi})=1;
        elseif strcmpi(strtrim(survey_in_obj.Infos.(inf_fields{ifi})),'no')
            survey_in_obj.Infos.(inf_fields{ifi})=0;
        end
    end
end

survey_in_obj.Options.Absorption=mbs_obj.Header.default_absorption;

survey_in_obj.Options.FrequenciesToLoad=survey_in_obj.Options.Frequency;


switch p.Results.type
    case 'raw'
        folders=mbs_obj.Input.rawDir;
    case 'crest'
        folders=mbs_obj.Input.crestDir;
end

[folders_unique,~,folder_vec_num]=unique(folders);

mat_snap_data=[mbs_obj.Input.snapshot;folder_vec_num']';

[snap_numbers,unique_snap,snap_ids]=unique(mat_snap_data,'rows');

snapshots=cell(1,length(unique_snap));

for isnap=1:size(snap_numbers,1)
    snap_num=snap_numbers(isnap,1);
    snap_curr.Folder=folders_unique{snap_numbers(isnap,2)};
    snap_curr.Number=snap_num;
    
    idx_snap=find(snap_ids==isnap);
    
    switch p.Results.type
        case 'raw'
            snap_curr.Folder=mbs_obj.Input.rawDir{idx_snap(1)};
        case 'crest'
            snap_curr.Folder=mbs_obj.Input.crestDir{idx_snap(1)};
    end
    snap_curr.Type={''};
    snap_curr.Cal=mbs_obj.Input.calRaw{idx_snap(1)};
    snap_curr.Cal_rev=mbs_obj.Input.calRev{idx_snap(1)};
    snap_curr.Cal.FREQ=38000;
    stratum_names=unique(mbs_obj.Input.stratum(idx_snap));
    stratum=cell(1,length(stratum_names));
    for istrat=1:length(stratum_names)
        strat_curr.Design='';
        strat_curr.Radius=0;
        strat_name=stratum_names{istrat};
        strat_curr.Name=strat_name;
        strat_curr.Cal=[];
        idx_strat=intersect(idx_snap,find(strcmp(strat_name,mbs_obj.Input.stratum)));
        trans_numbers=unique(mbs_obj.Input.transect(idx_strat));
        transects=cell(1,length(trans_numbers));
        for itrans=1:length(trans_numbers)
            trans_num=trans_numbers(itrans);
            trans_curr.number=trans_num;
            
            idx_trans=intersect(idx_strat,find(mbs_obj.Input.transect==trans_num));
            idx_trans=idx_trans(:)';
            bot_curr.ver=1;
            trans_curr.Bottom=bot_curr;
            trans_curr.files={};
            trans_curr.OriginCrest={};
            trans_curr.Es60_correction=[];
            trans_curr.Cal={};
            trans_curr.Cells={};
            regions_curr.ver=1;
            regions_curr.IDs='';
            switch p.Results.type
                case 'raw'
                    trans_curr.files=mbs_obj.Input.rawFileName(idx_trans);
                    trans_curr.Es60_correction=mbs_obj.Input.EsError(idx_trans);
                    trans_curr.Cal=mbs_obj.Input.calRaw(idx_trans);
                   
                    i_ori=0;
                    for sub_i_trans=idx_trans
                        i_ori=i_ori+1;
                        trans_curr.Cal{i_ori}.FREQ=38000;
                        trans_curr.OriginCrest{i_ori}=fullfile(mbs_obj.Input.crestDir{sub_i_trans},sprintf('d%07d', mbs_obj.Input.dfileNum(sub_i_trans)));
                    end
                case 'crest'
                    i_ori=0;
                    for sub_i_trans=idx_trans
                        i_ori=i_ori+1;
                        trans_curr.Cal=cell(1,length(idx_trans));
                        trans_curr.Es60_correction=nan(1,length(idx_trans));
                        trans_curr.files{i_ori}=sprintf('d%07d', mbs_obj.Input.dfileNum(sub_i_trans));
                        trans_curr.OriginCrest{i_ori}=fullfile(mbs_obj.Input.crestDir{sub_i_trans},sprintf('d%07d', mbs_obj.Input.dfileNum(sub_i_trans)));
                    end
            end
            
            reg_str='';
            id_vec=[];
            i_ori=0;
            for sub_i_trans=idx_trans
                i_ori=i_ori+1;
                
                for i_reg=1:length(mbs_obj.Input.reg{sub_i_trans})
                    if ~isempty(mbs_obj.Input.reg{sub_i_trans}(i_reg))
                        reg_curr=mbs_obj.Input.reg{sub_i_trans}(i_reg);
                        if nansum(reg_curr.id==id_vec)==0
                            id_vec=[id_vec reg_curr.id];
                            new_str=sprintf('%.0f(%s)',reg_curr.id,reg_curr.spec);
                            reg_str=[reg_str ';' new_str];
                        end
                    end
                end
            end
            
            if length(reg_str)>1
                reg_str(1)=[];
            end
            
            regions_curr.IDs=strtrim(reg_str);
            if ~isempty(reg_str)
                trans_curr.Regions={regions_curr};
            else
                trans_curr.Regions={};
            end
            transects{itrans}=trans_curr;
        end
        strat_curr.Transects=transects;
        stratum{istrat}=strat_curr;
    end
    snap_curr.Stratum=stratum;
    snapshots{isnap}=snap_curr;
end

survey_in_obj.Snapshots=snapshots;


end