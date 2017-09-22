-- NOTE:  THIS SCRIPT WILL ONLY WORK ON THE SWINBURNE DATABASE

CLEAR SCREEN;

exec tbaird.A2M_CLEAN_UP;

@./A2_SQLCODE.sql;
 
CLEAR SCREEN;

-- pre mark check for testing only
exec tbaird.A2M_pkg_assignment.premark_CHECK('DS Ass2', USER, false);

exec tbaird.A2M_Mark_Ds_Ass2( USER, FALSE);


