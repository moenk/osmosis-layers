begin transaction;

delete from geometry_columns where f_table_name='burger';
drop index if exists idx_burger;
drop table if exists burger;

create table burger as 
select id, tags->'name' as name, tags->'amenity' as amenity, tags->'website' as website, tags->'phone' as phone,
geom as geom
from nodes 
where tags->'cuisine' like '%burger%';

insert into burger 
select id, tags->'name' as name, tags->'amenity' as amenity, tags->'website' as website, tags->'phone' as phone, 
st_centroid(linestring) as geom
from ways as w 
where w.tags->'cuisine' like '%burger%';

delete from burger where "name" like '%Donald%';
delete from burger where "name" like '%King%';
delete from burger where "name" like '%KFC%';

insert into geometry_columns
(f_table_catalog, f_table_schema, f_table_name, f_geometry_column, coord_dimension, srid, "type")
values
(' ', 'public', 'burger', 'geom', 2, 4326, 'POINT');

create index idx_burger on burger using gist(geom);

commit;

vacuum full burger;
