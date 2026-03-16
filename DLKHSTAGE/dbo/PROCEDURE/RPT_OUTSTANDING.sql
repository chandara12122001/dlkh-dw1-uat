CREATE proc [dbo].[RPT_OUTSTANDING]
as
   IF OBJECT_ID('tempdb..#TDMAV') IS NOT NULL
  DROP TABLE #TDMAV
     IF OBJECT_ID('tempdb..#TPHST') IS NOT NULL
  DROP TABLE #TPHST
       IF OBJECT_ID('tempdb..#TAGRP') IS NOT NULL
  DROP TABLE #TAGRP
         IF OBJECT_ID('tempdb..#TEDIT') IS NOT NULL
  DROP TABLE #TEDIT
           IF OBJECT_ID('tempdb..#TPOLC') IS NOT NULL
  DROP TABLE #TPOLC
             IF OBJECT_ID('tempdb..#TCLNM') IS NOT NULL
  DROP TABLE #TCLNM
               IF OBJECT_ID('tempdb..#TCLNC') IS NOT NULL
  DROP TABLE #TCLNC
                 IF OBJECT_ID('tempdb..#TCLIC') IS NOT NULL
  DROP TABLE #TCLIC
                   IF OBJECT_ID('tempdb..#TCLIA') IS NOT NULL
  DROP TABLE #TCLIA
                     IF OBJECT_ID('tempdb..#TCVGC') IS NOT NULL
  DROP TABLE #TCVGC
                       IF OBJECT_ID('tempdb..#TCVG') IS NOT NULL
  DROP TABLE #TCVG
                       IF OBJECT_ID('tempdb..#TPOL') IS NOT NULL
  DROP TABLE #TPOL
                         IF OBJECT_ID('tempdb..#AGENT') IS NOT NULL
  DROP TABLE #AGENT

SELECT * INTO #TDMAV  FROM    OPENQUERY(UAT7,'SELECT * FROM KCAPXPR1.TDMAV')
SELECT * INTO #TPHST  FROM    OPENQUERY(UAT7,'SELECT * FROM KCAPXPR1.TPHST')
SELECT * INTO #TAGRP  FROM    OPENQUERY(UAT7,'SELECT * FROM KCAPXPR1.TAGRP')
SELECT * INTO #TEDIT FROM    OPENQUERY(UAT7,'SELECT * FROM KCAPXPR1.TEDIT')
SELECT * INTO #TPOLC FROM    OPENQUERY(UAT7,'SELECT * FROM KCAPXPR1.TPOLC')
SELECT * INTO #TCLNM FROM    OPENQUERY(UAT7,'SELECT * FROM KCAPXPR1.TCLNM')
SELECT * INTO #TCLNC FROM    OPENQUERY(UAT7,'SELECT * FROM KCAPXPR1.TCLNC')
SELECT * INTO #TCLIC FROM    OPENQUERY(UAT7,'SELECT * FROM KCAPXPR1.TCLIC')
SELECT * INTO #TCLIA FROM    OPENQUERY(UAT7,'SELECT * FROM KCAPXPR1.TCLIA')
SELECT * INTO #TCVGC FROM    OPENQUERY(UAT7,'SELECT * FROM KCAPXPR1.TCVGC')
SELECT * INTO #TCVG FROM    OPENQUERY(UAT7,'SELECT * FROM KCAPXPR1.TCVG')
SELECT * INTO #TPOL FROM    OPENQUERY(UAT7,'SELECT * FROM KCAPXPR1.TPOL')
select * INTO #AGENT from DLKHFACT..FACT_AGENT where DATE_KEY = (SELECT MAX(DATE_KEY) FROM DLKHFACT..FACT_AGENT)

PRINT 'CTE Demo';

WITH OD_POL AS (
  SELECT      TPOL.CO_ID,
              TPOL.POL_ID,
              TPOL.POL_BASE_CVG_NUM,
              TPOL.POL_CSTAT_CD,
              TPOL.POL_CEAS_REASN_CD,
              TPOL.POL_ISS_EFF_DT,
              TPOL.POL_INFC_DT,
              TPOL.POL_OS_DISB_AMT,
              TPOL.POL_OS_DISB_DT,
              TPOL.PLAN_ID
              
  FROM        #TPOL AS TPOL
  
  WHERE       TPOL.CO_ID                =   'CP'
    AND       TPOL.POL_OS_DISB_AMT      <>   0

)

SELECT      ROW_NUMBER() OVER (ORDER BY TPOL.POL_ID) AS  NBR,
            GETDATE()                AS  REPT_DT,
            TPOL.POL_ID                 AS  POL_ID, 
            TDMAV.DM_AV_MODEL_TXT AS  POL_STATUS, 
            
            CASE  WHEN TPOL.POL_CSTAT_CD =  'E'
                  THEN TEDIT.ETBL_DESC_TXT
                  ELSE ''
            END                         AS  TPOL_REASON_TERM,
            
            TPOLC.CLI_ID,
            
            CASE
              WHEN    TCLNM_MAX.CO_ID   IS  NOT NULL
                THEN  RTRIM(LTRIM(TCLNM.CLI_INDV_SUR_NM)) +  ' ' +  RTRIM(LTRIM(TCLNM.CLI_INDV_GIV_NM))
              ELSE    RTRIM(LTRIM(TCLNC.CLI_CO_NM))
            END                         AS  POL_OWN_NAME,
            
            TOWNA.POL_OWNER_ADDRESS1, 
            TOWNA.POL_OWNER_ADDRESS2, 
            TOWNA.POL_OWNER_ADDRESS3, 
            TOWNA.POL_OWNER_ADDRESS4, 
            TCLIC1.CLI_CNTCT_ID_TXT     AS  PO_CEL_TEL,
            TCLIC2.CLI_CNTCT_ID_TXT     AS  PO_BIZ_TEL,
            TCLIC3.CLI_CNTCT_ID_TXT     AS  PO_RES_TEL,
            RTRIM(LTRIM(TLIFE.CLI_INDV_SUR_NM))  +  ' ' +  RTRIM(LTRIM(TLIFE.CLI_INDV_GIV_NM)) AS POL_INSRD_NAME,
            TPOL.POL_ISS_EFF_DT, 
            TPOL.POL_INFC_DT, 
            TPHST.PCHST_EFF_DT,
            TPOL.POL_OS_DISB_AMT,
            TPOL.POL_OS_DISB_DT,
            TAGRP.AGT_ID, 
            TPOL.PLAN_ID,
			TEDIT1.ETBL_DESC_TXT AS  PLAN_NAME,A.CHANNEL,RTRIM(LTRIM(A.ENTR_SUR_NM)) + ' ' + RTRIM(LTRIM(A.ENTR_GIV_NM))  AGENT_NAME,
			RTRIM(LTRIM(A.ABM_SURNAME)) + ' ' + RTRIM(LTRIM(A.ABM_SURNAME))  ABM_NAME,CG.CVG_MAT_XPRY_DUR

FROM        OD_POL AS TPOL

LEFT JOIN (
  SELECT      TPHST.CO_ID,
              TPHST.POL_ID,
              TPHST.PCHST_EFF_DT
              
  FROM       #TPHST TPHST
  
  INNER JOIN  OD_POL AS TPOL
  ON          TPOL.CO_ID                =   TPHST.CO_ID
    AND       TPOL.POL_ID               =   TPHST.POL_ID
  
  INNER JOIN (
    SELECT      PHST1.CO_ID,
                PHST1.POL_ID,
                PHST1.CVG_NUM,
                MAX(PHST1.PREV_UPDT_TS) AS MAX_UPDT_TS

    FROM        #TPHST PHST1

    INNER JOIN  OD_POL AS TPOL
    ON          TPOL.CO_ID                =   PHST1.CO_ID
      AND       TPOL.POL_ID               =   PHST1.POL_ID

    WHERE       PHST1.CO_ID             =   'CP'
      AND       PHST1.CVG_NUM           IS  NULL 
      AND       PHST1.POL_ACTV_TYP_ID   =   '3003'
      
   GROUP BY     PHST1.CO_ID,
                PHST1.POL_ID,
                PHST1.CVG_NUM
  ) AS PHST1
  ON          PHST1.CO_ID               =   TPHST.CO_ID
    AND       PHST1.POL_ID              =   TPHST.POL_ID
    AND       PHST1.MAX_UPDT_TS         =   TPHST.PREV_UPDT_TS
    
  WHERE       TPHST.CO_ID               =   'CP'
    AND       TPHST.CVG_NUM             IS  NULL 
    AND       TPHST.POL_ACTV_TYP_ID     =   '3003'
) AS TPHST
ON          TPHST.CO_ID                 =   TPOL.CO_ID
  AND       TPHST.POL_ID                =   TPOL.POL_ID

LEFT JOIN (
  SELECT      TAGRP.CO_ID,
              TAGRP.POL_ID,
              TAGRP.AGT_ID

  FROM        #TAGRP TAGRP 

  WHERE       TAGRP.CO_ID               =   'CP'
    AND       TAGRP.AGT_PREL_TYP_CD     =   'S'
) AS TAGRP
ON          TAGRP.CO_ID                 =   TPOL.CO_ID
  AND       TAGRP.POL_ID                =   TPOL.POL_ID

LEFT JOIN   #TDMAV TDMAV 
ON          TDMAV.DM_AV_TBL_CD          =   'POL-CSTAT-CD' 
  AND       TDMAV.DM_AV_CD              =   TPOL.POL_CSTAT_CD

LEFT JOIN   #TEDIT TEDIT 
ON          TEDIT.CO_ID                 =   TPOL.CO_ID
  AND       TEDIT.ETBL_TYP_ID           =   'CEASE'
  AND       TEDIT.ETBL_LANG_CD          =   'E'
  AND       TEDIT.ETBL_VALU_ID          =   TPOL.POL_CEAS_REASN_CD

LEFT JOIN   #TPOLC TPOLC
ON          TPOLC.CO_ID                 =   TPOL.CO_ID
  AND       TPOLC.POL_ID                =   TPOL.POL_ID
  AND       TPOLC.POL_CLI_REL_TYP_CD    =   'O'

LEFT JOIN (
  SELECT      TCLNM.CO_ID,
              TCLNM.CLI_ID,
              MAX(TCLNM.CLI_INDV_EFF_DT)  AS  MAX_EFF_DT
              
  FROM        #TCLNM TCLNM
  
  WHERE       TCLNM.CO_ID               =   'CP'
    AND       TCLNM.CLI_INDV_GR_CD      =   'AL'
  
  GROUP BY    TCLNM.CO_ID, TCLNM.CLI_ID
) TCLNM_MAX
ON          TCLNM_MAX.CO_ID             =   TPOLC.CO_ID 
  AND       TCLNM_MAX.CLI_ID            =   TPOLC.CLI_ID
                                        
LEFT JOIN   #TCLNC TCLNC       
ON          TCLNC.CO_ID                 =   TPOLC.CO_ID
  AND       TCLNC.CLI_ID                =   TPOLC.CLI_ID
  AND       TCLNM_MAX.CO_ID             IS  NULL
                                        
LEFT JOIN   #TCLNM TCLNM       
ON          TCLNM.CO_ID                 =   TCLNM_MAX.CO_ID 
  AND       TCLNM.CLI_ID                =   TCLNM_MAX.CLI_ID
  AND       TCLNM.CLI_INDV_EFF_DT       =   TCLNM_MAX.MAX_EFF_DT
  AND       TCLNM.CLI_INDV_GR_CD        =   'AL'
  AND       TCLNM_MAX.CO_ID             IS  NOT NULL
  
LEFT JOIN   #TCLIC TCLIC1
ON          TCLIC1.CO_ID                =   TPOLC.CO_ID
  AND       TCLIC1.CLI_ID               =   TPOLC.CLI_ID
  AND       TCLIC1.CLI_CNTCT_ID_CD      =   'CP'
 
LEFT JOIN   #TCLIC TCLIC2
ON          TCLIC2.CO_ID                =   TPOLC.CO_ID
  AND       TCLIC2.CLI_ID               =   TPOLC.CLI_ID
  AND       TCLIC2.CLI_CNTCT_ID_CD      =   'MO'
  
LEFT JOIN   #TCLIC TCLIC3
ON          TCLIC3.CO_ID                =   TPOLC.CO_ID
  AND       TCLIC3.CLI_ID               =   TPOLC.CLI_ID
  AND       TCLIC3.CLI_CNTCT_ID_CD      =   'HO'
          
LEFT JOIN (
  SELECT      TCLIA.CO_ID,
              TCLIA.CLI_ID,
              RTRIM(LTRIM(CLI_ADDR_LN_1_TXT)) AS POL_OWNER_ADDRESS1,
              RTRIM(LTRIM(CLI_ADDR_LN_2_TXT)) AS POL_OWNER_ADDRESS2,
              RTRIM(LTRIM(CLI_ADDR_LN_3_TXT)) AS POL_OWNER_ADDRESS3,
              RTRIM(LTRIM(CLI_CITY_NM_TXT))   AS POL_OWNER_ADDRESS4,
              TCLIA1.CLI_ADDR_TYP_CD

  FROM        #TCLIA AS TCLIA,
              (
                SELECT      TCLIA.CO_ID,
                            TCLIA.CLI_ID,
                            TCLIA.CLI_ADDR_TYP_CD,
                            MAX(TCLIA.CLI_ADDR_EFF_DT) AS MAX_ADDR_DT

                FROM        #TCLIA AS TCLIA

                WHERE       TCLIA.CO_ID                 =   'CP'
                  AND       TCLIA.CLI_ADDR_STAT_CD      =   'C'
                  AND       TCLIA.CLI_ADDR_GR_CD        =   'AL'

                GROUP BY    TCLIA.CO_ID,
                            TCLIA.CLI_ID,
                            TCLIA.CLI_ADDR_TYP_CD
              ) TCLIA1

  WHERE       TCLIA.CO_ID               =   TCLIA1.CO_ID
    AND       TCLIA.CLI_ID              =   TCLIA1.CLI_ID
    AND       TCLIA.CLI_ADDR_TYP_CD     =   TCLIA1.CLI_ADDR_TYP_CD
    AND       TCLIA.CLI_ADDR_EFF_DT     =   TCLIA1.MAX_ADDR_DT
) TOWNA
ON          TOWNA.CO_ID                 =   TPOLC.CO_ID
  AND       TOWNA.CLI_ID                =   TPOLC.CLI_ID
  AND       TOWNA.CLI_ADDR_TYP_CD       =   TPOLC.CLI_ADDR_TYP_CD

LEFT JOIN   #TCVGC TCVGC
ON          TCVGC.CO_ID                 =   TPOL.CO_ID
  AND       TCVGC.POL_ID                =   TPOL.POL_ID
  AND       CAST(TCVGC.CVG_NUM as int)          =   TPOL.POL_BASE_CVG_NUM
  AND       TCVGC.CVG_CLI_REL_TYP_CD    =   'P'

LEFT JOIN   (
  SELECT      TCLNM.CO_ID,
              TCLNM.CLI_ID,
              MAX(TCLNM.CLI_INDV_EFF_DT)  AS MAX_EFF_DT

  FROM        #TCLNM TCLNM

  WHERE       TCLNM.CO_ID               =   'CP'
    AND       TCLNM.CLI_INDV_GR_CD      =   'AL'

  GROUP BY    TCLNM.CO_ID, TCLNM.CLI_ID
) TINS_MAX
ON          TINS_MAX.CO_ID              =   TCVGC.CO_ID
  AND       TINS_MAX.CLI_ID             =   TCVGC.INSRD_CLI_ID

LEFT JOIN   #TCLNM TLIFE
ON          TLIFE.CO_ID                 =   TINS_MAX.CO_ID
  AND       TLIFE.CLI_ID                =   TINS_MAX.CLI_ID
  AND       TLIFE.CLI_INDV_EFF_DT       =   TINS_MAX.MAX_EFF_DT
  AND       TLIFE.CLI_INDV_GR_CD        =   'AL'
          
LEFT JOIN   #TEDIT AS TEDIT1
ON          TEDIT1.CO_ID                =   TPOL.CO_ID 
  AND       TEDIT1.ETBL_TYP_ID          =   'PLAN' 
  AND       TEDIT1.ETBL_LANG_CD         =   'E'
  AND       TEDIT1.ETBL_VALU_ID         =   TPOL.PLAN_ID
INNER JOIN #AGENT A ON A.AGT_ID=TAGRP.AGT_ID
INNER JOIN #TCVG CG ON CG.POL_ID=TPOL.POL_ID AND       CAST(CG.CVG_NUM as int)          =   TPOL.POL_BASE_CVG_NUM
ORDER BY    TPOL.POL_ID;
