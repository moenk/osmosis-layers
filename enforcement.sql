begin transaction;

delete from geometry_columns where f_table_name='enforcement';
drop index if exists idx_enforcement;
drop table if exists enforcement;

-- erstmal die devices aus relationen in neue tabelle
create table enforcement as 
select n.id, d.enforcement, d.maxspeed, n.geom from (
  select r.id, m.member_id, r.tags->'enforcement' as enforcement, r.tags->'maxspeed' as maxspeed 
    from relations as r inner join relation_members as m on r.id=m.relation_id 
    where r.tags->'enforcement'!='' and m.member_role='device'
) as d inner join nodes as n on n.id=d.member_id;

-- die nodes hinterher
insert into enforcement 
select id, tags->'highway' as enforcement, tags->'maxspeed' as maxspeed, geom 
from nodes as n
where n.tags->'highway'='speed_camera';

-- und doppelte wieder raus
delete from enforcement 
where id in (
  select n.id from enforcement as lula 
  inner join enforcement as n on lula.id=n.id 
  and lula.enforcement='maxspeed' 
  and n.enforcement='speed_camera') 
and enforcement='speed_camera';

-- korrektur des alten tags speed_camera
update enforcement set enforcement='maxspeed' where enforcement='speed_camera';
update enforcement set maxspeed='0' where maxspeed is null;

-- geometrie anlegen
insert into geometry_columns 
(f_table_catalog, f_table_schema, f_table_name, f_geometry_column, coord_dimension, srid, "type") 
values 
(' ', 'public', 'enforcement', 'geom', 2, 4326, 'POINT');


create index idx_enforcement on enforcement using gist(geom);

commit;

vacuum full enforcement;
