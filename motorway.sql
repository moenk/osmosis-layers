begin transaction;

delete from geometry_columns where f_table_name='motorway';
drop index if exists idx_motorway;
drop table if exists motorway;

create table motorway as 
select id, tags->'ref' as name, tags->'maxspeed' as maxspeed, tags->'layer' as layer, tags->'highway' as highway, linestring as geom from ways 
where tags->'highway'='motorway' 
or tags->'highway'='motorway_link' 
order by layer asc;

insert into geometry_columns 
(f_table_catalog, f_table_schema, f_table_name, f_geometry_column, coord_dimension, srid, "type") 
values 
(' ', 'public', 'motorway', 'geom', 2, 4326, 'LINESTRING');

update motorway set maxspeed='0' where maxspeed is null;
update motorway set layer='0' where layer is null;

create index idx_motorway on motorway using gist(geom);

commit;

vacuum full motorway;
