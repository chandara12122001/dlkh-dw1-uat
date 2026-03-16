-- =============================================
-- Author:		BUNCHHOEUN CHHIM
-- Create date: 11-JAN-18
-- Description:	DIM the table DIM_POS 
--				from SGTB_SWTMINAL
-- =============================================
CREATE PROCEDURE [dbo].[SP_ETL_DIM_POS]	@BRANCH_DATE DATE, @IS_RE_PROC BIT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @IS_RE_PROC = 1
	BEGIN
		DELETE FROM BBCDW..DIM_POS WHERE DATE_KEY = CONVERT(VARCHAR, @BRANCH_DATE, 112);
	END
	
	INSERT INTO BBCDW..DIM_POS
	SELECT CONVERT(VARCHAR,@BRANCH_DATE,112) DATE_KEY, term_id TERM_ID, merch_id MERCH_ID, org_brn BRANCH,
		account_no ACC_NO, term_addr POS_ADDR
	FROM SGTB_SWTMINAL
	WHERE record_stat = 'O'
		AND channel = 'POS';

END
