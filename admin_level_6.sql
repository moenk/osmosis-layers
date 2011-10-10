begin transaction;

delete from geometry_columns where f_table_name='admin_level_6';
drop table if exists admin_level_6;
drop index if exists idx_admin_level_6;

create table admin_level_6 as 
select id, tags->'name' as name 
from relations as r 
where r.tags->'admin_level'='6';

alter table admin_level_6 add column geom geometry;

update admin_level_6 as x set geom=(
  select st_buildarea(st_union(ring.linestring)) as geom from (
    select relation_id, w.linestring from (
      select m.relation_id, m.member_id as way_id from relation_members as m 
        inner join relations r on m.relation_id = r.id where m.member_type = 'W'
        and m.relation_id = x.id order by sequence_id
    ) as ringways inner join ways as w on ringways.way_id=w.id
  ) as ring group by relation_id
);

alter table admin_level_6 add column area real;

update admin_level_6 set area=st_area(st_transform(geom,900913))/1000000 ;

insert into geometry_columns 
(f_table_catalog, f_table_schema, f_table_name, f_geometry_column, coord_dimension, srid, "type") 
values 
(' ', 'public', 'admin_level_6', 'geom', 2, 4326, 'POLYGON');

create index idx_admin_level_6 on admin_level_6 using gist(geom);

commit;

vacuum full admin_level_6;
