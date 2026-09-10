USE [PNSDLIKH]
GO

/****** Object:  StoredProcedure [dbo].[RPT_PREMIUM_REMINDER]    Script Date: 7/28/2026 3:55:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[RPT_PREMIUM_REMINDER] 
@CallDateFrom DATE = NULL
,@CallDateTo DATE = NULL
,@GenDateFrom DATE = NULL
,@GenDateTo DATE = NULL
AS 
BEGIN
IF @CallDateFrom IS NOT NULL AND @CallDateTo IS NOT NULL
    BEGIN

    IF @GenDateFrom IS NOT NULL AND @GenDateTo IS NOT NULL
        SELECT PR.*
        , POLICY_STATUS = VCT.POLICY_STATUS_DESC
        , Matrial_Status =  LTRIM(RTRIM(PR.PO_MARIT_STAT_CD))
        , generation_date = DATEADD(DAY, +12, CONVERT (date, PR.PAID_TO_DATE))
        , appointment_date = AC.appointment_date
        , appointment_status = AC.appointment_status
        , paid_to_date = CONVERT (date, PR.PAID_TO_DATE)
        , agent_type = AGT_INFO.AGENT_TYPE
        FROM premium_reminders PR
        LEFT JOIN V_CALL_TOOL_RPT VCT ON PR.policy_number = VCT.POLICY_NUMBER
        LEFT JOIN appointment_calls AC ON PR.appointment_id = AC.id
        LEFT JOIN DLIUDW01.DLKHSTAGE.dbo.DMS_AGENT_DETAIL AGT_INFO ON PR.agent_id = CAST(AGT_INFO.AGENT_CODE AS VARCHAR)
        WHERE PR.date_call BETWEEN @CallDateFrom AND @CallDateTo
        AND PR.PAID_TO_DATE BETWEEN DATEADD(DAY, -12, @GenDateFrom) AND DATEADD(DAY, -12, @GenDateTo)
    ELSE
        SELECT PR.*
        , POLICY_STATUS = VCT.POLICY_STATUS_DESC
        , Matrial_Status =  LTRIM(RTRIM(PR.PO_MARIT_STAT_CD))
        , generation_date = DATEADD(DAY, +12, CONVERT (date, PR.PAID_TO_DATE))
        , appointment_date = AC.appointment_date
        , appointment_status = AC.appointment_status
        , paid_to_date = CONVERT (date, PR.PAID_TO_DATE)
	    , agent_type = AGT_INFO.AGENT_TYPE
        FROM premium_reminders PR
        LEFT JOIN V_CALL_TOOL_RPT VCT ON PR.policy_number = VCT.POLICY_NUMBER
        LEFT JOIN appointment_calls AC ON PR.appointment_id = AC.id
        LEFT JOIN DLIUDW01.DLKHSTAGE.dbo.DMS_AGENT_DETAIL AGT_INFO ON PR.agent_id = CAST(AGT_INFO.AGENT_CODE AS VARCHAR)
        WHERE PR.date_call BETWEEN @CallDateFrom AND @CallDateTo
    END

ELSE
    BEGIN
    IF @GenDateFrom IS NOT NULL AND @GenDateTo IS NOT NULL
        SELECT PR.*
        , POLICY_STATUS = VCT.POLICY_STATUS_DESC
        , Matrial_Status =  LTRIM(RTRIM(PR.PO_MARIT_STAT_CD))
        , generation_date = DATEADD(DAY, +12, CONVERT (date, PR.PAID_TO_DATE))
        , appointment_date = AC.appointment_date
        , appointment_status = AC.appointment_status
        , paid_to_date = CONVERT (date, PR.PAID_TO_DATE)
        , agent_type = AGT_INFO.AGENT_TYPE
        FROM premium_reminders PR
        LEFT JOIN V_CALL_TOOL_RPT VCT ON PR.policy_number = VCT.POLICY_NUMBER
        LEFT JOIN appointment_calls AC ON PR.appointment_id = AC.id
        LEFT JOIN DLIUDW01.DLKHSTAGE.dbo.DMS_AGENT_DETAIL AGT_INFO ON PR.agent_id = CAST(AGT_INFO.AGENT_CODE AS VARCHAR)
        WHERE PR.PAID_TO_DATE BETWEEN DATEADD(DAY, -12, @GenDateFrom) AND DATEADD(DAY, -12, @GenDateTo)
    ELSE
        SELECT PR.*
        , POLICY_STATUS = VCT.POLICY_STATUS_DESC
        , Matrial_Status =  LTRIM(RTRIM(PR.PO_MARIT_STAT_CD))
        , generation_date = DATEADD(DAY, +12, CONVERT (date, PR.PAID_TO_DATE))
        , appointment_date = AC.appointment_date
        , appointment_status = AC.appointment_status
        , paid_to_date = CONVERT (date, PR.PAID_TO_DATE)
        , agent_type = AGT_INFO.AGENT_TYPE
        FROM premium_reminders PR
        LEFT JOIN V_CALL_TOOL_RPT VCT ON PR.policy_number = VCT.POLICY_NUMBER
        LEFT JOIN appointment_calls AC ON PR.appointment_id = AC.id
        LEFT JOIN DLIUDW01.DLKHSTAGE.dbo.DMS_AGENT_DETAIL AGT_INFO ON PR.agent_id = CAST(AGT_INFO.AGENT_CODE AS VARCHAR)
    END

END






GO


 