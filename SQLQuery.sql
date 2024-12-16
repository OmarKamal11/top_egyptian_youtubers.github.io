select NAME,total_subscribers,total_views,total_videos,average_views_per_video
from top_egypt_youtubers

--------------------------------------------------------------------------------

DELETE FROM top_egypt_youtubers
WHERE NAME IS NULL;

--------------------------------------------------------------------------------

ALTER TABLE top_egypt_youtubers
ALTER COLUMN NAME NVARCHAR(100) NOT NULL;


--------------------------------------------------------------------------------

select CHARINDEX('@',NAME) as position,NAME from top_egypt_youtubers

--------------------------------------------------------------------------------

CREATE VIEW view_egypt_youtubers as 
select SUBSTRING(NAME,1,CHARINDEX('@',NAME)-1) as channel_name,
	   total_subscribers,
	   total_videos,
	   total_views,
	   average_views_per_video
from top_egypt_youtubers

--------------------------------------------------------------------------------

select * from view_egypt_youtubers

--------------------------------------------------------------------------------

select *  from INFORMATION_SCHEMA.columns 
where TABLE_NAME = 'view_egypt_youtubers'


-------------------------------------------------------------------------------- Duplicate rows check

select channel_name,count(*) as duplicate_rows
from view_egypt_youtubers
group by channel_name
having count(*) > 1

---------------------------- Top 10 youtubers by subscribers -------------------

with top_subscribers as (
			 select *,
			        (ROW_NUMBER() OVER(ORDER BY total_subscribers desc)) as rn 
			 from view_egypt_youtubers)

select channel_name,total_subscribers
from top_subscribers
where rn<=10

---------------------------- Top 10 youtubers by views -------------------

with top_views as (
		   select *,
			  (ROW_NUMBER() OVER(ORDER BY total_views desc)) as rn 
		   from view_egypt_youtubers)

select channel_name,total_views
from top_views
where rn<=10

-------------------------------------- Important KPIs ------------------------------------

with channel_insights as (
			  select *,
				 ROUND((average_views_per_video/1000000),2) as average_views_per_video_M,
				 (CAST(ROUND((CAST(total_subscribers as decimal)/total_videos),2) as decimal(10,2))) as subscribers_to_video_ratio,
				 (CAST(ROUND((CAST(total_views as decimal)/total_subscribers),2) as decimal(10,2))) as views_per_subscriber_ratio
			   from view_egypt_youtubers)

select channel_name,average_views_per_video_M,subscribers_to_video_ratio,views_per_subscriber_ratio
from channel_insights



-------------------         YOUTUBE ANALYTICS        --------------------------------------
-------------------------------------------------------------------------------------------

DECLARE @conversion_rate FLOAT = 0.02;
DECLARE @product_cost MONEY = 200;
DECLARE @campaign_cost MONEY = 5000000;


WITH youtube_analytics_average_views AS (
	select *,
	      ROUND(average_views_per_video,-4) as average_views
    from view_egypt_youtubers),


product_sales AS (
	select *,
	      average_views * @conversion_rate as potential_product_sales_per_video
    from youtube_analytics_average_views),


revenue AS (
	select *,
		   potential_product_sales_per_video * @product_cost as potential_revenue_per_video_EGP
	from product_sales),


profit_margin AS (
	select *,
		   potential_revenue_per_video_EGP - @campaign_cost as net_profit
	from revenue)



select channel_name,average_views,
	   potential_product_sales_per_video,
	   potential_revenue_per_video_EGP,
	   net_profit
from profit_margin
order by total_subscribers desc
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY;
