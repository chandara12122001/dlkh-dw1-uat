/***************************************************************************************************
	REPORT:.......... AXP_AA  (SALE DIST. DEPT.)
	PURPOSE:......... LISTING DETAIL OF AGENT WITH THEIE POLICY INFO

    Changelog
    ***********
	VERSION    DATE CHNG   UPD_BY     DESC
	VERS0.1		                      Initial Version
	VERS0.1	   28-05-2024  DOM        GET UNDISCOUNT PREMIUM AMOUNT AS MODAL PREM FOR EASYCARE
***************************************************************************************************/
CREATE PROC [dbo].[RPT_AXP_AA_UAT] @BRANCH_DATE DATE AS
    --DECLARE @BRANCH_DATE	DATE = '2024-10-29'
    DROP TABLE IF EXISTS #AGT DROP TABLE IF EXISTS #EDIT DROP TABLE IF EXISTS #FA DROP TABLE IF EXISTS #PST

SELECT *
INTO #AGT
FROM DLKHSTAGE..V_GET_AGENT_BASIC
SELECT
    ETBL_VALU_ID,
    ETBL_TYP_ID,
    ETBL_DESC_TXT = RTRIM(ETBL_DESC_TXT)
INTO #EDIT
FROM DLKHSTAGE..SGTB_EDITTABLE
WHERE CO_ID = 'CP'
  AND ETBL_LANG_CD = 'E'
  AND ETBL_TYP_ID IN ( 'AGTLE', 'DV-AGT-STAT-CD', 'CSRC', 'STB1' )

SELECT *
INTO #FA
FROM DLKHFACT..FACT_AGT_SUM FA
WHERE FA.CSC_CODE = 'BA'
  AND FA.DATE_KEY = CONVERT(VARCHAR, @BRANCH_DATE, 112)

SELECT
    PST.*
INTO #PST
FROM (SELECT *
      FROM (SELECT
                ROW_NUMBER() OVER (PARTITION BY POL.POL_ID ORDER BY POL_CHNG_PRCES_DT DESC) AS Rownum,
                POL_ID,
                POL_CHNG_PRCES_DT,
                USER_ID
            FROM DLKHSTAGE..SGTB_POLICY_STATUS POL) POL
      WHERE Rownum = 1) PST

SELECT
                       A.DATE_KEY
  ,                    A.POL_KEY
  ,                    A.CLIIND_KEY
  ,                    A.POL_ID
  , POL_APP_FORM_ID  = RTRIM(P.POL_APP_FORM_ID)
  ,                    A.CS_REV_DT
  , DM_AV_DESC_TXT   = UPPER(RTRIM(A.DM_AV_DESC_TXT))
  , ENTR_GIV_NM      = RTRIM(A.ENTR_GIV_NM)
  , ENTR_SUR_NM      = RTRIM(A.ENTR_SUR_NM)
  ,                    A.PLAN_ID
  , PLAN_NAME        = RTRIM(A.PLAN_NAME)
  ,                    A.POL_AGT_SHR_PCT
  ,                    A.POL_BILL_MODE_CD
  ,                    CASE
                           WHEN P.PLAN_ID = 'BES001' THEN PS.ETBL_DESC_TXT
                           WHEN P.PLAN_ID IN ('CBS001') THEN 'Single Premium'
                           WHEN CVG.PLAN_ID = 'BSS001' THEN CASE
                                                                WHEN CVG.CVG_MAT_XPRY_DUR != CVG.PREM_PMT_DUR
                                                                    THEN 'Limited Premium'
                                                                ELSE 'Regular Premium' END
                           ELSE 'Regular Premium' END                                                PRE_MODE
  ,                    A.POL_CSTAT_CD
  ,                    A.POL_ISS_DT
  ,                    A.POL_PREM_PAY_DUR
  ,                    A.CVG_ME_FCT
  ,                    A.CVG_MPREM_AMT
  ,                    A.CVG_SUM_INS_AMT
  , AFYP             = CASE
                           WHEN A.PLAN_ID = 'BES001' THEN CVG.CVG_UNDSCNT_PREM * (CASE
                                                                                      WHEN CAST(A.POL_BILL_MODE_CD AS INT) > 0
                                                                                          THEN 12 / CAST(A.POL_BILL_MODE_CD AS INT)
                                                                                      ELSE 1 END)
                           ELSE A.AFYP END
    --,A.AFYP
  , WFYP             = DLKHSTAGE.dbo.FN_GET_WFYP(A.POL_ID, A.POL_PREM_PAY_DUR, CASE
                                                                                   WHEN A.PLAN_ID = 'BES001'
                                                                                       THEN CVG.CVG_UNDSCNT_PREM
                                                                                   ELSE A.CVG_MPREM_AMT END)
    --,WFYP = DLKHSTAGE.dbo.FN_GET_WFYP (A.POL_ID, A.POL_PREM_PAY_DUR, A.CVG_MPREM_AMT)
  ,                    CASE WHEN A.PLAN_ID = 'BES001' THEN CVG.CVG_UNDSCNT_PREM ELSE A.PRE_AFTER END PRE_AFTER
  ,                    A.PRE_BEFORE
  ,                    A.PRO_LOAD_DT
  , CSC_NAME         = RTRIM(A.CSC_NAME)
  ,                    A.AGENT_CODE
  ,                    A.AGENT_KEY
  , ABM_ID           = AGT.ManagerId
  , ABM_NAME         = RTRIM(AGT.ManagerName)
  , LEADER_ID        = AGT.LeaderId
  , LNAME            = AGT.LeaderName
  , AGT_NAME         = AGT.Name
  ,                    AGT.Status
  , AGT_STAT_DESC    = AGT.Status
  , AGT_TITL_DESC    = AGT.TitleRole
  ,                    AGT.EffectiveDate
  ,                    CASE WHEN AGT.DistributionChannelCode = 'BA' THEN ORG.ORG_CODE ELSE NULL END  BANK_BRANCH_CODE
  ,                    CASE WHEN AGT.DistributionChannelCode = 'BA' THEN ORG.NAME ELSE NULL END      BANK_BRANCH_NAME
  , ORGANIZATION     = CASE WHEN AGT.DistributionChannelCode = 'BA' THEN PN.NAME ELSE AGT.Branch END
  , BANK_AREA        = RTRIM(PN.NAME)
  ,                    POLW.POL_SOLD_BR_ID
  , POL_SOLD_BR_NAME = RTRIM(SLDBR.ETBL_DESC_TXT)
  ,                    P.CUST_SRC_CD
  , CUST_SRC_DESC    = CSRC.ETBL_DESC_TXT
  ,                    FA.NTU          AS                                                            NTU_DATE
  ,                    PC.POL_UW_RMRKS AS                                                            "REMARK"
  ,                    PST.USER_ID
  ,                    CVG.INTRO_ID
  , COMMISSION_SLIT  = CASE WHEN RTRIM(CVG.INTRO_ID) != '' THEN 50 ELSE A.POL_AGT_SHR_PCT END
FROM DLKHFACT..FACT_AXP_AA A
         LEFT JOIN #FA FA ON FA.POL_ID = A.POL_ID AND FA.AGENT_KEY = A.AGENT_KEY
         LEFT JOIN DLKHSTAGE..SGTB_POLICY P ON A.POL_ID = P.POL_ID
         LEFT JOIN DLKHSTAGE..SGTB_POLICY_CLIENT PC ON PC.POL_ID = FA.POL_ID AND PC.POL_CLI_REL_TYP_CD = 'O'
         LEFT JOIN DLKHSTAGE..SGTM_COVERAGE CVG ON CVG.POL_ID = A.POL_ID AND CVG.CVG_NUM = '01'
         LEFT JOIN DLKHSTAGE..SGTB_POLICY_WRITING POLW ON A.POL_ID = POLW.POL_ID
         LEFT JOIN DLKHSTAGE..SGTM_AGENT_DETAIL AGT ON AGT.AgentId = A.AGENT_CODE
         LEFT JOIN DLKHSTAGE..DMS_ORGANIZATION ORG ON ORG.SALE_SUPPORT LIKE CONCAT('%', A.AGENT_CODE, '%')
         LEFT JOIN DLKHSTAGE..DMS_PARTNER PN ON PN.CODE = ORG.PARTNER_CODE AND HIERARCHICAL_MODEL = 3
         LEFT JOIN #EDIT CSRC ON P.CUST_SRC_CD = CSRC.ETBL_VALU_ID AND CSRC.ETBL_TYP_ID = 'CSRC'
         LEFT JOIN #EDIT PS ON PS.ETBL_VALU_ID = CVG.CVG_STBL_1_CD AND PS.ETBL_TYP_ID = 'STB1'
         LEFT JOIN DLKHSTAGE..SGTM_PARA SLDBR
                   ON POLW.POL_SOLD_BR_ID = SLDBR.ETBL_VALU_ID AND SLDBR.ETBL_LANG_CD = 'E' AND
                      SLDBR.ETBL_TYP_ID = 'SOLDBR'
         LEFT JOIN #PST PST ON PST.POL_ID = A.POL_ID
WHERE A.DATE_KEY = CONVERT(VARCHAR, @BRANCH_DATE, 112)
