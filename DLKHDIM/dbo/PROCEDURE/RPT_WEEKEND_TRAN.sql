CREATE proc [dbo].[RPT_WEEKEND_TRAN] @FROM_DATE DATE,@TO_DATE DATE
AS
BEGIN
declare @END DATE=@TO_DATE
IF OBJECT_ID('tempdb..#tmp1') IS NOT NULL
  DROP TABLE #tmp1
IF OBJECT_ID('tempdb..#tmp2') IS NOT NULL
  DROP TABLE #tmp2
IF OBJECT_ID('tempdb..#tmp3') IS NOT NULL
  DROP TABLE #tmp3
create table #tmp1 (month int,startdate date)
while YEAR(@FROM_DATE)<=YEAR(@END)
begin
	while @FROM_DATE<=@END
	begin
set @FROM_DATE =(select dateadd(d,-1,dateadd(mm,datediff(m,0,@FROM_DATE),1 )))
set @TO_DATE = (select dateadd(d,-1,dateadd(mm,datediff(m,0,@FROM_DATE)+1,0)))
IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
  DROP TABLE #tmp

select * into #tmp from BBCDW..DIM_HOLIDAY where BRANCH_CODE='001' and YEAR=(YEAR(@FROM_DATE)) and MONTH=DATEPART(m, @FROM_DATE)

declare @min_month int=1

while @min_month<=12
begin
declare @max int = (select LEN(holiday_list) from #tmp where branch_code='001' and month=@min_month)
declare @min int=1
while @min<=@max
begin
insert into #tmp1
select @min_month,(select 
case when SUBSTRING(holiday_list,@min,1)='W' then null else
CONVERT(date,cast(CONCAT(Year,RIGHT('00'+ cast(MONTH as varchar),2),right('00'+cast(@min as varchar),2)) as varchar),112) end from #tmp where MONTH=@min_month and branch_code='001')

set @min=@min+1
end
set @min_month=@min_month+1
end
SET @FROM_DATE=DATEADD(MONTH,1,@FROM_DATE)
	END
SET @FROM_DATE=DATEADD(YEAR,1,@FROM_DATE)
END

select TRN_REF_NO,left(cast(TXN_DT_TIME as time),2) Time,cast(TXN_DT_TIME as date) VALUE_DT,PRODUCT,PRODUCT_DESCRIPTION into #tmp2 from BBCSTAGE..SGTB_AC_ENTRIES where cast(TXN_DT_TIME as date) in (select  startdate from #tmp1) 
and PRODUCT in ('CHDP','CHWL','FXSW','FXPW','CQWL') and EVENT='INIT'

select *,case when Time>=7 and Time<10 then 'a8am to 10am'
when Time>=10 and Time<12 then 'b10am to 12am' 
when Time>=12 and Time<14 then 'c12pm to 2pm' 
when Time>=14 and Time<16 then 'd2pm to 4pm'
when Time>=16 and Time<18 then 'e4pm to 6pm'
when Time>=18 and Time<20 then 'f6pm to 8pm' end TimeType,case when DATENAME(DW,VALUE_DT) in ('Saturday','Sunday') then 'WK' else 'PH' end Type into #tmp3 from #tmp2
select COUNT(TRN_REF_NO) Transac,PRODUCT,PRODUCT_DESCRIPTION,TimeType,Type into #tmp4 From #tmp3
group by PRODUCT,TimeType,Type,PRODUCT_DESCRIPTION order by TimeType

select SUM(Transac) Transac,PRODUCT,PRODUCT_DESCRIPTION,TimeType,Type from #tmp4
group by PRODUCT,PRODUCT_DESCRIPTION,TimeType,Type

drop table #tmp4

END
