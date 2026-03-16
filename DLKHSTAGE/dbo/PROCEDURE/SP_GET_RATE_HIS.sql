-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
create proc [dbo].[SP_GET_RATE_HIS] @BRANCH_DATE AS DATE,@DB_NAME VARCHAR(15),@SERVER_NAME VARCHAR(15),@CCY VARCHAR(10),@RATE varchar(100) OUTPUT
AS
BEGIN
DECLARE @SQL NVARCHAR(MAX)='(@DB_NAME,''SELECT MID_RATE FROM @SERVER_NAME.cytb_rates_history WHERE RATE_DATE=''''@BRANCH_DATE'''' AND RATE_TYPE=''''NBC'''' AND CCY2=''''@CCY'''' AND BRANCH_CODE=''''001'''''')'
SET @SQL=REPLACE(@SQL,'@BRANCH_DATE',@BRANCH_DATE)
SET @SQL=REPLACE(@SQL,'@CCY',@CCY)
SET @SQL=REPLACE(@SQL,'@SERVER_NAME',@SERVER_NAME)
SET @SQL=REPLACE(@SQL,'@DB_NAME',@DB_NAME)
SET @SQL = CONCAT('SELECT * FROM OPENQUERY',@SQL)
CREATE TABLE #TMP(TEST varchar(100))
INSERT INTO #TMP
EXEC sp_executesql @SQL	

SELECT @RATE=TEST FROM #TMP
DROP TABLE #TMP
END
