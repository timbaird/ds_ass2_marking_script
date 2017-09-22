clear screen;
Set Serveroutput On;

Begin
drop_if_exists('a2errorevent', true);
drop_if_exists('errorevent', true);
drop_if_exists('dwprod', true);
drop_if_exists('dwcust', true);
drop_if_exists('dwsale', true);
drop_if_exists('GENDERSPELLING', true);
drop_if_exists('Erroreventseq');
drop_if_exists('Dwprodseq');
drop_if_exists('Dwcustseq');
Drop_If_Exists('Dwsaleseq');
Drop_If_Exists('a2erroreventseq');
Drop_If_Exists('MULTIPLE_FILTER_FAILS');
end;
/

--Place all CREATE SEQUENCE statements below this line (separate each statement with a line containing / )

Create Sequence a2erroreventseq;
Create Sequence Dwprodseq;
Create Sequence Dwcustseq;
Create Sequence Dwsaleseq;

--Place all CREATE TABLE statements below this line  (separate each statement with a line containing / )
Create Table a2Errorevent(
  Errorid INTEGER,
  Source_Rowid Rowid,
  Source_Table Varchar2(30),
  Filterid Integer,
  Datetime Date,
  Action Varchar2(6),
  Constraint erroreventaction Check(Action In ('SKIP', 'MODIFY'))
);

Create Table Dwprod (
  Dwprodid Integer, 
  Dwsourcetable Varchar2(30), 
  Dwsourceid Number, 
  Prodname VARCHAR2(100) , 
  Prodcatname Varchar2(100), 
  Prodmanuname VARCHAR2(100),
  Prodshipname VARCHAR2(100)
);

Create Table Dwcust(
  Dwcustid Integer, 
  Dwsourceidbris Number(6), 
  Dwsourceidmelb Number(6) , 
  Firstname Varchar2(100),
  Surname Varchar2(100), 
  Gender Varchar2(50), 
  Phone Varchar2(50), 
  Postcode Varchar2(50), 
  City Varchar2(50), 
  State Varchar2(50), 
  CUSTCATNAME Varchar2(100)
);

Create Table Dwsale(
  Dwsaleid NUMBER(38), 
  dwcustid NUMBER(38),
  dwprodid NUMBER(38),
  dwsourceidbris NUMBER,
  dwsourceidmelb NUMBER,
  qty NUMBER,
  SALE_DWDATEID INTEGER,
  SHIP_DWDATEID INTEGER,
  saleprice NUMBER

);


Create Table Genderspelling(
  Invalidvalue Varchar2(20),
  NEWVALUE VARCHAR2(20)
);

Insert Into Genderspelling (Invalidvalue, Newvalue) Values('MAIL', 'F');
Insert Into Genderspelling (Invalidvalue, Newvalue) Values('WOMAN', 'F');
Insert Into Genderspelling (Invalidvalue, Newvalue) Values('FEM', 'F');
Insert Into Genderspelling (Invalidvalue, Newvalue) Values('FEMALE', 'F');
Insert Into Genderspelling (Invalidvalue, Newvalue) Values('MALE', 'M');
Insert Into Genderspelling (Invalidvalue, Newvalue) Values('GENTLEMAN', 'M');
Insert Into Genderspelling (Invalidvalue, Newvalue) Values('MM', 'M');
Insert Into Genderspelling (Invalidvalue, Newvalue) Values('FF', 'F');
Insert Into Genderspelling (Invalidvalue, Newvalue) VALUES('FEMAIL', 'F');

COMMIT;

-- TASK 2.1

-- FILTER 1 - NULL PRODUCT NAME
	Insert Into a2errorevent(Errorid, Source_Rowid, Source_Table, Filterid, Datetime, Action)
  Select a2erroreventseq.Nextval, Rowid, 'A2PRODUCT', 1, Sysdate, 'SKIP' From A2product 
	Where prodNAME is null;

-- TASK 2.2
-- FILTER 2 - NULL MANUFACTURER CODE
	Insert Into a2errorevent(Errorid, Source_Rowid, Source_Table, Filterid, Datetime, Action)
  Select a2erroreventseq.Nextval, Rowid, 'A2PRODUCT', 2, Sysdate, 'MODIFY' From A2product 
	Where MANUFACTURERCODE is null;
  
  
-- TASK 2.3  
-- FILTER 3 - identify incorrect product categorys and record in error event.
	Insert Into a2errorevent(Errorid, Source_Rowid, Source_Table, Filterid, Datetime, Action)
  Select A2erroreventseq.Nextval, Rowid, 'A2PRODUCT', 3, Sysdate, 'MODIFY' From A2product 
	Where Prodcategory Not In (Select Productcategory From A2prodcategory) OR PRODCATEGORY IS NULL;


-- TASK 2.4.3
-- TRANSFER GOOD PRODUCTS
-- upload those which do not have errors

Insert Into Dwprod (  
		    DWPRODID,
        DWSOURCETABLE, 
        Dwsourceid, 
        Prodname, 
        Prodcatname, 
        Prodshipname, 
        Prodmanuname)
select
    	Dwprodseq.Nextval,
    	'A2PRODUCT',
    	a2p.prodid,
    	A2p.Prodname, 
    	(Select Categoryname From A2prodcategory A2pc 
          		Where A2pc.Productcategory = A2p.Prodcategory), 
    	(Select description From A2shipping A2ps
          		Where A2ps.Shippingcode = A2p.Shippingcode), 
    	(Select Manuname From A2manufacturer A2pm
          		Where A2pm.Manucode = A2p.Manufacturercode)
		 
From A2product a2p 

-- a row should never get inserted as clean data if recorded under any filter
-- if it is in the error event table, so avoid putting a 'where filter = X ' clause 
-- on the clean data inserts.
Where Rowid || 'A2PRODUCT' Not In(Select Source_Rowid || SOURCE_TABLE From a2errorevent);


-- FILTER 1 ACTION IS SKIP SO NO INSERT REQUIRED

-- FILTER 2 TRANSFORMATION AND LOAD

INSERT INTO dwprod (  DWPRODID,
                  	  DWSOURCETABLE, 
                      Dwsourceid, 
                      Prodname, 
                      Prodcatname, 
                      Prodshipname, 
                      Prodmanuname)
select
    Dwprodseq.Nextval,
    'A2PRODUCT',
    a2p.prodid,
    A2p.Prodname, 
    (Select Categoryname From A2prodcategory A2pc 
          	 	Where A2pc.Productcategory = A2p.Prodcategory), 
    (Select description From A2shipping A2ps
          		Where A2ps.Shippingcode = A2p.Shippingcode), 
    'UNKNOWN'
    
From A2product A2p 

-- NO NEED TO SPECIFY TABLE AS FILTER 2 DOES THIS IMPLICITLY.
Where a2p.Rowid In(Select Source_RowiD From a2errorevent Where Filterid = 2);


-- FILTER 3 TRANSFORMATION AND LOAD

INSERT INTO dwprod (  DWPRODID,
                  	  DWSOURCETABLE, 
                      Dwsourceid, 
                      Prodname, 
                      Prodcatname, 
                      Prodshipname, 
                      Prodmanuname)
select
    Dwprodseq.Nextval,
    'A2PRODUCT',
    a2p.prodid,
    A2p.Prodname, 
    'UNKNOWN', 
    (Select description From A2shipping A2ps
          		Where A2ps.Shippingcode = A2p.Shippingcode), 
    (Select Manuname From A2manufacturer A2pm
          		Where A2pm.Manucode = A2p.Manufacturercode)
    
From A2product A2p 

-- NO NEED TO SPECIFY TABLE AS FILTER 3 DOES THIS IMPLICITLY.
Where A2p.Rowid In(Select Source_Rowid From a2errorevent Where Filterid = 3);



--FILTER 4
-- INVALID CUSTCATCODE ( MODIFY - USE 'UNKNOWN' )
Insert Into a2errorevent(Errorid, Source_Rowid, Source_Table, Filterid, Datetime, Action)
Select A2erroreventseq.Nextval, Rowid, 'A2CUSTBRIS', 4, Sysdate, 'MODIFY' From A2custbris 
Where Custcatcode Not In (Select Custcatcode From A2custcategory)
OR CUSTCATCODE IS NULL;

-- Filter 5
-- PHONE NUMBER HAS HYPHEN OR SPACE BUT NUMBER IS OTHERWISE VALID, (MODIFY - REMOVE HYPHEN OR SPACE)
Insert Into a2errorevent(Errorid, Source_Rowid, Source_Table, Filterid, Datetime, Action)
Select a2erroreventseq.Nextval, Rowid, 'A2CUSTBRIS', 5, Sysdate, 'MODIFY' From A2custbris 
Where (Phone Like '%-%' Or Phone Like '% %')
AND length(replace(replace(Phone, '-', ''), ' ' , '')) = 10;


-- Filter 6
-- PHONE NUMBER IS NOT 10 DIGITS LONG ONCE ANY SPACES OR HYPHENS REMOVED (SKIP)
Insert Into a2errorevent(Errorid, Source_Rowid, Source_Table, Filterid, Datetime, Action)
Select A2erroreventseq.Nextval, Rowid, 'A2CUSTBRIS', 6, Sysdate, 'SKIP' From A2custbris 
Where length(replace(replace(Phone, '-', ''), ' ' , '')) <> 10;


-- filter 7
-- GENDER IS NOT M OR F ( MODIFY: lookup value in genderspelling table)
-- spec says to treat lowercase values as uppercase

Insert Into a2errorevent(Errorid, Source_Rowid, Source_Table, Filterid, Datetime, Action)
Select a2erroreventseq.Nextval, Rowid, 'A2CUSTBRIS', 7, Sysdate, 'MODIFY' 
From A2custbris 
Where Upper(Gender) Not In ('M', 'F')
OR GENDER IS NULL;


-- insert customers who have passed ALL filters

Insert Into Dwcust (Dwcustid, 
					Dwsourceidbris, 
					Dwsourceidmelb, 
					Firstname,
					Surname, 
          Gender, 
					Phone, 
					Postcode, 
					City, 
					State, 
					Custcatname)
					
-- GENERATE THE RESULT SET TO INSERT  
Select 	Dwcustseq.Nextval, 
		CUSTId, 
		Null, 
		Fname, 
		Sname,
    	UPPER(Gender), 
		Phone,
		Postcode, 
		City, 
		State,
    	(Select Custcatname From A2custcategory Where Custcatcode = A2cb.CustcatCODE)
       
From A2custbris a2cb
-- ensure that only rows with no error_event records for any filter get inserted as clean.
where rowid || 'A2CUSTBRIS' not in(select source_rowid || SOURCE_TABLE from a2errorevent);


-- FILTER 4 TRANSFORMATION AND LOAD - CUSTCATAME SET TO UNKNOWN

Insert Into Dwcust (Dwcustid, 
					Dwsourceidbris, 
					Dwsourceidmelb, 
					Firstname,
					Surname, 
                    Gender, 
					Phone, 
					Postcode, 
					City, 
					State, 
					Custcatname)
-- GENERATE THE RESULT SET TO INSERT  
  
Select 	Dwcustseq.Nextval, 
		CUSTId, 
		Null, 
		Fname, 
		Sname,
		Gender, 
    	PHONE,
    	Postcode, 
		City, 
		State,
    	'UNKNOWN'
       
From A2custbris A2cb
-- NO NEED TO SPECIFY SOURCE TABLE AS FILTER 4 DOES THIS IMPLICITLY
where rowid in(select source_rowid from a2errorevent WHERE FILTERID = 4);
 


-- FILTER 5 TRANSFORMATION AND LOAD - PHONE HAS HYPHEN OR SPACE - REMOVE HYPHEN OR SPACE

Insert Into Dwcust (Dwcustid,
		 			Dwsourceidbris, 
					Dwsourceidmelb, 
					Firstname,
					Surname, 
                    Gender, 
					Phone, 
					Postcode, 
					City, 
					State, 
					Custcatname)
-- GENERATE THE RESULT SET TO INSERT
Select 	Dwcustseq.Nextval, 
		CUSTId, 
		Null, 
		Fname, 
		Sname,
		Gender, 
    	replace(replace(Phone, '-', ''), ' ' , ''),
    	Postcode, 
		City, 
		State,
    	(Select Custcatname From A2custcategory Where Custcatcode = A2cb.CustcatCODE)
       
From A2custbris A2cb
-- NO NEED TO SPECIFY SOURCE TABKLE AS FILTER 5 DOES THIS IMPLICITLY
where rowid in(select source_rowid from a2errorevent WHERE FILTERID = 5);
   

-- FILTER 6 ACTION IS SKIP, NO TRANSFORM AND LOAD REQUIRED.

-- FILTER 7 TRANSFORMATION AND LOAD

-- INSERT ROWS WITH FILTER 7 (GENDER SPELLING) ERRORS

-- DO OVER 2 QUERIES, ONE FOR THOSE WITH VALUES IN THE GENDER SPELLING TABLE
-- AND ONE FOR THOSE WITHOUT VALUE IN GENDER SPELLING OR NULLL GENDERS

Insert Into Dwcust (Dwcustid, 
					Dwsourceidbris, 
					Dwsourceidmelb, 
					Firstname,
					Surname, 
          		  	Gender, 
					Phone, 
					Postcode, 
					City, 
					State, 
					Custcatname)
 -- GENERATE THE RESULT SET TO INSERT  
Select  Dwcustseq.Nextval, 	
        CUSTId, 
        Null, 
        Fname, 
        Sname,
        (select newvalue from genderspelling where invalidvalue = upper(a2cb.gender)),
        Phone, 
        Postcode, 
        City, 
        State,
       	(Select Custcatname From A2custcategory Where Custcatcode = A2cb.CustcatCODE)
       
From A2custbris A2cb
-- NO NEED TO SPECIFY SOURCE TABLE AS FILTER 4 DOES THIS IMPLICITLY
Where Rowid In(Select Source_Rowid From a2errorevent Where Filterid = 7)
AND upper(a2cb.gender) IN (SELECT INVALIDVALUE FROM GENDERSPELLING);


Insert Into Dwcust (Dwcustid, 
					Dwsourceidbris, 
					Dwsourceidmelb, 
					Firstname,
					Surname, 
          		  	Gender, 
					Phone, 
					Postcode, 
					City, 
					State, 
					Custcatname)
 -- GENERATE THE RESULT SET TO INSERT 
Select  Dwcustseq.Nextval, 	
        CUSTId, 
        Null, 
        Fname, 
        Sname,
        'U',
        Phone, 
        Postcode, 
        City, 
        State,
       	(Select Custcatname From A2custcategory Where Custcatcode = A2cb.CustcatCODE)
       
From A2custbris A2cb
-- NO NEED TO SPECIFY SOURCE TABLE AS FILTER 4 DOES THIS IMPLICITLY
Where Rowid In(Select Source_Rowid From a2errorevent Where Filterid = 7)
And 
(Upper(A2cb.Gender) Not In (Select Invalidvalue From Genderspelling)
OR A2cb.Gender IS NULL);


--MERGE MELBOURNE CUSTOMERS

Merge Into Dwcust Dw
Using (Select A2c.Custid, A2c.Fname, A2c.Sname, A2c.Gender, A2c.Phone, A2c.Postcode, A2c.City, A2c.State, A2cc.Custcatname
        from A2custmelb a2c inner join a2custcategory a2cc on a2c.custcatcode = a2cc.custcatcode) a2
ON (A2.Fname = Dw.Firstname And A2.Sname = Dw.Surname and A2.Postcode = Dw.Postcode)
When Matched Then
Update Set Dw.Dwsourceidmelb = A2.Custid
When Not Matched Then
Insert (Dwcustid, 
        Dwsourceidbris, 
        Dwsourceidmelb, 
        Firstname,
        Surname, 
        Gender, 
        Phone, 
        Postcode, 
        City, 
        State, 
        Custcatname)
values  (Dwcustseq.Nextval, 	
        Null, 
        A2.custid, 
        A2.Fname, 
        A2.Sname,
        Upper(A2.Gender),
        A2.Phone, 
        A2.Postcode, 
        A2.City, 
        A2.State,
        a2.custcatname
       	);





	-- filter 8
	-- PROD ID DOES NOYT MATCH DWSOURCEID IN DWPROD WHERE DWSOURCETAVBLE = A2PRODUCT
	-- SKIP ALL ROWS THAT DON'T REFER TO A VALID PRODUCT
	Insert Into a2errorevent(Errorid, Source_Rowid, Source_Table, Filterid, Datetime, Action)
	Select a2erroreventseq.Nextval, Rowid, 'A2SALEBRIS', 8, Sysdate, 'SKIP' 
	From A2salebris a2sb
	Where A2sb.Prodid Not In (Select Dwsourceid From Dwprod)
  	OR A2SB.PRODID IS NULL;

	-- FILTER 9
	-- Customer ID does not match a Source CustID value in the DWCUST table (OR IS NULL)
	Insert Into a2errorevent(Errorid, Source_Rowid, Source_Table, Filterid, Datetime, Action)
	Select a2erroreventseq.Nextval, Rowid, 'A2SALEBRIS', 9, Sysdate, 'SKIP' 
	From A2salebris A2sb
	Where A2sb.Custid Not In (Select Dwsourceidbris From Dwcust where dwsourceidbris is not null)
	OR A2sb.Custid Is Null;

	-- filter 10
	-- SHIP DATE IS EARLIER THAN SALE DATE
	Insert Into a2errorevent(Errorid, Source_Rowid, Source_Table, Filterid, Datetime, Action)
	Select a2erroreventseq.Nextval, Rowid, 'A2SALEBRIS', 10, Sysdate, 'MODIFY' 
	From A2salebris A2sb
	Where A2sb.shipdate < a2sb.saledate;



	-- FILTER 11
	-- SALE PRICE IS NULL - MODIFY TO MATCH MOST RECENT SALE PRICE FOR THAT PRODUCT IN DWPROD.
	Insert Into a2errorevent(Errorid, Source_Rowid, Source_Table, Filterid, Datetime, Action)
	Select a2erroreventseq.Nextval, Rowid, 'A2SALEBRIS', 11, Sysdate, 'MODIFY' 
	From A2salebris A2sb
	Where A2sb.UNITPRICE IS NULL;


-- upload those with no errors

	Insert Into Dwsale (Dwsaleid, 
                    	Dwcustid, 
                    	Dwprodid, 
                    	Dwsourceidbris, 
                    	Dwsourceidmelb, 
                    	Qty, 
                    	Sale_Dwdateid, 
                    	Ship_DWDATEID, 
                     	Saleprice)      

	Select 	Dwsaleseq.Nextval, 
        	(Select Dwcustid From Dwcust Where Dwsourceidbris = A2sb.Custid and dwsourceidbris is not null),
        	(Select Dwprodid From Dwprod Where Dwsourceid = A2sb.Prodid),
        	A2sb.Saleid,
        	Null,
        	A2sb.Qty,
        	(Select Datekey From DWDATE Where Datevalue =  A2sb.Saledate),
         	(SELECT DATEKEY FROM DWDATE WHERE DATEVALUE =  A2sb.Shipdate),
        	a2sb.UNITprice
	From A2salebris A2sb
	-- ensure that only rows with no error_event records for any filter get inserted as clean.
	where rowid || 'A2SALEBRIS' not in (select source_rowid || SOURCE_TABLE from a2errorevent);

/

--  FILTER 8 ACION IS SKIP SO NO UPLOAD

--  FILTER 9 ACION IS SKIP SO NO UPLOAD

	-- FILTER 10 TRANSFORM AND LOAD - SET SHIPDATE TO SALEDATE + 2

	Insert Into Dwsale (Dwsaleid, 
						Dwcustid, 
						Dwprodid, 
						Dwsourceidbris, 
            			Dwsourceidmelb, 
						Qty, 
            			Sale_Dwdateid, 
            			 Ship_DWDATEID,
						Saleprice)      

	Select Dwsaleseq.Nextval, 
        (Select Dwcustid From Dwcust Where Dwsourceidbris = A2sb.Custid and dwsourceidbris is not null),
        (Select Dwprodid From Dwprod Where Dwsourceid = A2sb.Prodid),
        A2sb.Saleid,
        Null,
        A2sb.Qty,
        (Select Datekey From DWDATE Where Datevalue =  A2sb.Saledate),
        (Select Datekey From DWDATE Where Datevalue =  A2sb.Saledate + 2),
        a2sb.UNITprice
	From A2salebris A2sb
	-- NO NEED TO SPECIFY SOURCE TABLE AS FILTER 10 DOES THIS IMPLICITLY
	where rowid in (select source_rowid from a2errorevent where filterid = 10);


-- FILTER 11 - TRANSOFRM AND LOAD - SET SALEPRICE TO THE MAX SALEPRICE OD THAT PRODUCT IN 

	Insert Into Dwsale (Dwsaleid, 
                      Dwcustid, 
                      Dwprodid, 
                      Dwsourceidbris, 
                      Dwsourceidmelb, 
                      Qty, 
                      Sale_Dwdateid, 
                      Ship_DWDATEID,
                      Saleprice)      

	Select Dwsaleseq.Nextval, 
        (Select Dwcustid From Dwcust Where Dwsourceidbris = A2sb.Custid and dwsourceidbris is not null),
        (Select Dwprodid From Dwprod Where Dwsourceid = A2sb.Prodid),
        A2sb.Saleid,
        Null,
        A2sb.Qty,
        (Select Datekey From DWDATE Where Datevalue =  A2sb.Saledate),
        (Select Datekey From DWDATE Where Datevalue =  A2sb.Shipdate), 
        (Select Max(Ina2cb.Unitprice) From A2salebris Ina2cb Where Ina2cb.Prodid = A2sb.Prodid)
        
	From A2salebris A2sb
	-- NO NEED TO SPECIFY SOURCE TABLE AS FILTER 11 DOES THIS IMPLICITLY
	where rowid in (select source_rowid from a2errorevent where filterid = 11);

	-- filter 12
	-- PROD ID DOES NOYT MATCH DWSOURCEID IN DWPROD WHERE DWSOURCETAVBLE = A2PRODUCT
	-- SKIP ALL ROWS THAT DON'T REFER TO A VALID PRODUCT
	Insert Into a2errorevent(Errorid, Source_Rowid, Source_Table, Filterid, Datetime, Action)
	Select a2erroreventseq.Nextval, Rowid, 'A2SALEMELB', 12, Sysdate, 'SKIP' 
	From A2salemelb a2sb
	Where A2sb.Prodid Not In (Select Dwsourceid From Dwprod)
  OR A2SB.PRODID IS NULL;

	-- FILTER 13
	-- Customer ID does not match a Source CustID value in the DWCUST table (OR IS NULL)
	Insert Into a2errorevent(Errorid, Source_Rowid, Source_Table, Filterid, Datetime, Action)
	Select a2erroreventseq.Nextval, Rowid, 'A2SALEMELB', 13, Sysdate, 'SKIP' 
	From A2salemelb A2sb
	Where A2sb.Custid Not In (Select Dwsourceidmelb From Dwcust where dwsourceidmelb is not null)
	OR A2sb.Custid Is Null;

	-- filter 14
	-- SHIP DATE IS EARLIER THAN SALE DATE
	Insert Into a2errorevent(Errorid, Source_Rowid, Source_Table, Filterid, Datetime, Action)
	Select a2erroreventseq.Nextval, Rowid, 'A2SALEMELB', 14, Sysdate, 'MODIFY' 
	From A2salemelb A2sb
	Where A2sb.shipdate < a2sb.saledate;



	-- FILTER 15
	-- SALE PRICE IS NULL - MODIFY TO MATCH MOST RECENT SALE PRICE FOR THAT PRODUCT IN DWPROD.
	Insert Into A2errorevent(Errorid, Source_Rowid, Source_Table, Filterid, Datetime, Action)
	Select a2erroreventseq.Nextval, Rowid, 'A2SALEMELB', 15, Sysdate, 'MODIFY' 
	From A2salemelb A2sb
	Where A2sb.UNITPRICE IS NULL;


Create View MulTiple_FILTER_FAILS As
        Select Source_Rowid From A2errorevent
        Where Filterid In (12,13,14,15)
        Group By Source_Rowid
        Having Count(*) > 1;

-- upload those with no errors

	Insert Into Dwsale (Dwsaleid, 
                    	Dwcustid, 
                    	Dwprodid, 
                    	Dwsourceidbris, 
                    	Dwsourceidmelb, 
                    	Qty, 
                    	Sale_Dwdateid, 
                    	Ship_DWDATEID, 
                     	Saleprice)      

	Select 	Dwsaleseq.Nextval, 
        	(Select Dwcustid From Dwcust Where Dwsourceidmelb = A2sb.Custid and dwsourceidmelb is not null),
        	(Select Dwprodid From Dwprod Where Dwsourceid = A2sb.Prodid),
          Null,
        	A2sb.Saleid,
        	A2sb.Qty,
        	(Select Datekey From DWDATE Where Datevalue =  A2sb.Saledate),
         	(SELECT DATEKEY FROM DWDATE WHERE DATEVALUE =  A2sb.Shipdate),
        	a2sb.UNITprice
	From A2salemelb A2sb
	-- ensure that only rows with no error_event records for any filter get inserted as clean.
	Where Rowid || 'A2SALEMELB' Not In (Select Source_Rowid || Source_Table From A2errorevent);




--  FILTER 12 ACTION IS SKIP SO NO UPLOAD

--  FILTER 13 ACTION IS SKIP SO NO UPLOAD


	-- FILTER 14 TRANSFORM AND LOAD - SET SHIPDATE TO SALEDATE + 2

	Insert Into Dwsale (Dwsaleid, 
						Dwcustid, 
						Dwprodid, 
						Dwsourceidbris, 
            Dwsourceidmelb, 
						Qty, 
            Sale_Dwdateid, 
            Ship_DWDATEID,
						Saleprice)      

	Select Dwsaleseq.Nextval, 
        (Select Dwcustid From Dwcust Where Dwsourceidmelb = A2sb.Custid and dwsourceidmelb is not null),
        (Select Dwprodid From Dwprod Where Dwsourceid = A2sb.Prodid),
        Null,
        A2sb.Saleid,
        A2sb.Qty,
        (Select Datekey From DWDATE Where Datevalue =  A2sb.Saledate),
        (Select Datekey From DWDATE Where Datevalue =  A2sb.Saledate + 2),
        a2sb.UNITprice
	From A2saleMELB A2sb
	-- NO NEED TO SPECIFY SOURCE TABLE AS FILTER 14 DOES THIS IMPLICITLY
	Where Rowid In (Select Source_Rowid From A2errorevent Where Filterid = 14 And Filterid Is Not Null);



-- FILTER 15 - TRANSFoRM AND LOAD - SET SALEPRICE TO THE MAX SALEPRICE OD THAT PRODUCT IN 

	Insert Into Dwsale (Dwsaleid, 
						Dwcustid, 
						Dwprodid, 
						Dwsourceidbris, 
            Dwsourceidmelb, 
						Qty, 
            Sale_Dwdateid, 
            Ship_DWDATEID,
						Saleprice)      

	Select Dwsaleseq.Nextval, 
        (Select Dwcustid From Dwcust Where Dwsourceidmelb = A2sb.Custid and dwsourceidmelb is not null),
        (Select Dwprodid From Dwprod Where Dwsourceid = A2sb.Prodid),
        Null,
        A2sb.Saleid,
        A2sb.Qty,
        (Select Datekey From DWDATE Where Datevalue =  A2sb.Saledate),
        (Select Datekey From DWDATE Where Datevalue =  A2sb.Shipdate), 
        (Select Max(Ina2cb.Unitprice) From A2saleMELB Ina2cb Where Ina2cb.Prodid = A2sb.Prodid)
        
	From A2saleMELB A2sb
	-- NO NEED TO SPECIFY SOURCE TABLE AS FILTER 15 DOES THIS IMPLICITLY
	where rowid in (select source_rowid from a2errorevent where filterid = 15 and filterid is not null);


COMMIT;



PROMPT DWSALE WITHOUT REMOVING MULTI FILTER FAILS

--select count(*) from dwsale;

--select count(*) from dwsale where dwsourceidbris is not null;

--select count(*) from dwsale where dwsourceidmelb is not null;

Delete From Dwsale
WHERE DWSOURCEIDMELB IN(
                Select Saleid 
                From A2salemelb
                Where Rowid In (
                      Select * FROM Multiple_Filter_Fails
                                )
                        );
                
/*
PROMPT DWSALE COUNT AFTER REMOVING MULTI FILTER FAILS

Select Count(*) From Dwsale;

PROMPT EXPECTED FILTER COUNTS;

SELECT   FILTERID, ACTION, COUNT(*)
FROM     a2errorevent
GROUP BY FILTERID, ACTION
ORDER BY 1;


Prompt Part 8 - Queries


*/


