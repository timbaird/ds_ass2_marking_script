-- ##########################################################
-- MS COMMON Package - functions related to that table.
-- ##########################################################

Create Or Replace Package A2M_pkg_Common As
Procedure Getcur(Psysrefcur Out Sys_Refcursor, Psqlquery In Varchar2);
End A2M_pkg_Common;
/


Create Or Replace Package Body A2M_pkg_Common As
  Procedure Getcur(Psysrefcur Out Sys_Refcursor, Psqlquery In Varchar2) As
  begin
    Open Psysrefcur For Psqlquery;
	End Getcur;
End A2M_Pkg_Common;
/