-- =============================================
-- Author:		BUNCHHOEUN CHHIM
-- Create date: 16-Mar-18
-- Description:	ATM TRANSACTION RECONCILIATION
--				QUERY BY GL NUMBER
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_AMT_REC]
--ALTER PROCEDURE [dbo].[SP_ETL_FACT_CL_PAID_HIS]
	@AC_NO VARCHAR(10), @IS_RE_PRC BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--FIND LAST REPLENISH DATETIME & AMOUNT
	select * from b
END
