begin transaction;

delete from geometry_columns where f_table_name='landuse';
drop index if exists idx_landuse;
drop table if exists landuse;

create table landuse as 
select id, tags->'name' as name, tags->'landuse' as landuse
from relations 
where tags->'landuse'!='';

alter table landuse add column geom geometry;

update landuse as x set geom=(
  select st_buildarea(st_union(ring.linestring)) as geom from (
    select relation_id, w.linestring from (
      select m.relation_id, m.member_id as way_id from relation_members as m 
        inner join relations r on m.relation_id = r.id where m.member_type = 'W'
        and m.relation_id = x.id order by sequence_id
    ) as ringways inner join ways as w on ringways.way_id=w.id
  ) as ring group by relation_id
);

insert into landuse 
select id, tags->'name' as name, tags->'landuse' as landuse, st_buildarea(linestring) as geom
from ways as w 
where w.tags->'landuse'!=''
and st_numpoints(w.linestring)>3;

insert into geometry_columns 
(f_table_catalog, f_table_schema, f_table_name, f_geometry_column, coord_dimension, srid, "type") 
values 
(' ', 'public', 'landuse', 'geom', 2, 4326, 'POLYGON');

create index idx_landuse on landuse using gist(geom);

commit;

vacuum full landuse;
