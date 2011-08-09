begin transaction;

delete from geometry_columns where f_table_name='amenity';
drop index if exists idx_amenity;
drop table if exists amenity;

create table amenity as 
select id, tags->'name' as name, tags->'amenity' as amenity, 
tags->'website' as website, tags->'phone' as phone, tags->'cuisine' as cuisine,
geom as geom
from nodes 
where tags->'amenity'!='';

insert into amenity 
select id, tags->'name' as name, tags->'amenity' as amenity, 
tags->'website' as website, tags->'phone' as phone, tags->'cuisine' as cuisine,
st_centroid(linestring) as geom
from ways as w 
where w.tags->'amenity'!='';

insert into geometry_columns 
(f_table_catalog, f_table_schema, f_table_name, f_geometry_column, coord_dimension, srid, "type") 
values 
(' ', 'public', 'amenity', 'geom', 2, 4326, 'POINT');

create index idx_amenity on amenity using gist(geom);

commit;

vacuum full amenity;
