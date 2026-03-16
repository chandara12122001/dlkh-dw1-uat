-- =============================================
-- Author:		HENG PHINATH
-- Create date: 14-FEB-2020
-- Description:	GET beneficiary KEY AT DATE
-- =============================================
CREATE FUNCTION [dbo].[BenKeyAtDate]
(
	@POL_ID AS VARCHAR(9),
	@BEN_SEQUENCE AS DECIMAL(3, 0),
	@ValueDate AS DATE
)
RETURNS BIGINT
AS
BEGIN
	RETURN (SELECT TOP 1 BENE_KEY 
			FROM DIM_BENE
			WHERE POL_ID=@POL_ID
			AND BNFY_SEQ_NUM=@BEN_SEQUENCE
			AND DATEDIFF(DAY,START_DT,@ValueDate)>=0
			ORDER BY START_DT DESC)

END
