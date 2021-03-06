
-- DB SYSTEMS ASSIGNMENT 2 DATA WAREHOUSING - installation clean up


-- clean out the tables created to emulate a students assignment an enable installation.

CREATE OR REPLACE PROCEDURE A2M_CLEAN_UP AUTHID CURRENT_USER AS
BEGIN  
    DROP_IF_EXISTS('DWCUST', TRUE, TRUE);
    DROP_IF_EXISTS('DWPROD', TRUE, TRUE);
    DROP_IF_EXISTS('DWSALE', TRUE, TRUE);
	DROP_IF_EXISTS('GENDERSPELLING', TRUE, TRUE);
	DROP_IF_EXISTS('A2ERROREVENT', TRUE, TRUE);
	DROP_IF_EXISTS('A2M_NOT_ATTEMPTED', TRUE, TRUE);
EXCEPTION
	WHEN OTHERS THEN
	DOPL('ERROR IN A2M_CLEAN_UP: ' || SQLERRM);
END;
/