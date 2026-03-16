-- =============================================
-- Author:		BUNCHHOEUN CHHIM
-- Create date: 29-JAN-18
-- Description:	VISA OFF US CARD AUTH
--				TRANSACTION ON CADENCY
-- =============================================
--CREATE PROCEDURE [DBO].[SP_RPT_OFF_US_CARD]
CREATE PROCEDURE [dbo].[SP_RPT_OFF_US_CARD]
	@START_DATE DATE, @END_DATE DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT A.*, B.TERM_ADDR, (SELECT NORMAL_DATE FROM BBCCARD..CARD_MAPPING_DATE B WHERE A.LOCAL_DAY = B.LOCAL_DAY) TRN_DATE,
	CAST(STUFF(STUFF(STUFF(RIGHT('00000000' + CAST(A.LOCAL_TIME AS VARCHAR),8),3,0,':'),6,0,':'),9,0,'.') as TIME) TRN_TIME
	FROM BBCCARD..AUTH A
	INNER JOIN BBCDW..DIM_ATM_POS B
	ON A.CARD_TERM = B.TERM_ID
	WHERE A.LOCAL_DAY IN 
			(SELECT local_day 
			FROM BBCCARD..card_mapping_date 
			WHERE normal_date BETWEEN @START_DATE and @END_DATE);

END
