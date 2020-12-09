-- Run:
--     sqlite3 :memory: < main.sql
-- Runtime version:
--     sqlite3 --version
--     3.33.0 2020-08-14 13:23:32 fca8dc8b578f215a969cd899336378966156154710873e68b3d9ac5881b0alt1

create table data (
	value integer not null,
	i integer primary key autoincrement
);

.import input.txt data
.separator "\t"
.headers on

-- SQLite's auto increment IDs are 1-based :(

create view part_1
as
	select d.value as solution
	from data d
	where
		d.value not in (
			select a.value + b.value
			from data a, data b
			where
				a.i >= d.i - 25
				and
				a.i < d.i
				and
				b.i >= d.i - 25
				and
				b.i < d.i
				and
				a.i != b.i
		)
		and d.i > 25
	order by d.i asc
	limit 1;

select solution as part_1_solution from part_1;

create view possible_size
as
	select i from data;

create view possible_range
as
	select
		ps1.i as start,
		ps2.i as end
	from
		possible_size ps1,
		possible_size ps2
	where
		ps1.i < ps2.i;

create view part_2
as
	select
		min(d.value) as min_val,
		max(d.value) as max_val,
		min(d.value) + max(d.value) as solution
	from
		data d,
		possible_range r
	where
		r.start <= d.i and d.i <= r.end
		and
		(
			select sum(c.value)
			from data c
			where r.start <= c.i and c.i <= r.end
		) in part_1
	order by d.i;

select solution as part_2_solution from part_2;
