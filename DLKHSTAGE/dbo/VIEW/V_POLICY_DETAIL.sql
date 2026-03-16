
CREATE VIEW [dbo].[V_POLICY_DETAIL] AS
SELECT [PolicyNumber]=ch.POL_ID,
		[ApplicationNumber]=ch.POL_APP_FORM_ID,
		[POClientId]=po.CLI_ID,
		--[PolicyStatusCode] = ch.POL_CSTAT_CD, -- Cannot be used as code is number and letter
		[PlanCode]=ch.PLAN_ID,
		[PlanName]=PLN.ETBL_DESC_TXT,
		[StatusCode]=ch.POL_CSTAT_CD,
		[Status] = PSTAT.DM_AV_DESC_TXT,
		[BillingMode]=BLLM.ETBL_DESC_TXT,
		[GrossAnnualPremium]= ch.POL_GRS_APREM_AMT,
		--[ModalPremium/FYP]=ch.POL_MPREM_AMT, -- Model Premium Flag 0 when policy is not inforce
		[ModalPremium/FYP]=cov.CoveragePremium, 
		[APE/AFYP]= cov.CoveragePremium * (12/ch.POL_BILL_MODE_CD), -- 01 Monthly, 03 Quaterly, 06 Semi Annual, 12 Annaul
		--ch.POL_BILL_MODE_CD,
		[WFYP]='', -- if policy term is less than or equal to 6 year -> WFYP = APE/2 --> Sale Performance
		--ch.POL_PD_TO_DT_NUM,
		[Term] =  covrTrm.CVG_MAT_XPRY_DUR,
		[PaidToDate] = dbo.fnConvertChartoDateNoneStandard(ch.POL_PD_TO_DT_NUM), -- Paid to date data issue [Invalid data to convert to date]
		[BillToDate]= dbo.fnConvertChartoDateNoneStandard(ch.POL_BILL_TO_DT_NUM),
		[ApplicationSignedDate]= ch.POL_APP_SIGN_DT,
		[ApplicationReceivedDate]=ch.POL_APP_RECV_DT,
		[EffectiveDate]=ch.POL_ISS_EFF_DT,
		[IssueDate]=ch.POL_INFC_DT,
		[ReIssueDate]=ch.POL_REISS_DT,
		[NotTakenDate]= case when ch.POL_CSTAT_CD = 'A' then ch.POL_STAT_CHNG_DT else null end,
		[LastNotTakenDate]= null,
		[NumberOfCoverage]=ch.POL_CVG_REC_CTR,
		[ServicingAgentId]=ch.SERV_AGT_ID,
		[WritingAgentId]=wAgt.AGT_ID,
		[WritingAgentSharePercentage]=wAgt.POL_AGT_SHR_PCT,
		[SoldBranch]=SOLDBR.ETBL_DESC_TXT, 
		[SourceOfCustomer] = SRC.ETBL_DESC_TXT
	FROM SGTB_POLICY ch
		LEFT JOIN SGTB_POLICY_WRITING wAgt ON wAgt.CO_ID='CP' AND wAgt.POL_ID=ch.POL_ID
		LEFT JOIN SGTB_POLICY_CLIENT po ON po.CO_ID='CP' AND po.POL_CLI_REL_TYP_CD='O' AND po.POL_ID=ch.POL_ID  -- O -> PO, P -> Payor
		LEFT JOIN SGTM_PARA SOLDBR ON SOLDBR.ETBL_VALU_ID = wAgt.POL_SOLD_BR_ID AND SOLDBR.ETBL_TYP_ID = 'SOLDBR' AND SOLDBR.ETBL_LANG_CD = 'E'
		LEFT JOIN SGTM_PARA_1 PSTAT ON PSTAT.DM_AV_CD = ch.POL_CSTAT_CD AND PSTAT.DM_AV_TBL_CD='POL-CSTAT-CD' AND PSTAT.DM_AV_DESC_LANG_CD = 'E' AND PSTAT.CO_ID = 'CP'
		LEFT JOIN SGTB_EDITTABLE PLN ON PLN.ETBL_VALU_ID = ch.PLAN_ID AND PLN.ETBL_LANG_CD = 'E' AND PLN.CO_ID = 'CP' AND PLN.ETBL_TYP_ID = 'PLAN'
		LEFT JOIN SGTB_EDITTABLE SRC ON SRC.ETBL_VALU_ID = ch.CUST_SRC_CD AND SRC.ETBL_LANG_CD = 'E' AND SRC.CO_ID = 'CP' AND SRC.ETBL_TYP_ID = 'CSRC'
		LEFT JOIN SGTB_EDITTABLE BLLM ON BLLM.ETBL_VALU_ID = ch.POL_BILL_MODE_CD AND BLLM.ETBL_LANG_CD = 'E' AND BLLM.CO_ID = 'CP' AND BLLM.ETBL_TYP_ID = 'BILL-MODE'
		LEFT JOIN ( SELECT POL_ID, CVG_CSTAT_CD , SUM(CVG_MPREM_AMT) AS [CoveragePremium] FROM  SGTM_COVERAGE GROUP BY POL_ID,CVG_CSTAT_CD ) cov ON cov.POL_ID=ch.POL_ID AND cov.CVG_CSTAT_CD=ch.POL_CSTAT_CD
		LEFT JOIN SGTM_COVERAGE covrTrm ON covrTrm.CO_ID='CP' AND covrTrm.POL_ID=ch.POL_ID AND covrTrm.ORIG_PLAN_ID=ch.PLAN_ID
		WHERE  CH.POL_BILL_MODE_CD != ' '
