-- ensure ass2 related db objects exist so A2M_Mark_filter function compiles
--execute A2M_pkg_assignment.premark_CHECK('DS Ass2', user, true);


Create Or Replace Procedure A2M_Mark_Filter( Pfilterid In Integer, 
                                            Presult In Integer, 
                                            Pmarks In Integer, 
                                            Pmarkcounter In Out Integer,
                                            pUser varchar2,
                                            PDEBUG IN BOOLEAN DEFAULT FALSE) AUTHID CURRENT_USER AS
    Vcount Integer;
    vQuery varchar2(1000);
    
  Begin
  
    vQuery := 'Select Count(*) From ' || USER || '.A2errorevent Where Filterid = ' || Pfilterid;
  
    EXECUTE IMMEDIATE vQuery INTO Vcount;
        
    If Pdebug Then Dopl('DEBUG - FILTER ' || PFILTERID || ' ACTUAL: '|| Vcount || ' = EXPECTED: ' || Presult); End If;
  
    If Vcount = Presult Then
       
        If Pdebug Then Dopl('DEBUG - START MARKS: ' || Pmarkcounter || ' + NEW MARKS: ' || PMARKS ); End If;
       
      Pmarkcounter := Pmarkcounter + PMARKS; 
    Else
      Dopl('FILTER ' || PFILTERID || ' HAS INCORRECT NUMBER OF ENTRIES IN ERROR EVENT TABLE');
    End If;
    
  Exception
    When Others Then
      Dopl('UNEXPECTED EXCEPTION FILTER ' || PFILTERid || ' : ' || SQLERRM);
  End;
/


