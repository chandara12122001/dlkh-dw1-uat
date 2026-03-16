

-- Save to temp table due to future use of Hierachy Tier[1-7]
CREATE VIEW [dbo].[V_AGENT_HIERARCHY] AS 
WITH AgentName (AgentId, ClientId, Name,TitleId, TitleRole, ReportingTo)
AS (
	SELECT
		ag.AGT_ID,
		agCl.CLI_ID, 
   		RTRIM(agClName.CLI_INDV_SUR_NM) + ' ' + RTRIM(agClName.CLI_INDV_GIV_NM),
		ag.AGT_TITL,
   		agTlRol.ETBL_DESC_TXT,
   		ag.OVRID_BASE_AGT_ID
	FROM SGTM_AG ag
   		LEFT JOIN SGTM_AG_CLIENT agCl ON agCl.CO_ID='CP' AND agCl.AGT_CLI_REL_TYP_CD='R' AND agCl.AGT_ID=ag.AGT_ID -- R -> Regular, S -> Servicing, E -> Mailing
   		OUTER APPLY ( SELECT TOP 1 * FROM SGTM_CLIENT_IND cl WHERE cl.CO_ID='CP' AND cl.CLI_ID=agCl.CLI_ID  ORDER BY CLI_INDV_EFF_DT DESC )agClName
   		LEFT JOIN SGTB_EDITTABLE agTlRol ON agTlRol.ETBL_VALU_ID=ag.AGT_TITL AND agTlRol.CO_ID='CP' AND agTlRol.ETBL_LANG_CD='E' AND agTlRol.ETBL_TYP_ID='AGTLE'
	--ORDER BY  ag.AGT_ID
)
SELECT DISTINCT
    [AgentId] = ag.AGT_ID,
    [ClientId] =  agCl.CLI_ID,
    [Name] = agClName.[Name],
    [Gender] = agClPrf.CLI_SEX_CD,
    [BirthDate] = CONVERT(DATE,agClPrf.CLI_BTH_DT),
    [Cellphone]=cntCelPhn.CLI_CNTCT_ID_TXT,
    [OfficeNumber]= cntOffPhn.CLI_CNTCT_ID_TXT,
    [PhoneNumber] = RTRIM(ag.AGT_PHON_NUM),
    [Email] =cntEmail.CLI_CNTCT_ID_TXT,
    [EffectiveDateTitle] = CONVERT(DATE,ag.AGT_TITL_EFF_DT),
    [TerminationDate] = CONVERT(DATE,ag.AGT_CNTRCT_TRMN_DT),
    [Status] = CASE WHEN ag.AGT_STAT_CD='A' THEN 'Active'
                    WHEN ag.AGT_STAT_CD='I' THEN 'Inactive'
                    ELSE '' END,
	[ContractTypeCode] = RTRIM(ag.AGT_CMPNST_SCHD_CD),
    [ContractType]= cntTyp.ETBL_DESC_TXT,
    [ReferredById]= ag.AGT_REF_ID,
    [AgentType]= agTyp.DM_AV_DESC_TXT,
    [Branch]=agBrn.ETBL_DESC_TXT,
	[DistributionChannelCode]= RTRIM(ag.AGT_DISB_CHNL),
    [DistributionChannel]= agDshChn.ETBL_DESC_TXT,
    [TitleRole] = agTlRol.ETBL_DESC_TXT,
	[LeaderId] = CASE 
					WHEN tier1.TitleId IN('11','14') THEN tier1.AgentId 
					WHEN tier2.TitleId IN('11','14') THEN tier2.AgentId 
					WHEN tier3.TitleId IN('11','14') THEN tier3.AgentId 
					WHEN tier4.TitleId IN('11','14') THEN tier4.AgentId 
					WHEN tier5.TitleId IN('11','14') THEN tier5.AgentId 
					WHEN tier6.TitleId IN('11','14') THEN tier6.AgentId 
					WHEN tier7.TitleId IN('11','14') THEN tier7.AgentId 
				   END,
	[LeaderName] = CASE 
					WHEN tier1.TitleId IN('11','14') THEN tier1.Name 
					WHEN tier2.TitleId IN('11','14') THEN tier2.Name 
					WHEN tier3.TitleId IN('11','14') THEN tier3.Name 
					WHEN tier4.TitleId IN('11','14') THEN tier4.Name 
					WHEN tier5.TitleId IN('11','14') THEN tier5.Name 
					WHEN tier6.TitleId IN('11','14') THEN tier6.Name 
					WHEN tier7.TitleId IN('11','14') THEN tier7.Name 
				   END,
    [Tier1Id] =  CASE WHEN  ag.AGT_ID=tier1.[AgentId] THEN '' ELSE tier1.[AgentId] END ,
    [Tier1Name] = CASE WHEN  ag.AGT_ID=tier1.[AgentId] THEN '' ELSE tier1.[Name] END,
    [Tier1TitleRole] =  CASE WHEN  ag.AGT_ID=tier1.[AgentId] THEN '' ELSE tier1.[TitleRole] END,
    [Tier2Id] = CASE WHEN  tier1.[AgentId]=tier2.[AgentId] THEN '' ELSE tier2.[AgentId] END ,
    [Tier2Name] = CASE WHEN tier1.[AgentId]=tier2.[AgentId] THEN '' ELSE tier2.[Name] END ,
    [Tier2TitleRole] =  CASE WHEN  ag.AGT_ID=tier2.[AgentId] THEN '' ELSE tier2.[TitleRole] END,
    [Tier3Id] = CASE WHEN  tier2.[AgentId]=tier3.[AgentId] THEN '' ELSE tier3.[AgentId] END ,
    [Tier3Name] =CASE WHEN tier2.[AgentId]=tier3.[AgentId] THEN '' ELSE tier3.[Name] END ,
    [Tier3TitleRole] = CASE WHEN  tier2.[AgentId]=tier3.[AgentId] THEN '' ELSE tier3.[TitleRole] END,
    [Tier4Id] =  CASE WHEN  tier3.[AgentId]=tier4.[AgentId] THEN '' ELSE tier4.[AgentId] END,
    [Tier4Name] = CASE WHEN tier3.[AgentId]=tier4.[AgentId] THEN '' ELSE tier4.[Name] END,
    [Tier4TitleRole] = CASE WHEN  tier3.[AgentId]=tier4.[AgentId] THEN '' ELSE tier4.[TitleRole] END,
    [Tier5Id] = CASE WHEN  tier4.[AgentId]=tier5.[AgentId] THEN '' ELSE tier5.[AgentId] END,
    [Tier5Name] = CASE WHEN tier4.[AgentId]=tier5.[AgentId] THEN '' ELSE tier5.[Name] END,
    [Tier5TitleRole] = CASE WHEN  tier4.[AgentId]=tier5.[AgentId] THEN '' ELSE tier5.[TitleRole] END,
    [Tier6Id] = CASE WHEN  tier5.[AgentId]=tier6.[AgentId] THEN '' ELSE tier6.[AgentId] END,
    [Tier6Name] = CASE WHEN tier5.[AgentId]=tier6.[AgentId] THEN '' ELSE tier6.[Name] END,
    [Tier6TitleRole] = CASE WHEN  tier5.[AgentId]=tier6.[AgentId] THEN '' ELSE tier6.[TitleRole] END,
    [Tier7Id] = CASE WHEN  tier6.[AgentId]=tier7.[AgentId] THEN '' ELSE tier7.[AgentId] END,
    [Tier7Name] = CASE WHEN tier6.[AgentId]=tier7.[AgentId] THEN '' ELSE tier7.[Name] END,
    [Tier7TitleRole] =  CASE WHEN  tier6.[AgentId]=tier7.[AgentId] THEN '' ELSE tier7.[TitleRole] END
    --,

FROM SGTM_AG ag
    LEFT JOIN SGTM_AG_CLIENT agCl ON agCl.CO_ID='CP' AND agCl.AGT_CLI_REL_TYP_CD='R' AND agCl.AGT_ID=ag.AGT_ID -- R -> Regular, S -> Servicing, E -> Mailing
    --LEFT JOIN DLKHDIM..TCLNM agClName ON agClName.CO_ID='CP' AND agClName.CLI_ID=agCl.CLI_ID      -- Move to be handle by temp table -> due to duplication data
    LEFT JOIN AgentName agClName ON  agClName.ClientId=agCl.CLI_ID 
    LEFT JOIN SGTM_CLIENT agClPrf ON agClPrf.CO_ID='CP' AND agClPrf.CLI_ID=agCl.CLI_ID
    LEFT JOIN SGTM_CLIENT_CONTACT cntCelPhn ON cntCelPhn.CO_ID='CP' AND cntCelPhn.CLI_CNTCT_ID_CD='MO' AND cntCelPhn.CLI_ID=agCl.CLI_ID  -- CellPhone
    LEFT JOIN SGTM_CLIENT_CONTACT cntOffPhn ON cntOffPhn.CO_ID='CP' AND cntOffPhn.CLI_CNTCT_ID_CD='BU' AND cntOffPhn.CLI_ID=agCl.CLI_ID  -- OfficeNumber
    LEFT JOIN SGTM_CLIENT_CONTACT cntEmail ON cntEmail.CO_ID='CP' AND cntEmail.CLI_CNTCT_ID_CD='EM' AND cntEmail.CLI_ID=agCl.CLI_ID  -- Email
    LEFT JOIN SGTB_EDITTABLE cntTyp ON cntTyp.ETBL_VALU_ID=RTRIM(ag.AGT_CMPNST_SCHD_CD) AND cntTyp.CO_ID='CP' AND cntTyp.ETBL_LANG_CD='E' AND cntTyp.ETBL_TYP_ID='AGSCH'
    LEFT JOIN SGTM_PARA_1 agTyp ON agTyp.DM_AV_CD=ag.AGT_TYP_CD AND agTyp.CO_ID='CP' AND agTyp.DM_AV_DESC_LANG_CD='E' AND agTyp.DM_AV_TBL_CD='AGT-TYP-CD'
    LEFT JOIN SGTB_EDITTABLE agBrn ON agBrn.ETBL_VALU_ID=ag.BR_ID AND agBrn.CO_ID='CP' AND agBrn.ETBL_LANG_CD='E' AND agBrn.ETBL_TYP_ID='AKEY'
    LEFT JOIN SGTB_EDITTABLE agDshChn ON agDshChn.ETBL_VALU_ID=ag.AGT_DISB_CHNL AND agDshChn.CO_ID='CP' AND agDshChn.ETBL_LANG_CD='E' AND agDshChn.ETBL_TYP_ID='DCHNL'
    LEFT JOIN SGTB_EDITTABLE agTlRol ON agTlRol.ETBL_VALU_ID=ag.AGT_TITL AND agTlRol.CO_ID='CP' AND agTlRol.ETBL_LANG_CD='E' AND agTlRol.ETBL_TYP_ID='AGTLE'
    LEFT JOIN AgentName tier1 ON tier1.AgentId=ag.OVRID_BASE_AGT_ID
    LEFT JOIN AgentName tier2 ON tier2.AgentId=tier1.ReportingTo
    LEFT JOIN AgentName tier3 ON tier3.AgentId=tier2.ReportingTo
    LEFT JOIN AgentName tier4 ON tier4.AgentId=tier3.ReportingTo
    LEFT JOIN AgentName tier5 ON tier5.AgentId=tier4.ReportingTo
    LEFT JOIN AgentName tier6 ON tier6.AgentId=tier5.ReportingTo
    LEFT JOIN AgentName tier7 ON tier7.AgentId=tier5.ReportingTo
WHERE ag.CO_ID ='CP'
--ORDER BY ag.AGT_ID
