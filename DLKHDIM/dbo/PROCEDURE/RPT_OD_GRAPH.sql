CREATE PROC [dbo].[RPT_OD_GRAPH] @FROM_DATE1 DATE,@TO_DATE1 DATE,@CUST_NO1 VARCHAR(400)  AS
BEGIN
declare @cust_no int=@CUST_NO1
declare @FROM_DATE date=@FROM_DATE1
declare @TO_DATE date=@TO_DATE1
declare @END DATE=@TO_DATE

IF OBJECT_ID('tempdb..#Overview') IS NOT NULL
  DROP TABLE #Overview
create table #Overview(Year int,num_month int,Month varchar(max),MIN_BALANCE money,MAX_BALANCE MONEY,Authorized_Overdraft money,VARI MONEY,RM_NAME VARCHAR(500),FULL_NAME VARCHAR(500))
while YEAR(@FROM_DATE)<=YEAR(@END)
begin
	while @FROM_DATE<=@END
	begin
set @FROM_DATE =(select dateadd(d,-1,dateadd(mm,datediff(m,0,@FROM_DATE),1 )))
set @TO_DATE = (select dateadd(d,-1,dateadd(mm,datediff(m,0,@FROM_DATE)+1,0)))
IF OBJECT_ID('tempdb..#AVG') IS NOT NULL
  DROP TABLE #AVG
IF OBJECT_ID('tempdb..#AVG1') IS NOT NULL
  DROP TABLE #AVG1
IF OBJECT_ID('tempdb..#AVG11') IS NOT NULL
  DROP TABLE #AVG11
IF OBJECT_ID('tempdb..#AVG2') IS NOT NULL
  DROP TABLE #AVG2
IF OBJECT_ID('tempdb..#CR') IS NOT NULL
  DROP TABLE #CR
IF OBJECT_ID('tempdb..#DR') IS NOT NULL
  DROP TABLE #DR
IF OBJECT_ID('tempdb..#C') IS NOT NULL
  DROP TABLE #C
IF OBJECT_ID('tempdb..#D') IS NOT NULL
  DROP TABLE #D
IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
  DROP TABLE #tmp
IF OBJECT_ID('tempdb..#tmp1') IS NOT NULL
  DROP TABLE #tmp1
create table #tmp1 (month int,startdate date)
select * into #tmp from BBCDW..DIM_HOLIDAY where BRANCH_CODE='001' and YEAR = (YEAR(@FROM_DATE)) and MONTH=DATEPART(m, @FROM_DATE)

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

delete from #tmp1 where startdate is null

SELECT RM.RM_NAME,FULL_NAME,MIN(BAL.LCY_CUR_BAL) MIN_BAL,MAX(BAL.LCY_CUR_BAL) MAX_BAL,MAX(BAL.LCY_CUR_BAL)-MIN(BAL.LCY_CUR_BAL) VARI,
max(fac.COLLATERAL_CONTRIBUTION) APPROVE_AMOUNT
 into #AVG FROM BBCDW..FACT_DAILY_AC_BAL BAL 
INNER JOIN BBCDW..DIM_CUSTOMER CUS ON BAL.CUSTOMER_KEY=CUS.CUSTOMER_KEY and DATE_KEY between CONVERT(VARCHAR,@FROM_DATE,112) and CONVERT(VARCHAR,@TO_DATE,112)
INNER JOIN BBCDW..FACT_CUST_ACCOUNT_LINKAGES LINK ON LINK.CUSTOMER_KEY=BAL.CUSTOMER_KEY AND  LINK.DATE_KEY between CONVERT(VARCHAR,@FROM_DATE,112) and CONVERT(VARCHAR,@TO_DATE,112)
INNER JOIN BBCDW..FACT_DAILY_FACILITY FAC ON CONCAT(FAC.LINE_CODE,FAC.LINE_SERIAL)=CONCAT(LINK.LINE_CODE,LINK.LINE_SERIAL) AND FAC.DATE_KEY between CONVERT(VARCHAR,@FROM_DATE,112) and CONVERT(VARCHAR,@TO_DATE,112)
LEFT JOIN BBCDW..DIM_RELATION_MANAGER RM ON RM.RM_ID=CUS.RM_ID AND RM.BRANCH_CODE=1
where CUSTOMER_NO=@cust_no GROUP BY RM.RM_NAME,FULL_NAME

insert into #Overview
SELECT YEAR(@FROM_DATE),DATEPART(m, @FROM_DATE),DATENAME(MONTH,@FROM_DATE),MIN_BAL,MAX_BAL,SUM(APPROVE_AMOUNT)*(-1),VARI,RM_NAME,FULL_NAME FROM #AVG
GROUP BY MIN_BAL,MAX_BAL,VARI,RM_NAME,FULL_NAME

SET @FROM_DATE=DATEADD(MONTH,1,@FROM_DATE)
	END
SET @FROM_DATE=DATEADD(YEAR,1,@FROM_DATE)
END

SELECT o.*,r.Order_Char FROM #Overview o inner join BBCDW..DIM_ORDER r on o.num_month=r.ID

end
