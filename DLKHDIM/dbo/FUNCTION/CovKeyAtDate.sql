-- =============================================
-- Author:		HENG PHINATH
-- Create date: 14-FEB-2020
-- Description:	GET COVERAGE KEY AT DATE
-- =============================================
CREATE FUNCTION CovKeyAtDate
(
	@POL_ID AS VARCHAR(9),
	@COV_NUM AS VARCHAR(2),
	@ValueDate AS DATE
)
RETURNS BIGINT
AS
BEGIN
	RETURN (SELECT TOP 1 COV_KEY 
			FROM DIM_COVERAGE
			WHERE POL_ID=@POL_ID
			AND CVG_NUM=@COV_NUM
			AND DATEDIFF(DAY,START_DT,@ValueDate)>=0
			ORDER BY START_DT DESC)

END
