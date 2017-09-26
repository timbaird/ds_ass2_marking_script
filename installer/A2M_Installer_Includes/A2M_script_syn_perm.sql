
/*
DB SYSTEMS ASSIGNMENT 2 DATA WAREHOUSING 
SYNONYMS AND PERMISSIONS FOR MARKING SCRIPT
*/

-- SYNONYMS

set serveroutput on;

begin
    EXECUTE IMMEDIATE 'drop public synonym A2M_CLEAN_UP';
exception
    when others then
    DOPL('DROP SYNONYM A2M_CLEAN_UP: ' || SQLERRM);
END;
/
begin
    EXECUTE IMMEDIATE 'create public synonym A2M_CLEAN_UP  for ' || USER || '.A2M_CLEAN_UP';
exception
    when others then
    DOPL('CREATE SYNONYM A2M_CLEAN_UP: ' || SQLERRM);
END;
/    
begin
    EXECUTE IMMEDIATE 'drop public synonym A2M_Mark_Ds_Ass2';
exception
    when others then
    DOPL('DROP SYNONYM A2M_Mark_Ds_Ass2: ' || SQLERRM);
END;
/  
begin
    EXECUTE IMMEDIATE 'create public synonym A2M_Mark_Ds_Ass2  for ' || USER || '.A2M_Mark_Ds_Ass2';
exception
    when others then
    DOPL('CREATE SYNONYM A2M_Mark_Ds_Ass2: ' || SQLERRM);
END;
/
begin
    EXECUTE IMMEDIATE 'drop public synonym A2M_db_object';
exception
    when others then
    DOPL('DROP SYNONYM A2M_db_object: ' || SQLERRM);
END;
/   
begin
    EXECUTE IMMEDIATE 'create public synonym A2M_db_object  for ' || USER || '.A2M_db_object';
exception
    when others then
    DOPL('CREATE SYNONYM A2M_db_object: ' || SQLERRM);
END;
/   
begin
    EXECUTE IMMEDIATE 'drop public synonym A2M_assignment';
exception
    when others then
    DOPL('DROP SYNONYM A2M_assignment: ' || SQLERRM);
END;
/    
begin
    EXECUTE IMMEDIATE 'create public synonym A2M_assignment  for ' || USER || '.A2M_assignment';
exception
    when others then
    DOPL('CREATE SYNONYM A2M_assignment: ' || SQLERRM);
END;
/

-- permissions

GRANT EXECUTE ON A2M_CLEAN_UP TO PUBLIC;
GRANT EXECUTE ON A2M_pkg_assignment TO PUBLIC;
GRANT EXECUTE ON A2M_MARK_DS_ASS2 TO PUBLIC;
--GRANT EXECUTE ON A2M_Host_User TO PUBLIC;
GRANT SELECT ON A2M_DB_OBJECT TO PUBLIC;
GRANT SELECT ON A2M_assignment TO PUBLIC;



