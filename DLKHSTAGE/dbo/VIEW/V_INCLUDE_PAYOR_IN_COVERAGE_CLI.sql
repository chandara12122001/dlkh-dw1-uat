CREATE VIEW dbo.V_INCLUDE_PAYOR_IN_COVERAGE_CLI
AS
SELECT        'CP' AS CO_ID, LI.POL_ID, LI.CVG_NUM, CVGC.CVG_CLI_REL_TYP_CD, POLC.CLI_ID AS PO_ID, LI.INSRD_CLI_ID, CLIR.INSRD_ROLE, CVGC.PREV_UPDT_USER_ID, CVGC.PREV_UPDT_TS, CVGC.CVG_CLI_ISS_AGE, 
                         CVGC.CVG_CLI_ADJ_AGE, CVGC.ETL_DATE
FROM            (SELECT        INSRD_CLI_ID, POL_ID, CVG_NUM
                          FROM            dbo.SGTB_COVERAGE_CLI
                          UNION ALL
                          SELECT        CLI_ID, POL_ID, '00' AS CVG_NUM
                          FROM            dbo.SGTB_POLICY_CLIENT
                          WHERE        (CLI_ID NOT IN
                                                       (SELECT        INSRD_CLI_ID
                                                         FROM            dbo.SGTB_COVERAGE_CLI AS SGTB_COVERAGE_CLI_1))) AS LI LEFT OUTER JOIN
                         dbo.SGTB_COVERAGE_CLI AS CVGC ON LI.INSRD_CLI_ID = CVGC.INSRD_CLI_ID AND LI.POL_ID = CVGC.POL_ID AND LI.CVG_NUM = CVGC.CVG_NUM LEFT OUTER JOIN
                         dbo.V_GET_CVG_INSRD_ROLE AS CLIR ON CVGC.INSRD_CLI_ID = CLIR.INSRD_CLI_ID AND CVGC.POL_ID = CLIR.POL_ID AND CVGC.CVG_NUM = CLIR.CVG_NUM LEFT OUTER JOIN
                         dbo.SGTB_POLICY_CLIENT AS POLC ON LI.POL_ID = POLC.POL_ID AND POLC.POL_CLI_REL_TYP_CD = 'O'
