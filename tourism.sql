begin transaction;

delete from geometry_columns where f_table_name='tourism';
drop index if exists idx_tourism;
drop table if exists tourism;

create table tourism as 
select id, tags->'name' as name, tags->'tourism' as tourism, 
tags->'website' as website, tags->'phone' as phone,
geom as geom
from nodes 
where tags->'tourism'!='';

insert into tourism 
select id, tags->'name' as name, tags->'tourism' as tourism, 
tags->'website' as website, tags->'phone' as phone,
st_centroid(linestring) as geom
from ways as w 
where w.tags->'tourism'!='';

insert into geometry_columns 
(f_table_catalog, f_table_schema, f_table_name, f_geometry_column, coord_dimension, srid, "type") 
values 
(' ', 'public', 'tourism', 'geom', 2, 4326, 'POINT');

create index idx_tourism on tourism using gist(geom);

commit;

vacuum full tourism;
