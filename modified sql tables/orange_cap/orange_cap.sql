-- 3. orange cap table
show create table orange_cap;

-- make primary key 
SELECT position, COUNT(*)
FROM orange_cap
GROUP BY position
HAVING COUNT(*) > 1;

alter table orange_cap
add constraint p_key
primary key(position);

select * from orange_cap;