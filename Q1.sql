with 

/* select user_id with only non-Block email addresses */
user_id_by_email as (
	select distinct user_id
	from email
	where hashed_email not like '%@blockrenovation.com'
	and user_id is not null
),

/* select user_id where name does not include 'test' */
user_id_by_name as (
	select distinct user_id
	from contact
	where first_name not like '%test%'
	and last_name not like '%test%'
	and user_id is not null
)

/* take intersection of user_id with above two sets to get valid user_id - count by month */
select count(distinct user_id) as users_created, to_char(create_date, 'YYYY-MM') as create_month
from block_user
inner join user_id_by_email
	using (user_id)
inner join user_id_by_name
	using (user_id)
where user_id is not null
group by create_month
order by users_created desc
limit 1;