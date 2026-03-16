
/***************************************************************************************************
    Changelog
    ***********
	VERSION    DATE CHNG    UPDATE_BY    DESC
	VERS0.1		                          Initial Version
	VERS0.2	   12-06-2025    SAVRATH      Remove openquery to self
****************************************************************************************************/

CREATE VIEW [dbo].[V_POL_DISPATCH]
AS
SELECT        POL_ID, created_user, dispatched_date, acknowledgement_date, welcome_date
-- Initial Version
/*
FROM            OPENQUERY([10.116.17.52], 'SELECT policy_id AS POL_ID, created_user, dispatched_date, acknowledgement_date, welcome_date
FROM           [PNSDLIKH].[dbo].[ingenium_policy_dispatches]') AS derivedtbl_1
*/

-- VERS0.2
FROM (SELECT policy_id AS POL_ID, created_user, dispatched_date, acknowledgement_date, welcome_date
        FROM [PNSDLIKH].[dbo].[ingenium_policy_dispatches]) AS derivedtbl_1
