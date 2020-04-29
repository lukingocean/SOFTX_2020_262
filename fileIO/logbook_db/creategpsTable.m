function creategpsTable(dbconn)
gps_data_table=dbconn.fetch('select sql FROM sqlite_master WHERE type=''table'' AND name=''gps_data''');

if isempty(gps_data_table)
    creategpsTable_str = ['create table gps_data ' ...
        '(Filename VARCHAR DEFAULT NULL,'...
        'Lat VARCHAR DEFAULT NULL,'...
        'Long VARCHAR DEFAULT NULL,'...
        'Time VARCHAR DEFAULT NULL,'...
        'Depth VARCHAR DEFAULT NULL,'...
        'PRIMARY KEY (Filename) ON CONFLICT REPLACE,'...
        'FOREIGN KEY(Filename) REFERENCES logbook(Filename))'];
    dbconn.exec(creategpsTable_str);
else
    if ~contains(gps_data_table{1},'Depth')
        dbconn.exec(['ALTER TABLE gps_data '...
            'ADD Depth VARCHAR DEFAULT NULL']);
    end
end


