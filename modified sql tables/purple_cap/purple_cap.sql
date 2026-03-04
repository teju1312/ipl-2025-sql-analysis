-- 4.purple cap table
show create table purple_cap;

-- make primary key 
SELECT position, COUNT(*)
FROM purple_cap
GROUP BY position
HAVING COUNT(*) > 1;

alter table purple_cap
add constraint p_key
primary key(position);

select * from purple_cap;