-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_NBC_SHORT_COA]
	@DATE AS date,@RATE money
AS
BEGIN

	SET NOCOUNT ON;
declare @para int =cast(CONVERT(VARCHAR,@DATE,112) as int)
	IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
  DROP TABLE #tmp
	IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
  DROP TABLE #tmp
	select * into #tmp from FN_GET_NBC_COA_BAL(@para) WHERE LEAF='Y'

	update #tmp set nbc_code=LEFT(nbc_code,3)+'1'  where nbc_code='3865'
	update #tmp set CURRENCY=CONCAT('1',RIGHT(CURRENCY,1)) where NBC_CODE='3196'
	update #tmp set currency=LEFT(currency,1)+'9' where CONCAT(NBC_CODE,CURRENCY) not in (SELECT CONCAT(NBC_CODE,CURRENCY) FROM #tmp A inner JOIN DIM_NBC_COA AC ON CONCAT(AC.L1,AC.L2,AC.L3,AC.L4)=CONCAT(NBC_CODE,CURRENCY) WHERE LEAF='Y')
	

	
	select CONCAT(NBC_CODE,CURRENCY) AC_NO,AC.AC_DESC,SUM(A.LCY_BAL) USD_BAL,ROUND(SUM(A.LCY_BAL*@RATE),2) KHR_BAL,@RATE EX_RATE 
	from #tmp A inner JOIN DIM_NBC_COA AC ON CONCAT(AC.L1,AC.L2,AC.L3,AC.L4)=CONCAT(NBC_CODE,CURRENCY)
	GROUP BY AC.AC_DESC,NBC_CODE,CURRENCY having SUM(A.LCY_BAL)<>0
	ORDER BY 1

END
