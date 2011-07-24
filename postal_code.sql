begin transaction;

delete from geometry_columns where f_table_name='postal_code';
drop index if exists idx_postal_code;
drop table if exists postal_code;

create table postal_code as 
select id, tags->'postal_code' as postal_code, tags->'note' as note 
from relations where tags->'boundary'='postal_code' 
or (tags->'boundary'='administrative' and tags->'postal_code'!='') 
order by postal_code;

alter table postal_code add column geom geometry;

update postal_code as x set geom=(
  select st_buildarea(st_union(ring.linestring)) as geom from (
    select relation_id, w.linestring from (
      select m.relation_id, m.member_id as way_id from relation_members as m 
        inner join relations r on m.relation_id = r.id where m.member_type = 'W'
        and m.relation_id = x.id order by sequence_id
    ) as ringways inner join ways as w on ringways.way_id=w.id
  ) as ring group by relation_id
);

insert into geometry_columns 
(f_table_catalog, f_table_schema, f_table_name, f_geometry_column, coord_dimension, srid, "type") 
values 
(' ', 'public', 'postal_code', 'geom', 2, 4326, 'POLYGON');

create index idx_postal_code on postal_code using gist(geom);

commit;

vacuum full postal_code;
