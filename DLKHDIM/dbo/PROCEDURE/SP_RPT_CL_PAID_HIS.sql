-- =============================================
-- Author:		BUNCHHOEUN CHHIM
-- Create date: 19-FEB-18
-- Description:	LOAN PAYMENT HISTORY
--				QUERY BY DATE KEY 
-- =============================================

CREATE PROCEDURE [dbo].[SP_RPT_CL_PAID_HIS]
			@LOAN_AC_NO VARCHAR(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT B.FULL_NAME, C.BRANCH_CODE, A.*
	FROM BBCDW..FACT_CL_PAID_HIS A
		INNER JOIN BBCDW..DIM_CUSTOMER B ON A.CUST_KEY = B.CUSTOMER_KEY
		INNER JOIN BBCDW..DIM_BBC_BRANCH C ON A.BRN_KEY = C.BRANCH_KEY
	WHERE A.LOAN_NUM = @LOAN_AC_NO 
  
END
