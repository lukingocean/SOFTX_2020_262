function correctTriangleWave(trans_obj,varargin)

p = inputParser;

addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl'));
addParameter(p,'EsOffset',[]);
addParameter(p,'block_len',get_block_len(5,'gpu'),@(x) x>0);
addParameter(p,'load_bar_comp',[]);

parse(p,trans_obj,varargin{:});

range=trans_obj.get_transceiver_range();
pings=trans_obj.get_transceiver_pings();

nb_samples=numel(range);
nb_pings=numel(pings);

bsize=ceil(p.Results.block_len/nb_samples);

if nb_pings>=ceil(2721/2)
    bsize=nanmax(bsize,ceil(2721/2));
else
    bsize=nanmax(bsize,nb_pings);
end
mean_err=p.Results.EsOffset;
u=0;
% initialize progress bar
if ~isempty(p.Results.load_bar_comp)
    p.Results.load_bar_comp.progress_bar.setText('Correcting Triangle wave error');
    set(p.Results.load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',ceil(nb_pings/bsize), 'Value',0);
end

while u<ceil(nb_pings/bsize)
    
    idx_pings=(u*bsize+1):nanmin(((u+1)*bsize),nb_pings);
    
    u=u+1;
    
    idx_pings_next=(u*bsize+1):nanmin(((u+1)*bsize),nb_pings);
    if ~isempty(idx_pings_next)
        if idx_pings_next(end)==nb_pings
            idx_pings=union(idx_pings,idx_pings_next);
            u=u+1;
        end
    end
    power=get_subdatamat(trans_obj.Data,1:nb_samples,idx_pings,'field','power');
    
    [power_corr_db,mean_err]=correctES60(10*log10(power),mean_err,u-1);
    if mean_err~=0
        trans_obj.Data.replace_sub_data_v2('power',10.^(power_corr_db/10),[],idx_pings);
    end
    trans_obj.Config.EsOffset=mean_err;
    if ~isempty(p.Results.load_bar_comp)
    
    set(p.Results.load_bar_comp.progress_bar,'Value',u);
    end
end
if ~isempty(p.Results.load_bar_comp)
    p.Results.load_bar_comp.progress_bar.setText('');
end


end