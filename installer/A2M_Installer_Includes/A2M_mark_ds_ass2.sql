-- ensure ass2 related db objects exist so A2M_Mark_ds_ass2 function compiles
-- this is done at install time, it needs to be duplicated in the procedure below
execute A2M_pkg_assignment.premark_CHECK('DS Ass2', USER);

create or replace procedure A2M_mark_ds_ass2(PUSER VARCHAR2, pDebug boolean default false) AUTHID CURRENT_USER as

VQUERY VARCHAR2(1000);

Vtotalmarks Integer := 0;
Vsectionmarks Integer := 0;
VINTEGER Integer;
Vvarchar Varchar2(1000);
VERROREVENTOK BOOLEAN := TRUE;

vResultPart1 Boolean := true;
vResultPart2 Boolean := false;
vResultPart3 Boolean := false;
vResultPart4 Boolean := false;
vResultPart5 Boolean := false;
vResultPart6 Boolean := false;
vResultPart7 Boolean := false;

vCorrectInteger integer;

vPassPercent number(2,1) := 0.8; 


Begin

  -- this is called during marking, it needs to be duplicated with the call above
  -- which is used for install time.
  A2M_pkg_assignment.premark_CHECK('DS Ass2', puser, FALSE);

  -- CHECK FOR FAILURE TO CREATE ERROR EVENT TABLE
  Declare
    E_ERROR_EVENT EXCEPTION;
  Begin
  
    VQUERY := 'Select Count(*)
               From ' || USER || '.A2M_Not_Attempted
               WHERE DB_OBJECT_NAME = ''A2ERROREVENT''';
    
    EXECUTE IMMEDIATE VQUERY INTO VINTEGER;
    
    If Vinteger > 0 Then
      RAISE E_ERROR_EVENT;
    End If;
  Exception
    When E_Error_Event Then
      vResultPart1 := false;
      Raise_Application_Error(-20001, 'A2ERROREVENT TABLE NOT CREATED');
    When Others Then
      Raise;
  End;
  
  
  -------------------
  -------------------
  --  start part 2
  -------------------
  -------------------


  If Pdebug Then Dopl('MARK THE FILTERS'); End If;
  if pdebug then dopl(' '); END IF;


  -- filter 1 correct answer
  Select count(*) into vCorrectInteger From A2product 
	Where prodNAME is null;
  
  -- MARK filter 1
  A2M_Mark_Filter(1, vCorrectInteger, 2, Vsectionmarks, user, PDEBUG);
  
  
  -- filter 2 correct answer
  Select count(*) into vCorrectInteger From A2product 
	Where MANUFACTURERCODE is null;
  
  -- MARK filter 2
  A2M_Mark_Filter(2, vCorrectInteger, 1, Vsectionmarks, user, PDEBUG);
  
    -- filter 3 correct answer
  Select count(*) into vCorrectInteger From A2product 
	Where Prodcategory Not In (Select Productcategory From A2prodcategory)
	OR prodcategory is null;
  
  
  -- MARK filter 3
  A2M_Mark_Filter(3, vCorrectInteger, 3, Vsectionmarks, user, PDEBUG);
  
  If Pdebug Then Dopl(' '); End If;
  If Pdebug Then Dopl('MARK THE DATA TRANSFER'); End If;
  if pdebug then dopl(' '); END IF;
  
  
  
  
  -- MARK THE PART 2 DATA TRANSFER
  Declare
    VINITIALCHECK INTEGER;
    VSOURCE INTEGER;
    Vactual Integer;
    Vexcluded Integer;
    Valtered Integer;
    Vtomodify Integer;
    
  Begin
  
    -- CHECK IF DWPROD CREATED    
    VQUERY := 'Select Count(*)
               From ' || USER || '.A2M_Not_Attempted
               WHERE DB_OBJECT_NAME = ''DWPROD''';
    
    EXECUTE IMMEDIATE VQUERY INTO VINTEGER;
    
    if pdebug then dopl('DEBUG - NUM DWPROD IN A2M_NOT_ATTEMPTED:  ' || VINTEGER); END IF;
    
    -- MAKE SURE THAT AT LEAST ONE OF THE FILTERS IN THIS SECTION
    -- HAS AN ENTRY IN THE ERROR EVET TABLE    
    VQUERY := 'Select Count(*)
               From ' || USER || '.A2ERROREVENT
               Where Filterid In (1,2,3)
               AND FILTERID IS NOT NULL';
    
    EXECUTE IMMEDIATE VQUERY INTO Vinitialcheck;
    
    -- IF THE TABLE WASN'T CREATED 0 MARKS FOR INSERTION PARTS
    If Vinteger  > 0 Then
      vResultPart1 := false;
      Dopl('DWPROD TABLE NOT CREATED CORRECTLY');
    Elsif Vinitialcheck= 0 Then
      Dopl('NO FILTER ENTRIES FOR PART 2 FILTERS - TRANSFER CANNOT BE GRADED');
    Else
      
      -- FILTER 1 WAS SKIP, 2 AND 3 WERE MODIFY
      -- # IN DWPROD = # IN A2PRODUCT - # FILTER 1 FAILS
      
      -- find out how many in source table A2Product
      Select Count(*) Into Vsource From A2product;

      -- find out how many transfered to DW Prod
      VQUERY := 'Select Count(*)
               From ' || PUSER || '.DWPROD';
    
      EXECUTE IMMEDIATE VQUERY INTO Vactual;
      
      -- find out how many should have been excluded from dwprod due to filter 1
      VQUERY := 'Select Count(*)
                 From ' || PUSER || '.A2errorevent
                 Where Filterid = 1 AND FILTERID IS NOT NULL';
    
      EXECUTE IMMEDIATE VQUERY INTO Vexcluded;
      
      if pdebug then dopl('DEBUG - TRANSFER SUMMARY - SOURCE: ' ||  VSOURCE ||
                                                    ' = DW: ' || Vactual ||
                                                    ' + EE SKIPS : ' || VEXCLUDED ); END IF;
      
      -- find out how many should have been modified due to filters 2 and 3
      VQUERY := 'Select Count(*)
                 From ' || PUSER || '.A2errorevent
                 Where Filterid In (2,3) And Filterid Is Not Null';
    
      EXECUTE IMMEDIATE VQUERY INTO Vtomodify;
      
      -- find out how many were correctly altered due to filters 2 and 3      
      VQUERY := 'Select Count(*)
                 From ' || PUSER || '.Dwprod
                 Where Upper(Prodmanuname) = ''UNKNOWN'' And Prodmanuname Is Not Null
                 Or Upper(Prodcatname) = ''UNKNOWN'' And Prodcatname Is Not Null';
    
      EXECUTE IMMEDIATE VQUERY INTO ValtereD;
      
      If Pdebug Then Dopl('DEBUG - MODIDY SUMMARY - TO MODIFY: ' || Vtomodify || 
                                                  ' = MODIFIED: ' || VALTERED); END IF;     
      
      -- if the # in source = # in dw + # excluded  AND the # modified 
      -- matches the # that should have been modified then all CORRECT
      If Vsource = (Vactual + Vexcluded) And Vtomodify = Valtered and valtered > 0 Then
        Vsectionmarks := Vsectionmarks + 4;
        
      -- if the # in source = # in dw + # excluded  - only exclusions done correctly
      Elsif Vsource = (Vactual + Vexcluded) Then
        Dopl('MODIFICATIONS NOT DONE CORRECTLY');
        Vsectionmarks := Vsectionmarks + 2;  
        
      -- the # modified matches the # that should have been modified then only modifications done correctly
      Elsif Vtomodify = Valtered Then
        Dopl('INCORRECT NUMBER OF ROWS TRANSFERRED');
        Vsectionmarks := Vsectionmarks + 2;
      ELSE
        -- Tneither done correctly
        Dopl('INNCORRECT NUMBER OF ROWS TRANSFERRED AND PROBLEMS IN MODIFICATIONS');
      End If;
    END IF;
      
    Exception
      When Others Then 
      DOPL('UNEXPECTED EXCEPTION MARKING PART 2 TRANSFER ' || sqlerrm);
    END;
  if Vsectionmarks / 10 > vPassPercent then
  Dopl('PART 2 RESULT : PASS');
  vResultPart2 := true;
  else
  Dopl('PART 2 RESULT : FAIL');
  end if;
  
  Vtotalmarks := Vtotalmarks + Vsectionmarks; -- not really needed in portfolio version but left in in case need changes
  
  Vsectionmarks := 0;
  
  If Pdebug Then Dopl('TOTAL MARKS AFTER PART 2: '|| Vtotalmarks); End If;
  If Pdebug Then Dopl('SECTION MARKS RESET AFTER PART 2: '|| VSECTIONmarks); End If;
  if pdebug then dopl(' '); END IF;


  -------------------
  -------------------
  --  start part 3
  -------------------
  -------------------


  Dopl(' ');
  
  If Pdebug Then Dopl('MARK THE FILTERS'); End If;
  if pdebug then dopl(' '); END IF;
  
  -- filter 4 correct answer
  Select count(*) into vCorrectInteger From A2custbris 
  Where Custcatcode Not In (Select Custcatcode From A2custcategory)
  OR CUSTCATCODE IS NULL;
  
  --Mark Filter 4
  A2M_Mark_Filter(4, vCorrectInteger, 2, Vsectionmarks, user, PDEBUG);
  
  -- filter 5 correct answer
  Select count(*) into vCorrectInteger From A2custbris 
  Where (Phone Like '%-%' Or Phone Like '% %')
  AND length(replace(replace(Phone, '-', ''), ' ' , '')) = 10;
  
   --Mark Filter 5
  A2M_Mark_Filter(5, vCorrectInteger, 2, Vsectionmarks, user, PDEBUG);
  
  -- filter 6 correct answer
  Select count(*) into vCorrectInteger From A2custbris 
  Where length(replace(replace(Phone, '-', ''), ' ' , '')) <> 10;
  
  --Mark Filter 6
  A2M_Mark_Filter(6, vCorrectInteger, 2, Vsectionmarks, user, PDEBUG);
  
  -- filter 7 correct answer
  --Select count(*) into vCorrectInteger From A2product 
	--Where prodNAME is null;
  
  Select count(*) into vCorrectInteger From A2custbris 
  Where Upper(Gender) Not In ('M', 'F')
  OR GENDER IS NULL;
  
    --Mark Filter 7
  A2M_Mark_Filter(7, vCorrectInteger, 2, Vsectionmarks, user, PDEBUG);
  
  
  If Pdebug Then Dopl(' '); End If;
  If Pdebug Then Dopl('MARK THE DATA TRANSFER'); End If;
  if pdebug then dopl(' '); END IF;
  
    -- MARK THE PART 3 DATA TRANSFER
  Declare
    VINITIALCHECK INTEGER;
    VSOURCE INTEGER;
    Vactual Integer;
    Vexcluded Integer;
    Valtered Integer;
    Vtomodify Integer;
    
  Begin
  
    -- CHECK IF DWCUST CREATED    
      VQUERY := 'Select Count(*)
                 From ' || PUSER || '.A2M_Not_Attempted
                 WHERE DB_OBJECT_NAME = ''DWCUST''';
    
    EXECUTE IMMEDIATE VQUERY INTO Vinteger;
    
    
    if pdebug then dopl('DEBUG - NUM DWCUST IN A2M_NOT_ATTEMPTED:  ' || VINTEGER); END IF;
    
    -- MAKE SURE THAT AT LEAST ONE OF THE FILTERS IN THIS SECTION
    -- HAS AN ENTRY IN THE ERROR EVET TABLE
    
      VQUERY := 'Select Count(*)
                 From ' || PUSER || '.A2errorevent 
                 Where Filterid In (4,5,6,7)
                 AND FILTERID IS NOT NULL';
    
      EXECUTE IMMEDIATE VQUERY INTO Vinitialcheck;
    

    If Pdebug Then Dopl('DEBUG - NUM ROWS IN ERROR EVENT FOR PART 3: ' || ViNITIALCHECK); End If;
        
    
    -- IF THE TABLE WASN'T CREATED 0 MARKS FOR INSERTION PARTS
    If Vinteger  > 0 Then
      Dopl('DWCUST TABLE NOT CREATED CORRECTLY');
      vResultPart1 := false;
    Elsif Vinitialcheck = 0 Then
      Dopl('NO FILTER ENTRIES FOR PART 3 FILTERS - TRANSFER CANNOT BE GRADED');
    Else
      
      -- FILTER 6 WAS SKIP, 4, 5 AND 7 WERE MODIFY
      -- # IN DWCUST (BRISBANE SOURCE ID)  = # IN A2CUSTBRIS - # FILTER 6 FAILS
      
      -- get total number of rows in source table
      Select Count(*) Into Vsource FROM A2CUSTBRIS;
      
      -- get total number of rows in dwtable which claim to be from brisbane    
      VQUERY := 'Select Count(*)
                 From ' || PUSER || '.DWCUST 
                 Where Dwsourceidbris Is Not Null';
    
      EXECUTE IMMEDIATE VQUERY INTO Vactual;
      
      
      -- find out how many should have been excluded based on filter 6
      VQUERY := 'Select Count(*)
                 From ' || PUSER || '.A2errorevent 
                 Where Filterid = 6 AND FILTERID IS NOT NULL';
    
      EXECUTE IMMEDIATE VQUERY INTO Vexcluded;      
      
            
      if pdebug then dopl('DEBUG - TRANSFER SUMMARY - SOURCE: ' ||  VSOURCE ||
                                                    ' = DW: ' || Vactual ||
                                                    ' + EE SKIPS : ' || VEXCLUDED ); END IF;      
            
            
      -- FILTER 7 IS MARKED SPERATELY
      -- find out how many should have been modified based on filter 7
      VQUERY := 'Select Count(*)
                 From ' || PUSER || '.A2errorevent 
                 Where Filterid In (4,5) And Filterid Is Not Null';
    
      EXECUTE IMMEDIATE VQUERY INTO Vtomodify;         
    

    -- find out how many entries from brisbane in dw with correct modifications based on filters 4 and 5
    
    
      --Select Count(*) Into Valtered From Dwcust
      --Where 
      -- FILTER 4 IS CORRECTED
      --(Dwsourceidbris Is Not Null And Upper(Custcatname) = 'UNKNOWN' And Custcatname Is Not Null)
      --Or
      -- FILTER 5 IS CORRECTED
      --(Dwsourceidbris Is Not Null And Dwsourceidbris In 
       --     (Select Custid From A2custbris Where Phone Like '%-%' Or Phone Like '% %')
      -- And Phone Not Like '%-%'And Phone Not Like '% %');
     
      
      VQUERY := 'Select Count(*)
                 From ' || PUSER || '.Dwcust 
                 Where 
                (Dwsourceidbris Is Not Null And Upper(Custcatname) = ''UNKNOWN'' And Custcatname Is Not Null)
                Or
                (Dwsourceidbris Is Not Null And Dwsourceidbris In 
                (Select Custid From A2custbris Where Phone Like ''%-%'' Or Phone Like ''% %'')
                And Phone Not Like ''%-%'' And Phone Not Like ''% %'')';     
    
      EXECUTE IMMEDIATE VQUERY INTO Valtered; 
      
      If Pdebug Then Dopl('DEBUG - MODIfY (F4/5) SUMMARY - TO MODIFY: ' || Vtomodify || 
                                                  ' = MODIFIED: ' || VALTERED); END IF;  
      -- if # in source table = # in dw + # excluded
      -- and # modified = # that should be modified then all correct
      If Vsource = (Vactual + Vexcluded) And Vtomodify = Valtered and vAltered > 0 Then
        Vsectionmarks := Vsectionmarks + 5;
      
      -- if # in source table = # in dw + # excluded - only  exclusions done correctly
      Elsif Vsource = (Vactual + Vexcluded) Then
        Dopl('MODIFICATIONS (F4/5) NOT DONE CORRECTLY');
        Vsectionmarks := Vsectionmarks + 3;
        
      -- and # modified = # that should be modified - only modifications done correctly
      Elsif Vtomodify = Valtered and vAltered > 0 Then
        Dopl('INCORRECT NUMBER OF ROWS TRANSFERRED');
        Vsectionmarks := Vsectionmarks + 2;
      ELSE
        -- TRANSFER DOESN'T ADD UP
        Dopl('INNCORRECT NUMBER OF ROWS TRANSFERRED AND PROBLEMS IN (F4/5) MODIFICATIONS');
      End If;
    END IF;
  
    
      -- WORK OUT THE FILTER 7 MARKS
 
      -- get the number of filter 7 fails      
      VQUERY := 'Select Count(*)
                 From ' || PUSER || '.A2errorevent 
                 Where Filterid = 7 And Filterid Is Not Null';
    
      EXECUTE IMMEDIATE VQUERY INTO Vtomodify;         
    
      
      -- get a count of customers who have had their gender correctly updated
      VQUERY := 'Select Count(*)
                 From ' || PUSER || '.Dwcust
                       Where Dwsourceidbris Is Not Null
                       And Dwsourceidbris In (Select Custid From A2custbris Where Upper(Gender) Not In (''M'', ''F'') Or Gender Is Null)    
                       And GENDER IN (''M'', ''F'', ''U'')';
    
      EXECUTE IMMEDIATE VQUERY INTO Valtered; 
       
       
      If Pdebug Then Dopl('DEBUG - MODIfY (F7) SUMMARY - TO MODIFY: ' || Vtomodify || 
                                                  ' = MODIFIED: ' || VALTERED); END IF;  

      If Vtomodify = Valtered and vAltered > 0 Then
        -- IT ALL ADDS UP
        Vsectionmarks := Vsectionmarks + 2;
      Else
        -- TRANSFER DOESN'T ADD UP
        Dopl('MODIFICATIONS (F7) NOT DONE CORRECTLY');
      End If;
      
    Exception
      When Others Then 
      Dopl('UNEXPECTED EXCEPTION MARKING PART 3 TRANSFER : ' || SQLERRM);
    END;
    dopl(' ');
    if Vsectionmarks / 15 > vPassPercent then
      dopl('PART 3 RESULT : PASS');
      vResultPart3 := true;
    else
      Dopl('PART 3 RESULT : FAIL');
    end if;
    
    
    
    
    
    Vtotalmarks := Vtotalmarks + Vsectionmarks; -- not needed but left for future use if model changes
    Vsectionmarks := 0;
  
    If Pdebug Then Dopl('TOTAL MARKS AFTER PART 3: '|| Vtotalmarks); End If;
    If Pdebug Then Dopl('SECTION MARKS RESET AFTER PART 3: '|| Vsectionmarks); End If;
    if pdebug then dopl(' '); END IF;
  
  -------------------
  -------------------
  --  start part 4
  -------------------
  -------------------
  
    dopl(' '); 
    
    If Pdebug Then Dopl(' '); End If;
    If Pdebug Then Dopl('MARK THE DATA TRANSFER'); End If;
    if pdebug then dopl(' '); END IF;
  
    -- MARK THE PART 4 DATA TRANSFER
    
    Declare
      Vsourcetotal Integer; -- NUMBER IN DWCUSTMENB
      Vdwtotal Integer; -- NUMBER OF ROWS IN DW WITH DWSOURCEIDMELB
      
      Vdwduplicate Integer; -- NUMBER OF DUPLIACTE ROWS (HAS BOTH DWSOURCEIDBRIS AND DWSOURCEIDMELB) IN DW
      VSOURCEDUPLICATE Integer; -- NUMBER OF DUPLICATES WHEN COMPARING A2CUSTMELB AND DWCUST ROWS WITH A DWSOURCEIDBRIS
    Begin
      -- CHECK IF DWCUST CREATED    
      VQUERY := 'Select Count(*)
                 From ' || PUSER || '.A2M_Not_Attempted 
                 WHERE DB_OBJECT_NAME = ''DWCUST''';
    
      EXECUTE IMMEDIATE VQUERY INTO Vinteger;  
    
    
      If Pdebug Then Dopl('DEBUG - NUM ENTRIES IN A2M_NOT_ATTEMPTED WITH OBJECT NAME DWCUST: ' || Vinteger); End If;

        -- IF THE TABLE WASN'T CREATED 0 MARKS FOR INSERTION PARTS
      If Vinteger  > 0 Then
        Dopl('DWCUST TABLE NOT CREATED CORRECTLY');
        vResultPart1 := false;
      Else
        
        -- CORRECT NUMBER ROWS IN DW WITH DWCUSTIDMELB (IE FROM A2CUSTMELB) 
          
        -- find out how many rows in source table
        SELECT COUNT(*) INTO VSOURCETOTAL FROM A2CUSTMELB;
      
        -- find out how many melbourne related rows in dw        
        VQUERY := 'Select Count(*)
                 From ' || PUSER || '.Dwcust
                 WHERE DWSOURCEIDMELB IS NOT NULL';
    
        EXECUTE IMMEDIATE VQUERY INTO Vdwtotal;  
        
        
        
        If Pdebug Then Dopl('DEBUG - MERGE TOTAL - SOURCE TABLE ROWS: ' || VSOURCETOTAL || ' =  ROWS IN DWCUST WITH MELB ID: '|| Vdwtotal); End If;   
      
        -- if they are the same then it is done correctly
        -- duplicates that match brisbane have an entry in each of melbcustid and briscustid
        If Vsourcetotal = Vdwtotal Then
          Vsectionmarks := Vsectionmarks + 10;
        Else
          Dopl('INCORRECT NUMBER OF A2CUSTMELB ROWS TRANSFERRED TO DWCUST');
        End If;
      
      
      
        -- find out how many customers SHOULD HAVE BOTH DWSOURCEIDMELB AND DWSOURCEIDBRIS
        vQuery := 'Select Count(*) From A2custmelb WHERE FNAME||SNAME||POSTCODE IN (
                      SELECT FIRSTNAME||SURNAME || POSTCODE FROM ' || PUSER || '.DWCUST WHERE DWSOURCEIDBRIS IS NOT NULL)';
        
        EXECUTE IMMEDIATE VQUERY INTO VSOURCEduplicate ;
        
        -- find out how many actually have both in dw
        VQUERY := 'Select Count(*)
                 From ' || PUSER || '.Dwcust
                 where Dwsourceidbris Is Not Null AND DWSOURCEIDMELB IS NOT NULL';
    
        EXECUTE IMMEDIATE VQUERY INTO Vdwduplicate ;  
  

        If Pdebug Then Dopl('DEBUG - MERGE DUPLICATES - ACTUAL DUPLICATES: ' || VSOURCEduplicate || ' DUPES IN ATTEMPT: ' || VDWDUPLICATE); End If;  
       
       -- if they are equal then it is correct
        If Vsourceduplicate = Vdwduplicate and Vdwduplicate > 0 Then
          Vsectionmarks := Vsectionmarks + 5;
        Else
          Dopl('ROWS WITH DUPLICATE FNAME, SNAME AND POSTCODE NOT MERGED CORRECTLY; -5 MARKS');
        End If;
      
      END IF;

      
    Exception
      When Others Then 
      Dopl('UNEXPECTED EXCEPTION MARKING PART 4 TRANSFER : ' || Sqlerrm);
    END;
    
    dopl(' ');  
    
    if Vsectionmarks / 15 > vPassPercent then
      dopl('PART 4 RESULT : PASS');
      vResultPart4 := true;
    else
      Dopl('PART 4 RESULT : FAIL');
    end if;
      
   
  -------------------
  -------------------
  --  start part 5
  -------------------
  -------------------

    Vtotalmarks := Vtotalmarks + Vsectionmarks;
    Vsectionmarks := 0;
  
    If Pdebug Then Dopl('TOTAL MARKS AFTER PART 4: '|| Vtotalmarks); End If;
    If Pdebug Then Dopl('SECTION MARKS RESET AFTER PART 4: '|| Vsectionmarks); End If;
    if pdebug then dopl(' '); END IF;  

    dopl(' ');
  
  If Pdebug Then Dopl('MARK THE FILTERS'); End If;
  if pdebug then dopl(' '); END IF;
  
  begin
    -- get the number of filter 8 fails
    VQUERY := 'Select Count(*)
                From A2salebris A2sb
                Where A2sb.Prodid Not In (Select Dwsourceid FROM ' || PUSER || '.Dwprod WHERE DWSOURCEID IS NOT NULL)
                OR A2SB.PRODID IS NULL';
      
    EXECUTE IMMEDIATE VQUERY INTO vCorrectInteger; 
    

    --Mark Filter 8
    A2M_Mark_Filter(8, vCorrectInteger, 2, Vsectionmarks, user, PDEBUG);
  
    -- get the number of filter 9 fails 
    
    VQUERY := 'Select Count(*)
                From A2salebris A2sb
                Where A2sb.Custid Not In (Select Dwsourceidbris From  ' || PUSER || '.Dwcust Where Dwsourceidbris Is Not Null)
                Or A2sb.Custid Is Null';
      
    EXECUTE IMMEDIATE VQUERY INTO vCorrectInteger; 
    
    --Mark Filter 9
    A2M_Mark_Filter(9, vCorrectInteger, 2, Vsectionmarks, user, PDEBUG);
  
      -- get the number of filter 10 fails  
    Select count(*) into vCorrectInteger 
    From A2salebris A2sb
    Where A2sb.shipdate < a2sb.saledate;
  
    --Mark Filter 10
    A2M_Mark_Filter(10, vCorrectInteger, 2, Vsectionmarks, user, PDEBUG);
    
    -- get the number of filter 11 fails  	
    Select count(*) into vCorrectInteger
    From A2salebris A2sb
    Where A2sb.UNITPRICE IS NULL;
  
    --Mark Filter 11
    A2M_Mark_Filter(11, vCorrectInteger, 2, Vsectionmarks, user, PDEBUG);
  
  Exception 
    When Others Then
    Raise;
  End;
  
  If Pdebug Then Dopl(' '); End If;
  If Pdebug Then Dopl('MARK THE DATA TRANSFER'); End If;
  if pdebug then dopl(' '); END IF;
  
  
  
    -- MARK THE PART 5 DATA TRANSFER
  Declare
    VINITIALCHECK INTEGER;
    VSOURCE INTEGER;
    Vactual Integer;
    Vexcluded Integer;
    Valtered Integer;
    Vtomodify Integer;
    
  Begin
  
    -- CHECK IF DWSALE CREATED    
    VQUERY := 'Select Count(*)
                 From ' || PUSER || '.A2M_Not_Attempted 
                 WHERE DB_OBJECT_NAME = ''DWSALE''';
    
    EXECUTE IMMEDIATE VQUERY INTO Vinteger;  
    
    if pdebug then dopl('DEBUG - NUM ENTRIES IN A2M_NOT_ATTEMPTED WITH OBJECT NAME DWSALE: ' || VINTEGER); END IF;
    
    -- MAKE SURE THAT AT LEAST ONE OF THE FILTERS IN THIS SECTION
    -- HAS AN ENTRY IN THE ERROR EVET TABLE    
        VQUERY := 'Select Count(*)
                  From ' || PUSER || '.A2errorevent
                  Where Filterid In (8,9,10,11)
                  AND FILTERID IS NOT NULL';
    
    EXECUTE IMMEDIATE VQUERY INTO Vinitialcheck;
    
    

    -- IF THE TABLE WASN'T CREATED 0 MARKS FOR INSERTION PARTS
    If Vinteger  > 0 Then
      Dopl('DWSALE TABLE NOT CREATED CORRECTLY');
      vResultPart1 := false;
    Elsif Vinitialcheck = 0 Then
      Dopl('NO FILTER ENTRIES FOR PART 5 FILTERS - TRANSFER CANNOT BE GRADED');
    Else
      
      -- FILTER 8 AND 9 ARE SKIP, 10 AND 11 ARE MODIFY
      -- # IN DWSALE (BRISBANE SOURCE ID)  = # IN A2SALEBRIS - # FILTER 8 AND 9 FAILS
      
      -- find out the number in the surce table
      Select Count(*) Into Vsource FROM A2SALEBRIS;

      -- find out the number in the dw table
      VQUERY := 'Select Count(*)
                  From ' || PUSER || '.DwSALE
                  Where Dwsourceidbris Is Not Null';
    
      EXECUTE IMMEDIATE VQUERY INTO Vactual;

       -- find out how many should have been excluded based in filter 8 and 9     
      VQUERY := 'Select Count(*)
                  From ' || PUSER || '.A2errorevent
                  Where Filterid IN (8, 9) AND FILTERID IS NOT NULL';
    
      EXECUTE IMMEDIATE VQUERY INTO Vexcluded;

      if pdebug then dopl('DEBUG - TRANSFER SUMMARY - SOURCE: ' ||  VSOURCE ||
                                                    ' = DW: ' || Vactual ||
                                                    ' + EE SKIPS : ' || VEXCLUDED ); END IF;   
    
      -- if the # in the source - # in dw + # ecluded the transfer correct
      If Vsource = (Vactual + Vexcluded) then

        -- IT ALL ADDS UP
        Vsectionmarks := Vsectionmarks + 9;
      Else
        -- TRANSFER DOESN'T ADD UP
        Dopl('INCORRECT NUMBER OF ROWS TRANSFERRED');
      End If;
    
      -- get the number that should be modified based on filter 10
      VQUERY := 'Select Count(*)
                  From ' || PUSER || '.A2errorevent
                  Where Filterid In (10) And Filterid Is Not Null';
    
      EXECUTE IMMEDIATE VQUERY INTO Vtomodify;
      
      -- get the numbert that actually were modified        
      VQUERY := 'Select Count(*)
                  From ' || PUSER || '.DwSALE DS
                  WHERE 
                  Ds.Dwsourceidbris In (Select Saleid From A2salebris Where Shipdate < Saledate Or Saledate Is Null)
                  And Ds. Dwsourceidbris Is Not Null 
                  And Ds. Ship_Dwdateid = Ds.Sale_Dwdateid + 2 
                  And Ds.Ship_Dwdateid Is Not Null 
                  AND DS.SALE_Dwdateid Is Not Null';
    
      EXECUTE IMMEDIATE VQUERY INTO Valtered;

      If Pdebug Then Dopl('DEBUG - MODIfY (F10) SUMMARY - TO MODIFY: ' || Vtomodify || 
                                                  ' = MODIFIED: ' || VALTERED); END IF; 
      -- if they match modifications are correct
      If Vtomodify = Valtered and Valtered > 0 Then

        -- IT ALL ADDS UP
        Vsectionmarks := Vsectionmarks + 4;
      Else
        -- TRANSFER DOESN'T ADD UP
        Dopl('MODIFICATIONS (F10) NOT DONE CORRECTLY');
      End If;
            
      -- get the number to be modified based on filter 11
      
      VQUERY := 'Select Count(*)
                  From ' || PUSER || '.A2errorevent
                  Where Filterid In (11) And Filterid Is Not Null';
    
      EXECUTE IMMEDIATE VQUERY INTO Vtomodify;
      
      -- get the actual number modified correctly in dw  
        
      VQUERY := 'Select Count(*)
                  From ' || PUSER || '.DwSALE DS
                  Where 
                  Ds.Dwsourceidbris In (Select Saleid From A2salebris Where Unitprice Is Null)
                  And Ds.Dwsourceidbris Is Not Null
                  AND DS.SALEPRICE = (SELECT MAX(UNITPRICE) 
                                      FROM A2SALEBRIS WHERE PRODID = (
                                                                      SELECT DWSOURCEID 
                                                                      FROM ' || PUSER || '.DWPROD 
                                                                      WHERE DWPRODID = ds.dwprodid))';
    
      EXECUTE IMMEDIATE VQUERY INTO Valtered;        
        
      If Pdebug Then Dopl('DEBUG - MODIfY (F11) SUMMARY - TO MODIFY: ' || Vtomodify || 
                                                  ' = MODIFIED: ' || VALTERED); END IF; 
    
      -- if the match modifications were correct
      If Vtomodify = Valtered and Valtered > 0 Then

        -- IT ALL ADDS UP
        Vsectionmarks := Vsectionmarks + 4;
      Else
        -- TRANSFER DOESN'T ADD UP
        Dopl('MODIFICATIONS (F11) NOT DONE CORRECTLY');
      End If;
            
    
    END IF;
      
    Exception
      When Others Then 
      Dopl('UNEXPECTED EXCEPTION MARKING PART 5 TRANSFER : ' || SQLERRM);
    END;
    dopl(' ');
    if Vsectionmarks / 25 > vPassPercent then
      dopl('PART 5 RESULT : PASS');
      vResultPart5 := true;
    else
      Dopl('PART 5 RESULT : FAIL');
    end if;

 
    Vtotalmarks := Vtotalmarks + Vsectionmarks; -- not needed but left for future use
    Vsectionmarks := 0;
  
    If Pdebug Then Dopl('TOTAL MARKS AFTER PART 5: '|| Vtotalmarks); End If;
    If Pdebug Then Dopl('SECTION MARKS RESET AFTER PART 5: '|| Vsectionmarks); End If;
    if pdebug then dopl(' '); END IF;  
  
  
    -------------------
  -------------------
  --  start part 6
  -------------------
  -------------------
  
 -- ######################## 
 -- ########################   
  -- ########################  
   -- ######################## 
 -- ########################   
  -- ########################  
   -- ######################## 
 -- ########################   
  -- ########################  
   -- ######################## 
 -- ########################   
  -- ########################  
  

    dopl(' ');
  
  If Pdebug Then Dopl('MARK THE FILTERS'); End If;
  if pdebug then dopl(' '); END IF;
  
  If Pdebug Then Dopl('NO MARKS ASSIGNED TO PART 6 FILTERING - ERROR EVENT ENTRIES AS THE LOGIC SHOULD DUPLICATE PART 5 LOGIC'); End If;
  
  begin
    -- get the number of filter 12 fails  
    VQUERY := 'Select count(*)
              From A2salemelb A2sb
              Where A2sb.Prodid Not In (Select Dwsourceid From ' || PUSER || '.Dwprod where dwsourceid is not null)
              Or A2sb.Prodid Is Null';
    
    EXECUTE IMMEDIATE VQUERY INTO vCorrectInteger;
    
    
    --Mark Filter 12
    A2M_Mark_Filter(12, vCorrectInteger, 0, Vsectionmarks, user, PDEBUG);
  
    -- get the number of filter 13 fails  
  
    VQUERY := 'Select count(*)
              From A2salemelb A2sb
              Where A2sb.Custid Not In (Select Dwsourceidmelb From ' || PUSER || '. Dwcust Where Dwsourceidmelb Is Not Null)
              Or A2sb.Custid Is Null';
    
    EXECUTE IMMEDIATE VQUERY INTO vCorrectInteger;
  
  
    --Mark Filter 13
    A2M_Mark_Filter(13, vCorrectInteger, 0, Vsectionmarks, user, PDEBUG);
  
    -- get the number of filter 14 fails   
    Select count(*) into vCorrectInteger
    From A2salemelb A2sb
    Where A2sb.shipdate < a2sb.saledate;
  
    --Mark Filter 14
    A2M_Mark_Filter(14, vCorrectInteger, 0, Vsectionmarks, user, PDEBUG);
  
    -- get the number of filter 15 fails 
    Select count(*) into vCorrectInteger 
    From A2salemelb A2sb
    Where A2sb.UNITPRICE IS NULL;
  
    --Mark Filter 15
    A2M_Mark_Filter(15, vCorrectInteger, 0, Vsectionmarks, user, PDEBUG);
  
  Exception
    When Others Then
    raise;
  end;
  
    -- ########################  
   -- ######################## 
 -- ########################   
  -- ########################  
   -- ######################## 
 -- ########################   
  -- ########################  
  
  
  
  
    If Pdebug Then Dopl(' '); End If;
    If Pdebug Then Dopl('MARK THE DATA TRANSFER (PART 6 AND 7 MARKED CONCURRENTLY'); End If;
    if pdebug then dopl(' '); END IF;
  
  -- MARK THE PART 6 DATA TRANSFER
  Declare
    Vinitialcheck1 Integer; -- NUMBER OF SINGLE FILTER ENTRYS IN ERROR EVENT FOR PART 6 FILTERS
    Vnum_multi_fails Integer; -- NUMBER OF MULTIPLE FILTER ENTRYS IN ERROR EVENT FOR PART 6 FILTERS
    Vclean Integer; -- NUM CLEAN ENTIRES IN 
    Vactual Integer; -- NUM ROS IN DWSALW WITH SOURCE MELB ID
    Vsingle Integer; -- NUMBER OF SINGLE FILTER FAILS (F14/15) WHICH SHOULD BE INSERTED
    VMULTIPLE INTEGER; -- NUMBER OF MULTIPLE FILTER FAIL INSERTS THAT SHOULD GO INTO DWSALE IF PART 7 NOT COMPLETE.
    
    Vcorrectforp6 Boolean; -- TRUE IF NUMBERS ARE CORRECT FOR PART 6
    VCORRECTFORP7 BOOLEAN;  -- TRUE IF NUMBERS ARE CORRECT FOR PART 7
    
    Ecrosscheck EXCEPTION;
  Begin
  
    -- CHECK IF DWSALE CREATED
    VQUERY := 'Select Count(*)
                 From ' || PUSER || '.A2M_Not_Attempted 
                 WHERE DB_OBJECT_NAME = ''DWSALE''';
    
    EXECUTE IMMEDIATE VQUERY INTO Vinteger;
    
    
    if pdebug then dopl('DEBUG - NUM ENTRIES IN A2M_NOT_ATTEMPTED WITH OBJECT NAME DWSALE: ' || VINTEGER); END IF;
    
    
    -- MAKE SURE THAT AT LEAST ONE OF THE FILTERS IN THIS SECTION
    -- HAS AN ENTRY IN THE ERROR EVET TABLE
    
    VQUERY := 'Select Count(*)
                 From ' || PUSER || '.A2errorevent
                 Where Filterid In (12,13,14,15)
                 AND FILTERID IS NOT NULL';
    
    EXECUTE IMMEDIATE VQUERY INTO Vinitialcheck1;
    
    -- GET THE NUMBER OF MULIPLE FAILS IN ERROR EVENT TABLE    
    VQUERY := 'Select Count(*)
              FROM (
                    Select Source_Rowid From ' || PUSER || '.A2errorevent
                    Where Filterid In (12,13,14,15)
                    and filterid is not null
                    Group By Source_Rowid
                    Having Count(*) > 1
                )';
    
    EXECUTE IMMEDIATE VQUERY INTO Vnum_multi_fails;
    
         
    -- IF THE TABLE WASN'T CREATED 0 MARKS FOR INSERTION PARTS
    If Vinteger  > 0 Then
      Dopl('DWSALE TABLE NOT CREATED CORRECTLY');
      vResultPart1 := false;
    Elsif Vinitialcheck1 = 0 Then
      Dopl('NO FILTER ENTRIES FOR PART 6 FILTERS - TRANSFER CANNOT BE GRADED FOR EITHER PART 6 OR PART 7: -25 MARKS');
    Else
    
    
 -- ########################   
  -- ######################## 
   -- ########################   
  -- ######################## 
      
      -- to calculate if is correct FOR PART 6
      
      -- Part 6 AL-GOR-ITHM 8)
      
      -- TOTAL DWSALE WITH MELB ID = NUM CLEAN ENTRIES IN A2SALEMELB (IE NOT IN ERROR EVENT )
      --                            + SINGLE FILTER FAILS FOR F14/15 WHICH SHOULD BE INSERTED
      --                            + number of f14/15 inserts WHICH ARE BASED ON multple fails AND WILL BE INSERTED
      
      
      -- to calculate if is correct FOR PART 7
      
      -- Part 7 AL-GOR-ITHM 8)
      
      -- TOTAL DWSALE WITH MELB ID = NUM CLEAN ENTRIES IN A2SALEMELB (IE NOT IN ERROR EVENT )
      --                            + SINGLE FILTER FAILS FOR F14/15 WHICH SHOULD BE INSERTED
      --     
        
        
      -- get data to calculate corrrct answers
      
      -- NUM CLEAN ENTRIES IN A2ALEMELB
      VQUERY := 'Select Count(*) From A2salemelb WHERE ROWID NOT IN (SELECT SOURCE_ROWID FROM ' || PUSER || '.A2ERROREVENT)';
    
      EXECUTE IMMEDIATE VQUERY INTO VCLEAN;
      
      
      
      -- TOTAL ENTRIES IN DWSALE WITH DWSOUREIDMELB NOT NULL      
      VQUERY := 'Select Count(*) From ' || PUSER || '.Dwsale Where DwSOURCEidmelb Is Not Null';
    
      EXECUTE IMMEDIATE VQUERY INTO Vactual;
        
      -- NUMBER SINGLE FILTER FAILS FOR F14/15 WHICH SHOULD BE INSERTED (AND MODIFIED) 

         -- lists rowid and filterID of all rows IN A2ERROREVENT WHICH HAVE OTHER ROWS IN A2ERROREVENT REFERENCING SAME ROWID IE. MULTIPLE FILTER FAILS
      VQUERY := '      Select Count(*)
                      From
                      ( 
                          Select source_rowid, Filterid
                          From ' || PUSER || '.A2errorevent
                          Where 
                                Filterid In (14,15)
                                And Source_Rowid NOT In
                                  (
                                    Select Source_Rowid From ' || PUSER || '.A2errorevent
                                    Where Filterid In (12,13,14,15)
                                    Group By Source_Rowid
                                    Having Count(*) > 1
                                  )
                      )';
    
      EXECUTE IMMEDIATE VQUERY INTO VSINGLE;
      
      -- gets count of all rows that will get inserted if muitiple filter fails not being properly removed
      -- IE ISOLATES MULTIPLE FILTER FAILS TO THOSE WHICH WILL GET INESERTED (F14/15)
  
      
      VQUERY := 'Select Count(*) From
                    ( 
                      Select source_rowid, Filterid
                      From ' || PUSER || '.A2errorevent
                      Where Filterid In (12,13,14,15)
                      And Source_Rowid In
                      (
                        Select Source_Rowid From ' || PUSER || '.A2errorevent
                        Where Filterid In (12,13,14,15)
                        Group By Source_Rowid
                        Having Count(*) > 1
                      )
                    )
                where filterid in (14,15)';
    
      EXECUTE IMMEDIATE VQUERY INTO VMULTIPLE;
 
      
 
      If Pdebug Then Dopl('DEBUG - PART 6:  NUM IN DWSALE WITH MELB ID: ' || Vactual ||
                                            ' = CLEAN A2ALEMELB ENTIRES: ' || Vclean || 
                                            ' + SINGLE FILTER MODIFIES FOR F14/15: ' || Vsingle ||
                                            ' + MULTIPLE FILTER MODIFIES FOR F14/15: ' || VMULTIPLE); End If;    
      
      
      If Pdebug Then Dopl('DEBUG - PART 7: ROWS IN DWSALE: ' || Vactual || ' = CLEAN ROWS IN A2SALEMELB: ' || Vclean || ' + SINGLE FILTER FAIL MODIFIES: ' || Vsingle); End If;
        
      -- set the part 6 / art 7 correct variables  
        
      If VACTUAL = VCLEAN + VSINGLE + VMULTIPLE Then
        Vcorrectforp6 := True; 
      Else
        Vcorrectforp6 := False;
      END IF;
      
      If VACTUAL = VCLEAN + VSINGLE Then
        Vcorrectforp7 := True; 
      Else
        Vcorrectforp7 := False;
      END IF;
 
      -- main script for marking / output
 
      -- number correct for part 7
      If Vcorrectforp7 Then
        If Vnum_Multi_Fails > 0 Then
          -- solved without altering error event table
          Vsectionmarks := Vsectionmarks + 25;
        Else
          -- solved by altering error event table
          Vsectionmarks := Vsectionmarks + 20;
          Dopl('ALTERATION OF A2ERROREVENT TO SOLVE PART 7 -5 MARKS');
          DOPL('CODE INSPECTION REQUIRED TO CONFIRM ALTERATION OF A2ERROREVENT');
        End If;
      Elsif Vcorrectforp6 Then
        
          dopl('PART 7 TRANSFER NOT CORRECT - MULTIPLE FILTER FAIL ROWS TRANSFERED');
          Vsectionmarks := Vsectionmarks + 5;
          If Pdebug Then Dopl('VSECTIONMARKS + 5 -> NEW TOTAL:' || Vsectionmarks); End If;          
      Else
          Dopl('NEITHER PART 6 OR PART 7 TRANSFER CORRECT');
      End If;
  
    END IF;
      
  Exception
    When Others Then 
      Dopl('UNEXPECTED EXCEPTION MARKING PART 6/7 : ' || SQLERRM);
  END;
  dopl(' ');
  if Vsectionmarks / 25 > vPassPercent then
      dopl('PART 6 and 7 RESULT : PASS');
      vResultPart6 := true;
      vResultPart7 := TRUE;
  else
      Dopl('PART 6 and 7 RESULT : FAIL');
  end if;
    
  dopl(' ');
  Vtotalmarks := Vtotalmarks + Vsectionmarks;
  --Dopl('TOTAL (EXCLUDING PART 8 - 10 MARKS) : ' || VTOTalmarks || ' / 90');
  Vsectionmarks := 0;
  
    If Pdebug Then Dopl('TOTAL MARKS AFTER PART 6 AND 7: '|| Vtotalmarks); End If;
    If Pdebug Then Dopl('SECTION MARKS RESET AFTER PART 7: '|| Vsectionmarks); End If;
    if pdebug then dopl(' '); END IF;  

    dopl('');
    
    dopl('');
    IF vResultPart1 AND vResultPart2 AND vResultPart3 THEN
      dopl('PASS TASKS: SATISFACTORY');
    ELSE
      dopl('PASS TASKS: NOT YET SATISFACTORY');
    END IF;
    dopl('');
    
    IF vResultPart4 AND vResultPart5 THEN
      dopl('CREDIT TASKS: SATISFACTORY');
    ELSE
      dopl('CREDIT TASKS: NOT YET SATISFACTORY');
    END IF;
    dopl('');
    IF vResultPart6 AND vResultPart7 THEN
      dopl('DISTINCTION TASKS: SATISFACTORY');
    ELSE
      dopl('DISTINCTION TASKS: NOT YET SATISFACTORY');
    END IF;
    dopl('');


Exception
  When Others Then
  DOPL('OUTMOST EXCEPTION - ' || SQLERRM); 
End;
/
SHOW ERRORS;
