Create Or Replace Package A2M_Pkg_Create_Dummy AUTHID CURRENT_USER As
Procedure Db_Table(Pobjectid Varchar2, puser varchar2, PDEBUG BOOLEAN DEFAULT FALSE);
End A2M_PKG_Create_Dummy;
/


Create Or Replace Package Body A2M_PKG_Create_Dummy As

  Procedure Db_Table (Pobjectid Varchar2, puser varchar2, PDEBUG BOOLEAN DEFAULT FALSE) AS

    Vname A2M_Db_Object.Objectname%Type;
    Vquery Varchar2(1000);
    Vfirst Boolean := True;

    Cursor Vcur Is
      Select * 
	  From A2M_Db_Object_Item
      --From TBAIRD.A2M_Db_Object_Item
      where objectid = pobjectid;

  Begin

    if pdebug then dopl('DEBUG - SELECTING OBJECT NAME IN WHERE OBJECT ID = ' || POBJECTID); END IF;

    Select Objectname Into Vname
	From A2M_Db_Object
    --From TBAIRD.A2M_Db_Object
    where objectid = pobjectid;
    
    if pdebug then dopl('DEBUG - OBJECTNAME: ' || VNAME); END IF;
    

    Vquery := 'CREATE TABLE ' || USER || '.' || Vname || '(';
  
    -- based on columns only
  
    For Vrec In Vcur
    Loop
  
      If Not Vfirst Then
        Vquery := Vquery || ', ';
      Else
        vfirst := false;
      End If;

      If Vrec.Itemtype = 'COLUMN' Then
    
        Vquery := Vquery || Vrec.Itemname || ' ' || Vrec.Datatype;
    
        Case
        When vrec.datalength is Null Then 
          Vquery := Vquery;
        Else
          Vquery := Vquery || '(' || vrec.datalength || ')' ;
        End Case;
      Elsif Vrec.Itemtype = 'CONSTRAINT' Then
        VQUERY := VQUERY || 'CONSTRAINT ' || VREC.ITEMNAME || ' ' || VREC.ITEMSUBTYPE || VREC.CONDITIONS;
      END IF;
 
    end loop;
  
    vquery := vquery || ')';
  
  If pdebug then dopl('DEBUG - EXECUTEING QUERY: ' || VQUERY); END IF;
  
  execute immediate vquery;

  Exception
    When Others Then
      Raise;
    
  End Db_Table;

End A2M_PKG_Create_Dummy;
/


