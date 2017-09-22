create or replace Package A2M_Pkg_Assignment authid current_user As
Procedure Premark_Check(Passname Varchar2, pUser varchar2, Pdebug Boolean Default False);
End A2M_pkg_Assignment;
/


create or replace Package Body A2M_Pkg_Assignment As
  -- overloaded version
  Procedure Premark_Check(Passname varchar2, pUser varchar2, PDEBUG BOOLEAN DEFAULT false) as
  
    -- GET A LIST OF ALL THE REQUIRED OBJECTS FOR THIS ASSIGNMENT
    Cursor Vcur Is
    --Select * From tbaird.A2M_Db_Object
    Select * From A2M_Db_Object
    --where assid = (select assid from tbaird.A2M_assignment where assname = passname);
    where assid = (select assid from A2M_assignment where assname = passname);
      
      vQuery varchar2(200);
      vVariable varchar2(100);
      vResultInt integer;
  
  Begin

    -- CHECK IF THE A2M_NOT_ATTEMPTED TABLE EXISTS IN THE HOST ACCOUNT
  	SELECT count (*) INTO VRESULTINT FROM SYS.ALL_OBJECTS WHERE OWNER = user and OBJECT_NAME = 'A2M_NOT_ATTEMPTED';
  
    IF PDEBUG THEN DOPL('num tables named A2M_NOT_ATTEMPTED belonging to ' || user || ' ' || VRESULTINT); END IF;


  			-- if it has been created
    if vResultInt > 0 then
      --clear the table
      execute immediate'DELETE FROM ' || USER || ' .A2M_Not_Attempted';
      IF PDEBUG THEN DOPL('CLEARING A2M_NOT_ATTEMPTED TABLE'); END IF;
    
  	else -- it has not been created
  	  -- create the table 
      EXECUTE IMMEDIATE 'Create Table ' || USER || '.A2M_Not_Attempted(Db_Object_Name Varchar2(50))';
      IF PDEBUG THEN DOPL('CREATING NEW A2M_NOT_ATTEMPTED TABLE'); END IF;
  	end if;
    
  -- FOR EACH OF THE REQUIRED ITEMS
  
  
  	for vrec in vcur
  	Loop  

    
      -- IF THE OBJECT DOESN'T EXIST
    	If Not A2M_Pkg_Db_Object.Exist(Vrec.Objectid, PUSER) Then

      		if pdebug then dopl('DEBUG - ' || VREC.OBJECTNAME || ' DOES NOT EXIST'); END IF;
          
      		--A2M_Pkg_Db_Object.Create_Dummy(Vrec.Objectid, pUser);
          
      		if pdebug then dopl('DEBUG - ' || vREC.OBJECTNAME || ' DUMMY CREATED'); END IF;
      		vQuery := 'INSERT INTO ' || USER || '.A2M_NOT_ATTEMPTED (DB_OBJECT_NAME) VALUES (:TABLENAME)';
          
          EXECUTE IMMEDIATE vQuery using Vrec.Objectname;
          
          if pdebug then dopl('DEBUG - ' || VREC.OBJECTNAME || ' INSERTED INTO A2M_NOT_ATTEMPTED'); END IF;
    	End If;
    
  	End Loop;
       
  Exception
    When Others Then
      --DOPL('EXCEPTION');
      Raise; 
  End Premark_Check;
  
End A2M_pkg_Assignment;
/

commit;