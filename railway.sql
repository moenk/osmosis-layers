begin transaction;

delete from geometry_columns where f_table_name='railway';
drop index if exists idx_railway;
drop table if exists railway;

create table railway as 
select id, tags->'name' as name, tags->'layer' as layer, tags->'railway' as railway, linestring as geom from ways 
where tags->'railway'!=''
order by layer asc;

insert into geometry_columns 
(f_table_catalog, f_table_schema, f_table_name, f_geometry_column, coord_dimension, srid, "type") 
values 
(' ', 'public', 'railway', 'geom', 2, 4326, 'LINESTRING');

update railway set layer='0' where layer is null;

create index idx_railway on railway using gist(geom);

commit;

vacuum full railway;
