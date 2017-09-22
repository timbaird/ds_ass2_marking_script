clear screen;

-- ***********************************
-- *** IMPORTANT - PLEASE READ THE READ ME FILE FOR INSTRUCTONS ON DEPENDENCIES AND HOW TO USE THIS SCRIPT
-- ***********************************

-- SET UP THE SOURCE DATA FOR STUDENTS
--@./A2M_Installer_Includes/A2M_source_data.sql;

-- SET UP THE ASSIGNMENT MARKING FRAMEWORK
@./A2M_Installer_Includes/A2M_Ddl.sql;
@./A2M_Installer_Includes/A2M_Ass_Data.sql;
@./A2M_Installer_Includes/A2M_Pkg_Create_Dummy.sql;
@./A2M_Installer_Includes/A2M_Pkg_Db_Object.sql;

-- SET UP THE ASSIGMENT MARKING PACKAGES
@./A2M_Installer_Includes/A2M_Pkg_Common.sql;
@./A2M_Installer_Includes/A2M_Pkg_assignment.sql;

-- SET UP MARKING PROCEDURES
@./A2M_Installer_Includes/A2M_Mark_Filter.sql;
@./A2M_Installer_Includes/A2M_mark_ds_ass2.sql;

-- PROCEDURE TO CLEAN UP TABLES CREATED TO EMULATE A 
-- STUDENTS ASSIGNMENT AND ENABLE INSTALLATION
@./A2M_Installer_Includes/A2M_clean_up.sql;
-- EXECUTE THE CLEAN UP PROCEDURE;
EXEC A2M_CLEAN_UP;

-- SET UP ADDITIONAL SYNONYMS AND PERMISSIONS 
--@./A2M_Installer_Includes/A2M_source_data_syn_perm.sql;
@./A2M_Installer_Includes/A2M_script_syn_perm.sql;


