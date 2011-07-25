begin transaction;

delete from geometry_columns where f_table_name='secondary_road';
drop index if exists idx_secondary_road;
drop table if exists secondary_road;

create table secondary_road as 
select id, tags->'name' as name, tags->'maxspeed' as maxspeed, tags->'layer' as layer, tags->'highway' as highway, linestring as geom from ways 
where tags->'highway'='secondary' 
or tags->'highway'='secondary_link' 
order by layer asc;

insert into geometry_columns 
(f_table_catalog, f_table_schema, f_table_name, f_geometry_column, coord_dimension, srid, "type") 
values 
(' ', 'public', 'secondary_road', 'geom', 2, 4326, 'LINESTRING');

update secondary_road set maxspeed='0' where maxspeed is null;
update secondary_road set layer='0' where layer is null;

create index idx_secondary_road on secondary_road using gist(geom);

commit;

vacuum full secondary_road;
