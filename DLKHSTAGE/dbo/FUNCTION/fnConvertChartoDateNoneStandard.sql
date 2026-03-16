

-- =============================================
-- Author:		KOURNGMENG.S
-- Create date: 2022-11-16
-- Description:	Data issue on policy paid to date
--				I found many data issue in production table TPOL invalid [paid to date, bill to date] to be converted date
-- =============================================
CREATE FUNCTION [dbo].[fnConvertChartoDateNoneStandard]
(
    -- Add the parameters for the function here
    @ValueDate VARCHAR(10)
)
RETURNS DATE
AS
BEGIN
    
    IF(@ValueDate='0000-00-00')
        --RETURN CONVERT(DATE,'1979-01-01')
		RETURN NULL
    DECLARE @MonthDay AS VARCHAR(5)
    DECLARE @Year AS VARCHAR(4)
    DECLARE @IsLeap AS BIT

 

    SET @MonthDay = RIGHT(@ValueDate,5)
    SET @Year = CONVERT(SMALLINT,LEFT(@ValueDate,4))
    IF (@Year%400=0) OR (@Year%4=0 AND @Year%100<>0)
        SET @IsLeap=1
    ELSE SET @IsLeap=0
    SET @MonthDay = CASE
				WHEN @MonthDay='02-29' AND @IsLeap<>1 THEN '02-28'
                WHEN @MonthDay='02-30' AND @IsLeap<>1 THEN '02-28'
				WHEN @MonthDay='02-30' AND @IsLeap=1 THEN '02-29'
				WHEN @MonthDay='02-31' AND @IsLeap<>1 THEN '02-28'
				WHEN @MonthDay='02-31' AND @IsLeap=1 THEN '02-29'
                WHEN @MonthDay='04-31' THEN '04-30'
                WHEN @MonthDay='06-31' THEN '06-30'
                WHEN @MonthDay='09-31' THEN '09-30'
                WHEN @MonthDay='11-31' THEN '11-30'
                ELSE RIGHT(@ValueDate,5)
            END
    RETURN  CONVERT(DATE,CONCAT(@YEAR,'-',@MonthDay))
END
