-- ##########################################################
-- MS DB OBJECT Package - functions related to that table.
-- ##########################################################

Create Or Replace Package A2M_Pkg_Db_Object AUTHID CURRENT_USER As
FUNCTION EXIST(POBJECTID INTEGER, PUSER VARCHAR2, PDEBUG BOOLEAN DEFAULT FALSE) RETURN BOOLEAN;
procedure CREATE_DUMMY(pOBJECTID INTEGER, puser varchar2, PDEBUG BOOLEAN DEFAULT FALSE);
End A2M_Pkg_DB_OBJECT;
/

Create Or Replace Package BODY A2M_Pkg_Db_Object As

FUNCTION EXIST(POBJECTID INTEGER, PUSER VARCHAR2, PDEBUG BOOLEAN DEFAULT FALSE) RETURN BOOLEAN AS

  VOBJNAME A2M_DB_OBJECT.OBJECTNAME%TYPE;
  Vobjtype A2M_DB_OBJECT.OBJECTTYPE%TYPE;
  Vcount Integer;
  E_SOMETHING_WEIRD EXCEPTION;

begin

  If Pdebug Then Dopl('DEBUG - SELECTING OBJECTNAME AND OBJECT TYPE WTH ID: ' || POBJECTID); End If;
  
  -- GET THE TYPE OF THE OBJECT
  Select OBJECTNAME, Objecttype Into VOBJNAME, Vobjtype 
  --from tbaird.A2M_db_object where objecTID= POBJECTID;
  from A2M_db_object where objecTID= POBJECTID;
  
  If Pdebug Then Dopl('DEBUG - OBJECTNAME: ' || VOBJNAME || ' OBJECT TYPE: ' ||  VOBJTYPE); End If;

  -- GET THE NUMBER OF OBJECTS OF THIS NAME, AND TYPE FOR THIS OWNER
  Select Count(*) Into Vcount From Sys.All_Objects
  Where Object_Name = Upper(VobJname)
  And Object_Type = Vobjtype
  AND OWNER = USER;
  
  If Pdebug Then Dopl('DEBUG - NUMBER OF OBJECTS IN THE DB: ' || VCOUNT); End If;

  -- DEPENDING ON COUNT RETURN THE ANSWER - TRUE = OBJECT EXISTS
  If Vcount = 1 Then
    Return True;
  Elsif Vcount = 0 Then
    Return False;
  Else
    Raise E_Something_Weird;
  END IF;



exception

  When E_Something_Weird Then
    Raise_Application_Error(-20001, 'SOMETHING WEIRD GOING ON WITH COUNT');
  When Others Then
    Raise;
END EXIST;

procedure CREATE_DUMMY(pOBJECTID INTEGER, puser varchar2, PDEBUG BOOLEAN DEFAULT FALSE) as

  Vobjtype A2M_Db_Object.Objecttype%Type;
  E_Invalid_Type Exception;
  
Begin

  if pdebug then dopl('DEBUG - SELECTING OBJECTTYPE IN WHERE OBJECT ID = ' || POBJECTID); END IF;

  Select Objecttype Into Vobjtype
  From A2M_Db_Object
  WHERE OBJECTID = POBJECTID;
  
  if pdebug then dopl('DEBUG - OBJECTTYPE: ' || VOBJTYPE); END IF;

  Case Vobjtype
    When 'TABLE' Then
      A2M_PKG_Create_Dummy.Db_Table(POBJECTID, puser);  
      
    When 'PROCEDURE' Then
      DOPL('CONSTRUCT_PROCEDURE(POBJECTID)');  
    When 'FUNCTION' Then
      DOPL('CONSTRUCT_FUNCTION(POBJECTID)');   
    When 'TRIGGER' Then
      DOPL('CONSTRUCT_TRIGGER(POBJECTID)');    
    When 'SEQUENCE' Then
      DOPL('CONSTRUCT_SEQUENCE(POBJECTID)');   
    When 'PACKAGE' Then
      DOPL('CONSTRUCT_PACKAGE(POBJECTID)');   
    When 'PACKAGE BODY' Then
      DOPL('CONSTRUCT_PACKAGE_BODY(POBJECTID)');   
    When 'INDEX' Then
      DOPL('CONSTRUCT_INDEX(POBJECTID)');    
    When 'SYNONYM' Then
      DOPL('CONSTRUCT_SYNONYM(POBJECTID)');  
    When 'VIEW' Then
      DOPL('CONSTRUCT_VIEW(POBJECTID)');   
    When 'TYPE' Then
      DOPL('CONSTRUCT_TYPE(POBJECTID)');   
  Else
    Raise E_Invalid_Type;
  End CASE;

Exception

  When E_Invalid_Type Then
    Raise_Application_Error(-20002, 'INVALID OBJECT TYPE PASSED TO A2M_PKG_DB_OBJECT.CREATE_DUMMY - ' || SQLERRM);
    
  When Others Then
    RAISE;

END CREATE_DUMMY;

End A2M_Pkg_Db_Object;
/

