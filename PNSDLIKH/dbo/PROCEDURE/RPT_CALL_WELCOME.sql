
CREATE PROCEDURE [dbo].[RPT_CALL_WELCOME] 
 @CallDateFrom DATE = NULL
 ,@CallDateTo DATE = NULL
 ,@GenDateFrom DATE = NULL
 ,@GenDateTo DATE = NULL
AS 
BEGIN
 IF @CallDateFrom IS NOT NULL AND @CallDateTo IS NOT NULL
  BEGIN
  
   IF @GenDateFrom IS NOT NULL AND @GenDateTo IS NOT NULL
    SELECT CW.*
    , POLICY_STATUS = VCT.POLICY_STATUS_DESC
    , Matrial_Status = LTRIM(RTRIM(CW.PO_MARIT_STAT_CD))
    , generation_date = DATEADD(DAY, +4, CONVERT (date, CW.POLICY_ISSUE_DATE))
    , appointment_date = AC.appointment_date
    , appointment_status = AC.appointment_status
    , paid_to_date = CONVERT (date, CW.PAID_TO_DATE)
	, agent_type = AGT_INFO.AGENT_TYPE
    FROM call_welcomes CW
    LEFT JOIN V_CALL_TOOL_RPT VCT ON CW.policy_number = VCT.POLICY_NUMBER
    LEFT JOIN appointment_calls AC ON CW.appointment_id = AC.id
	LEFT JOIN DLIUDW01.DLKHSTAGE.dbo.DMS_AGENT_DETAIL AGT_INFO ON CW.agent_id = CAST(AGT_INFO.AGENT_CODE AS VARCHAR)
    WHERE CW.date_call BETWEEN @CallDateFrom AND @CallDateTo
    AND CW.POLICY_ISSUE_DATE BETWEEN DATEADD(DAY, -4, @GenDateFrom) AND DATEADD(DAY, -4, @GenDateTo)
   ELSE
    SELECT CW.*
    , POLICY_STATUS = VCT.POLICY_STATUS_DESC
    , Matrial_Status = LTRIM(RTRIM(CW.PO_MARIT_STAT_CD))
    , generation_date = DATEADD(DAY, +4, CONVERT (date, CW.POLICY_ISSUE_DATE))
    , appointment_date = AC.appointment_date
    , appointment_status = AC.appointment_status
    , paid_to_date = CONVERT (date, CW.PAID_TO_DATE)
	, agent_type = AGT_INFO.AGENT_TYPE
    FROM call_welcomes CW
    LEFT JOIN V_CALL_TOOL_RPT VCT ON CW.policy_number = VCT.POLICY_NUMBER
    LEFT JOIN appointment_calls AC ON CW.appointment_id = AC.id
	LEFT JOIN DLIUDW01.DLKHSTAGE.dbo.DMS_AGENT_DETAIL AGT_INFO ON CW.agent_id = CAST(AGT_INFO.AGENT_CODE AS VARCHAR)
    WHERE CW.date_call BETWEEN @CallDateFrom AND @CallDateTo
  END
  
 ELSE
  BEGIN
   IF @GenDateFrom IS NOT NULL AND @GenDateTo IS NOT NULL
    SELECT CW.*
    , Matrial_Status = LTRIM(RTRIM(CW.PO_MARIT_STAT_CD))
    , POLICY_STATUS = VCT.POLICY_STATUS_DESC
    , generation_date = DATEADD(DAY, +4, CONVERT (date, CW.POLICY_ISSUE_DATE))
    , appointment_date = AC.appointment_date
    , appointment_status = AC.appointment_status
    , paid_to_date = CONVERT (date, CW.PAID_TO_DATE)
	, agent_type = AGT_INFO.AGENT_TYPE
    FROM call_welcomes CW
    LEFT JOIN V_CALL_TOOL_RPT VCT ON CW.policy_number = VCT.POLICY_NUMBER
    LEFT JOIN appointment_calls AC ON CW.appointment_id = AC.id
	LEFT JOIN DLIUDW01.DLKHSTAGE.dbo.DMS_AGENT_DETAIL AGT_INFO ON CW.agent_id = CAST(AGT_INFO.AGENT_CODE AS VARCHAR)
    WHERE CW.POLICY_ISSUE_DATE BETWEEN DATEADD(DAY, -4, @GenDateFrom) AND DATEADD(DAY, -4, @GenDateTo)
   ELSE
    SELECT CW.*
    , POLICY_STATUS = VCT.POLICY_STATUS_DESC
    , Matrial_Status = LTRIM(RTRIM(CW.PO_MARIT_STAT_CD))
    , generation_date = DATEADD(DAY, +4, CONVERT (date, CW.POLICY_ISSUE_DATE))
    , appointment_date = AC.appointment_date
    , appointment_status = AC.appointment_status
    , paid_to_date = CONVERT (date, CW.PAID_TO_DATE)
	, agent_type = AGT_INFO.AGENT_TYPE
    FROM call_welcomes CW
    LEFT JOIN V_CALL_TOOL_RPT VCT ON CW.policy_number = VCT.POLICY_NUMBER
    LEFT JOIN appointment_calls AC ON CW.appointment_id = AC.id
	LEFT JOIN DLIUDW01.DLKHSTAGE.dbo.DMS_AGENT_DETAIL AGT_INFO ON CW.agent_id = CAST(AGT_INFO.AGENT_CODE AS VARCHAR)
  END
  
END
GO

 