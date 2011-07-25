begin transaction;

delete from geometry_columns where f_table_name='building';
drop index if exists idx_building;
drop table if exists building;

create table building as 
select id, tags->'addr:housenumber' as housenumber, st_buildarea(linestring) as geom
from ways as w 
where w.tags->'building'!='' 
and st_numpoints(w.linestring)>3;

insert into geometry_columns 
(f_table_catalog, f_table_schema, f_table_name, f_geometry_column, coord_dimension, srid, "type") 
values 
(' ', 'public', 'building', 'geom', 2, 4326, 'POLYGON');

create index idx_building on building using gist(geom);

commit;

vacuum full building;
