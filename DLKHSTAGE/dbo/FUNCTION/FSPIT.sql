
Create FUNCTION [dbo].[FSPIT]
(
    @string VARCHAR(MAX),
    @delimiter CHAR(1)
)
RETURNS @output TABLE(num int,
    data VARCHAR(max)
)
BEGIN

	
    DECLARE @start INT, @end INT , @num INT = 0 
    SELECT @start = 1, @end = CHARINDEX(@delimiter, @string)

    WHILE @start < LEN(@string) + 1 BEGIN
        IF @end = 0 
            SET @end = LEN(@string) + 1
			SET @num=@num+1
        INSERT INTO @output  
        VALUES(@num,SUBSTRING(@string, @start, @end - @start))
        SET @start = @end + 1
        SET @end = CHARINDEX(@delimiter, @string, @start)
    END

    RETURN

END
