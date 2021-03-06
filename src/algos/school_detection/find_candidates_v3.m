

function candidates=find_candidates_v3(Mask,range_d,dist_pings,l_min_can,h_min_can,min_nb_sples,output,load_bar_comp)


[nb_row,~]=size(Mask);

CC = bwconncomp(Mask==1);
% [boundaries,~,~,A] = bwboundaries(Mask);
% % enclosing_boundary  = find(A(m,:));
% % enclosed_boundaries = find(A(:,m));

num_can=CC.NumObjects;
candidates_idx=CC.PixelIdxList;

switch output
    case 'mat'
        candidates=zeros(size(Mask));
    case 'cell'
        candidates=cell(1,num_can);
end

if ~isempty(load_bar_comp)
    load_bar_comp.progress_bar.setText('Finding Candidates');
    set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',num_can, 'Value',0);
end
region_number=1;

for ic=1:num_can
    
    if ~isempty(load_bar_comp)
        set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',num_can, 'Value',ic);
    end
    
    curr_candidate=candidates_idx{ic};
    if length(curr_candidate)>min_nb_sples
        row_idx=rem(curr_candidate,nb_row);
        row_idx(row_idx==0)=nb_row;
        col_idx=ceil(curr_candidate/nb_row);
        
        if range(dist_pings(col_idx))>=l_min_can...
                &&range(range_d(row_idx))>=h_min_can
            
            switch output
                case 'mat'
                    candidates(curr_candidate)=region_number;
                    region_number=region_number+1;
                case 'cell'
                    candidates{ic}=curr_candidate;
            end
            
        end
        
         
    end
    if ~isempty(load_bar_comp)
        set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',num_can, 'Value',ic);
    end
end

switch output
    case 'cell'
        candidates(cellfun(@isempty,candidates))=[];
end

end