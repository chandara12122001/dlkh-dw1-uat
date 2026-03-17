
-- Centralized, static rules; inlined into the caller
CREATE   FUNCTION dbo.FN_GET_PREMIUM_TYPE_UAT
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
            WHEN @PLAN_ID IN ('CBS001', 'KBE003','BCLS01','BCLP01') AND @POL_BILL_TYP_CD = 'P' 
            THEN 'Single Premium'
            ELSE 'Regular Premium'
        END AS Premium_Type_Name
);