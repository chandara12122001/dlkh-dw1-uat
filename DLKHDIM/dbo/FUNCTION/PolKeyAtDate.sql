-- =============================================
-- Author:		HENG PHNATH
-- Create date: 14-FEB-2020
-- Description:	GET POL_KEY at date
-- =============================================
CREATE FUNCTION [dbo].[PolKeyAtDate]
(
	@POL_ID AS VARCHAR(9),
	@ValueDate AS DATE
)
RETURNS BIGINT
BEGIN
	RETURN (SELECT TOP 1 POL_KEY FROM DIM_POLICY WHERE POL_ID=@POL_ID AND DATEDIFF(DAY,START_DT,@ValueDate)>=0 ORDER BY START_DT DESC)
END
