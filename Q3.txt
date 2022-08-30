with

/* get deal details of "closed won" deals */
	closed_deal as (
		select distinct *
		from deal
		where closed_won_date is not null
	),


/* get valid user_id - re-use code from Q1 */
	user_id_by_email as (
		select distinct user_id
		from email
		where hashed_email not like '%@blockrenovation.com'
		and user_id is not null
	),
	user_id_by_name as (
		select distinct user_id
		from contact
		where first_name not like '%test%'
		and last_name not like '%test%'
		and user_id is not null
	),

	valid_user_id as (
		select distinct user_id
		from block_user
		inner join user_id_by_email
			using (user_id)
		inner join user_id_by_name
			using (user_id)
		where user_id is not null
	),

/* extract details for "closed won" deals with valid user_id and populated property_city*/
valid_deals_with_duplicates as (
	select *
	from contact
	inner join deal_contact
		using (contact_id)
	inner join closed_deal
		using (deal_id)
	inner join valid_user_id
		using (user_id)
	where property_city is not null
),

/* drop duplicate rows where a single deal has multiple contacts */
valid_deals as (
	select distinct deal_id, upper(property_city) as deal_city, upper(property_state) as deal_state, deal_value_usd
	from valid_deals_with_duplicates
),

/* 77 distinct "cities" */
/* re-cast city into active markets/greater metropolitan area for simplicity/legibility */
/* exploratory analysis shows all cities either fall within NYC or LA */
/* below case-when is tailored to this dataset */
valid_deals_gma as (
	select *, (
		case when deal_state like 'N%' then 'New York City'
		when deal_state is null then 'New York City'
		else 'Los Angeles' end
		) as city
	from valid_deals
)

/* aggregate by city */
select city, avg(deal_value_usd) as avg_deal_value,
	sum(deal_value_usd) as gross_deal_value, sum(deal_value_usd)*100.0 / sum(sum(deal_value_usd)) over() as gross_deal_value_pct,
	count(deal_value_usd) as deal_count, count(deal_value_usd)*100.0 / sum(count(deal_value_usd)) over() as deal_count_pct
from valid_deals_gma
group by city
order by gross_deal_value desc;