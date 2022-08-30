with

/* get details of closed deals, as these are the only ones that bring in deal value */
closed_deals as (
	select distinct deal_id, to_char(closed_won_date, 'YYYY-MM') as closed_month, deal_value_usd
	from deal
	where closed_won_date is not null
	and deal_value_usd is not null
)

/* sum deal value by month */
select closed_month, sum(deal_value_usd) as gross_deal_value
from closed_deals
group by closed_month
order by gross_deal_value desc
limit 1;