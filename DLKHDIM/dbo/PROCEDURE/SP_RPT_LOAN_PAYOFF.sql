-- =============================================
-- Author:		BUNCHHOEUN CHHIM
-- Create date: 19-FEB-18
-- Description:	LOAN PAYOFF REPORT
--				QUERY BY DATE KEY 
-- =============================================
--				MODIFY HISTORY
-- =============================================
-- Modify By:	BUNCHHOEUN chhim
-- Modify Date:	22-Feb-18
-- Modify Des:	Add row number & cust no
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_LOAN_PAYOFF]
			@START_DT DATE, @END_DT DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT ROW_NUMBER() OVER (ORDER BY cust_no) ROW_NUM, a.*
	FROM BBCDW..FACT_LOAN_PAYOFF a
	WHERE DATE_KEY >= CONVERT(VARCHAR, @START_DT, 112)
		AND DATE_KEY <= CONVERT(VARCHAR, @END_DT, 112)
  
END
