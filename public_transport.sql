begin transaction;

delete from geometry_columns where f_table_name='public_transport';
drop index if exists idx_public_transport;
drop table if exists public_transport;

create table public_transport as 
select id, tags->'name' as name, tags->'highway' as transport, tags->'ref' as ref, tags->'operator' as operator, 
geom as geom
from nodes 
where tags->'highway'='bus_stop' or tags->'railway'='station' or tags->'railway'='tram_stop';

insert into  public_transport  
select id, tags->'name' as name, tags->'highway' as transport, tags->'ref' as ref, tags->'operator' as operator, 
st_centroid(linestring) as geom
from ways as w 
where w.tags->'highway'='bus_stop' or w.tags->'railway'='station' or w.tags->'railway'='tram_stop';

insert into geometry_columns
(f_table_catalog, f_table_schema, f_table_name, f_geometry_column, coord_dimension, srid, "type")
values
(' ', 'public', 'public_transport', 'geom', 2, 4326, 'POINT');

create index idx_public_transport on public_transport using gist(geom);

commit;

vacuum full public_transport;
