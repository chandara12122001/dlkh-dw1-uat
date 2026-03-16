-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
create FUNCTION [dbo].[FN_GET_NBC_CCY_NO] 
(
	@CCY_CODE AS VARCHAR(3),@LAST_2_CHAR AS VARCHAR(2)
)
RETURNS VARCHAR(2)
AS
BEGIN
	DECLARE @RESULT VARCHAR(2)='00'

	IF CAST(@LAST_2_CHAR AS SMALLINT)>=10 
		BEGIN
			
			SET @RESULT=(CASE WHEN @CCY_CODE='KHR' THEN LEFT(@LAST_2_CHAR,1)+'1' 
							  WHEN @CCY_CODE='USD' THEN LEFT(@LAST_2_CHAR,1)+'2'
							  WHEN @CCY_CODE='EUR' THEN LEFT(@LAST_2_CHAR,1)+'3'
							  WHEN @CCY_CODE='JPY' THEN LEFT(@LAST_2_CHAR,1)+'4'
							  WHEN @CCY_CODE='THB' THEN LEFT(@LAST_2_CHAR,1)+'5'
							  WHEN @CCY_CODE='HKD' THEN LEFT(@LAST_2_CHAR,1)+'6'
							  WHEN @CCY_CODE='MYR' THEN LEFT(@LAST_2_CHAR,1)+'7'
							  WHEN @CCY_CODE='SGD' THEN LEFT(@LAST_2_CHAR,1)+'8'
							  ELSE '9' END)
		 END;
	ELSE
		BEGIN
		
			SET @RESULT=(CASE WHEN @CCY_CODE='KHR' THEN '01' 
								  WHEN @CCY_CODE='USD' THEN '02'
								  WHEN @CCY_CODE='EUR' THEN '03'
								  WHEN @CCY_CODE='JPY' THEN '04'
								  WHEN @CCY_CODE='THB' THEN '05'
								  WHEN @CCY_CODE='HKD' THEN '06'
								  WHEN @CCY_CODE='MYR' THEN '07'
								  WHEN @CCY_CODE='SGD' THEN '08'
								  ELSE '09' END)
		 END;
	RETURN @RESULT;

END
