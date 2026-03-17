
-- Centralized, static rules; inlined into the caller
CREATE   FUNCTION dbo.FN_GET_AFYP_MULTIPLIER
(
    @PLAN_ID         VARCHAR(20),
    @POL_BILL_TYP_CD VARCHAR(10)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        CASE
            WHEN @PLAN_ID IN ('CBS001', 'KBE003','BCLS01','BCLP01') AND @POL_BILL_TYP_CD = 'P' THEN 0.10
        ELSE 1
    END AS multiplier
);
