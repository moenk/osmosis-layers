begin transaction;

delete from geometry_columns where f_table_name='primary_road';
drop index if exists idx_primary_road;
drop table if exists primary_road;

create table primary_road as 
select id, tags->'name' as name, tags->'maxspeed' as maxspeed, tags->'layer' as layer, tags->'highway' as highway, linestring as geom from ways 
where tags->'highway'='primary' 
or tags->'highway'='primary_link' 
order by layer asc;

insert into geometry_columns 
(f_table_catalog, f_table_schema, f_table_name, f_geometry_column, coord_dimension, srid, "type") 
values 
(' ', 'public', 'primary_road', 'geom', 2, 4326, 'LINESTRING');

update primary_road set maxspeed='0' where maxspeed is null;
update primary_road set layer='0' where layer is null;

create index idx_primary_road on primary_road using gist(geom);

commit;

vacuum full primary_road;
