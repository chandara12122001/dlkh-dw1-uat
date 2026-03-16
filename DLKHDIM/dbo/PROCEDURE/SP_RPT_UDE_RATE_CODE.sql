-- =============================================
-- Author:		BUNCHHOEUN CHHIM
-- Create date: 19-FEB-18
-- Description:	UDE RATE CODE MAPPING
-- =============================================

--ALTER PROCEDURE [dbo].[SP_RPT_UDE_RATE_CODE]
CREATE PROCEDURE [dbo].[SP_RPT_UDE_RATE_CODE]
			@CUST_NO NCHAR(20), @CUST_ACC_NO NCHAR(30), @START_DT DATE, @END_DT DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
	declare @sql nchar(300);

	set @sql = 'select * from openquery([BBCFCC],''select a.BRANCH_CODE BRN, a.CUST_NO, a.CUST_AC_NO, a.AC_OPEN_DATE, a.AC_DESC, a.ACCOUNT_CLASS, c.DESCRIPTION, b.PROD, b.UDE_ID, b.UDE_EFF_DT, b.UDE_VALUE, b.RATE_CODE, d.CCY_CODE, d.RATE,
			d.RECORD_STAT, d.AUTH_STAT, d.BRANCH_CODE
		from FCCBBCPRD.STTM_CUST_ACCOUNT a, FCCBBCPRD.ICTM_ACC_UDEVALS b, FCCBBCPRD.STTM_ACCOUNT_CLASS c, FCCBBCPRD.ICTMS_RATES d
		where a.CUST_AC_NO = ' + 001000007100018 + '
			and b.RATE_CODE = d.RATE_CODE
			and a.cust_ac_no = b.acc (+)
			and a.ACCOUNT_CLASS = c.ACCOUNT_CLASS (+)
		order by a.CUST_NO, a.CUST_AC_NO'');';
	
	EXEC @sql

END
