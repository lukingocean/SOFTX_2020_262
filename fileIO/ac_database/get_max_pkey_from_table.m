function max_pkey=get_max_pkey_from_table(ac_db_filename,table_name,pkey_name)
max_pkey=0;
output_vals=[];

sql_query=sprintf('SELECT MAX(%s) FROM %s',pkey_name,table_name);
try
    if ischar(ac_db_filename)
        dbconn=connect_to_db(ac_db_filename);
    else
        dbconn=ac_db_filename;
    end
    output_vals=dbconn.fetch(sql_query);
    
    if ischar(ac_db_filename)        
        dbconn.close()
    end
    
catch err
    disp(err.message);
    warning('get_max_pkey_from_table:Error while executing sql query');
end

if ~isempty(output_vals)
    max_pkey=output_vals{1,1};   
end

if ~isempty(max_pkey)
    if iscell(max_pkey)
        max_pkey=max_pkey{1};
    end
else
    max_pkey=0;
end


if ischar(max_pkey)
    max_pkey=0;
end

if isnan(max_pkey)
    max_pkey=0;
end