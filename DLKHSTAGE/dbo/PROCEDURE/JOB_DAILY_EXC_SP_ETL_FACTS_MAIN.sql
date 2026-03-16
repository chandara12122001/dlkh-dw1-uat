-- =============================================
-- Author:		BUNCHHOEUN CHHIM
-- Create date: 28-APR-2017
-- Description:	In daily basis execution to 
--				report in DWH
-- =============================================
--					Revision History
-- =============================================
-- Revise Date: 23-May-17
-- Description: Add logic to check fcc date 
--				This is to ensure sp exec only one time 
--				and it according to FCC date

CREATE PROCEDURE [dbo].[JOB_DAILY_EXC_SP_ETL_FACTS_MAIN]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    
	DECLARE @pre_date date;
	DECLARE @curr_date date;
	DECLARE @con_var NVARCHAR(2);
	DECLARE @msg_out INT;
	--SELECT @pre_date = prev_working_day from openquery(BBCFCC, 'select * from fccbbcprd.sttm_dates where branch_code=''001''')
	SELECT @pre_date = MAX(BGK_DATE) from BBCDW..FACT_DAILY_GL_HISTORY
	SELECT @curr_date = exc_date from BBCSTAGE..msg_log order by exc_date asc;
	SELECT @pre_date = CONVERT(CHAR(10), @pre_date, 126)

	SET @con_var = 'DD'    

	BEGIN         
		INSERT INTO BBCSTAGE.dbo.MSG_LOG VALUES(@pre_date, 'Succeed', 'Shell script called store procedure successfully');
		BEGIN
			IF @pre_date = @curr_date
				INSERT INTO BBCSTAGE.dbo.MSG_LOG VALUES(@pre_date, 'Succeed', 'Duplicate shell script execution');				
			ELSE
				EXEC BBCSTAGE.dbo.SP_ETL_FACTS_MAIN @pre_date
		END
    END
END
