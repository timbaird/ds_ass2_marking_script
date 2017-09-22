Insert Into A2M_Assignment (Assid, Assname, Assdesc)
Select A2M_Assign_Seq.Nextval, 'DS Ass2', 'DS Data Warehousing Assignment Semester 1 2015' From Dual;


Insert Into A2M_Db_Object_Type Values ('TABLE');
Insert Into A2M_Db_Object_Type Values ('PROCEDURE');
Insert Into A2M_Db_Object_Type Values ('FUNCTION');
Insert Into A2M_Db_Object_Type Values ('TRIGGER');
Insert Into A2M_Db_Object_Type Values ('SEQUENCE');
Insert Into A2M_Db_Object_Type Values ('PACKAGE');
Insert Into A2M_Db_Object_Type Values ('PACKAGE BODY');
Insert Into A2M_Db_Object_Type Values ('INDEX');
Insert Into A2M_Db_Object_Type Values ('SYNONYM');
Insert Into A2M_Db_Object_Type Values ('VIEW');
Insert Into A2M_Db_Object_Type values ('TYPE');


Insert Into A2M_Db_Object_Item_Type Values('PARAMETER', 'IN');
Insert Into A2M_Db_Object_Item_Type Values('PARAMETER', 'OUT');
Insert Into A2M_Db_Object_Item_Type Values('PARAMETER', 'INOUT');
Insert Into A2M_Db_Object_Item_Type Values('RETURN_VALUE', ' ');
Insert Into A2M_Db_Object_Item_Type Values('COLUMN', ' ');
Insert Into A2M_Db_Object_Item_Type Values('CONSTRAINT', 'PRIMARY KEY');
Insert Into A2M_Db_Object_Item_Type Values('CONSTRAINT', 'FOREIGN KEY');
Insert Into A2M_Db_Object_Item_Type Values('CONSTRAINT', 'CHECK');
Insert Into A2M_Db_Object_Item_Type Values('CONSTRAINT', 'UNIQUE');
Insert Into A2M_Db_Object_Item_Type Values('CONSTRAINT', 'NOT NULL');


Insert Into A2M_Data_Type Values ('INTEGER');
Insert Into A2M_Data_Type Values ('NUMBER');
Insert Into A2M_Data_Type Values ('ROWID');
Insert Into A2M_Data_Type Values ('BOOLEAN');
Insert Into A2M_Data_Type Values ('VARCHAR2');
Insert Into A2M_Data_Type Values ('CHAR');
Insert Into A2M_Data_Type Values ('EXCEPTION');
Insert Into A2M_Data_Type Values ('DATE');
Insert Into A2M_Data_Type Values ('DATETIME');


-- dwcust

Insert Into A2M_Db_Object (Objectid, Objectname, Objecttype, ASSID)
select A2M_Object_Seq.NEXTVAL, 'DWCUST', 'TABLE', (select assid from A2M_assignment where assname = 'DS Ass2') FROM DUAL;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)                               
SELECT 	A2M_Object_Item_Seq.NEXTVAL, 
		'DWCUSTID', 
		'COLUMN', 
		NULL, 
		'VARCHAR2', 
		'50', 
		1, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWCUST')
From Dual;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
SELECT 	A2M_Object_Item_Seq.NEXTVAL, 
		'DWSOURCEIDBRIS', 
		'COLUMN', 
		Null, 
		'INTEGER', 
		NULL, 
		2, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWCUST')
FROM DUAL;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
SELECT 	A2M_Object_Item_Seq.NEXTVAL, 
		'DWSOURCEIDMELB', 
		'COLUMN', 
		Null, 
		'INTEGER', 
		NULL, 
		3, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWCUST')
FROM DUAL;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
Select 	A2M_Object_Item_Seq.Nextval, 
		'FIRSTNAME', 
		'COLUMN', 
		Null, 
		'VARCHAR2', 
		'50', 
		4, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWCUST')
FROM DUAL;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
Select 	A2M_Object_Item_Seq.Nextval, 
		'SURNAME', 
		'COLUMN', 
		Null, 
		'VARCHAR2', 
		'50', 
		5, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWCUST')
FROM DUAL;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
Select 	A2M_Object_Item_Seq.Nextval, 
		'GENDER', 
		'COLUMN', 
		Null, 
		'VARCHAR2', 
		'10', 
		6, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWCUST')
FROM DUAL;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
Select 	A2M_Object_Item_Seq.Nextval, 
		'PHONE', 
		'COLUMN', 
		Null, 
		'VARCHAR2', 
		'20', 
		7, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWCUST')
FROM DUAL;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)

Select 	A2M_Object_Item_Seq.Nextval, 
		'POSTCODE', 
		'COLUMN', 
		Null, 
		'NUMBER', 
		'4', 
		8, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWCUST')
FROM DUAL;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
Select 	A2M_Object_Item_Seq.Nextval, 
		'CITY', 
		'COLUMN', 
		Null, 
		'VARCHAR2', 
		'50', 
		9, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWCUST')
FROM DUAL;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
Select 	A2M_Object_Item_Seq.Nextval, 
		'STATE', 
		'COLUMN', 
		Null, 
		'VARCHAR2', 
		'10', 
		10, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWCUST')
FROM DUAL;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
Select 	A2M_Object_Item_Seq.Nextval, 
		'CUSTCATNAME', 
		'COLUMN', 
		Null, 
		'VARCHAR2', 
		'30', 
		11, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWCUST')
From Dual;


Insert Into A2M_Db_Object (Objectid, Objectname, Objecttype, ASSID)
select A2M_Object_Seq.NEXTVAL, 'DWSALE', 'TABLE', (select assid from A2M_assignment where assname = 'DS Ass2') FROM DUAL;

--###########\
-- dwsale


Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
Select 	A2M_Object_Item_Seq.Nextval, 
		'DWSALEID', 
		'COLUMN', 
		Null, 
		'INTEGER', 
		NULL, 
		1, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWSALE')
FROM DUAL;


Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
Select 	A2M_Object_Item_Seq.Nextval, 
		'DWCUSTID', 
		'COLUMN', 
		Null, 
		'INTEGER', 
		NULL, 
		2, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWSALE')
FROM DUAL;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
Select 	A2M_Object_Item_Seq.Nextval, 
		'DWPRODID', 
		'COLUMN', 
		Null, 
		'INTEGER', 
		Null, 
		3, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWSALE')
FROM DUAL;


Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
Select 	A2M_Object_Item_Seq.Nextval, 
		'DWSOURCEIDBRIS', 
		'COLUMN', 
		Null, 
		'INTEGER', 
		Null, 
		4, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWSALE')
FROM DUAL;


Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
Select 	A2M_Object_Item_Seq.Nextval, 
		'DWSOURCEIDMELB', 
		'COLUMN', 
		Null, 
		'INTEGER', 
		Null, 
		5, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWSALE')
FROM DUAL;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
Select 	A2M_Object_Item_Seq.Nextval, 
		'QTY', 
		'COLUMN', 
		Null, 
		'INTEGER', 
		Null, 
		6, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWSALE')
FROM DUAL;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
Select 	A2M_Object_Item_Seq.Nextval, 
		'SALE_DWDATEID', 
		'COLUMN', 
		Null, 
		'INTEGER', 
		Null, 
		7, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWSALE')
FROM DUAL;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
Select 	A2M_Object_Item_Seq.Nextval, 
		'SHIP_DWDATEID', 
		'COLUMN', 
		Null, 
		'INTEGER', 
		Null, 
		8, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWSALE')
FROM DUAL;


Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
Select 	A2M_Object_Item_Seq.Nextval, 
		'SALEPRICE', 
		'COLUMN', 
		Null, 
		'NUMBER', 
		'5,2', 
		9, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWSALE')
From Dual;

--$##############
-- dwprod


Insert Into A2M_Db_Object (Objectid, Objectname, Objecttype, ASSID)
select A2M_Object_Seq.NEXTVAL, 'DWPROD', 'TABLE', (select assid from A2M_assignment where assname = 'DS Ass2') FROM DUAL;


Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
Select 	A2M_Object_Item_Seq.Nextval, 
		'DWPRODID', 
		'COLUMN', 
		Null, 
		'INTEGER', 
		NULL, 
		1, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWPROD')
FROM DUAL;


Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
Select 	A2M_Object_Item_Seq.Nextval, 
		'DWSOURCETABLE', 
		'COLUMN', 
		Null, 
		'VARCHAR2', 
		'50', 
		2, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWPROD')
FROM DUAL;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
Select 	A2M_Object_Item_Seq.Nextval, 
		'DWSOURCEID', 
		'COLUMN', 
		Null, 
		'INTEGER', 
		NULL, 
		3, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWPROD')
FROM DUAL;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
Select 	A2M_Object_Item_Seq.Nextval, 
		'PRODNAME', 
		'COLUMN', 
		Null, 
		'VARCHAR2', 
		'100', 
		4, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWPROD')
FROM DUAL;


Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
Select 	A2M_Object_Item_Seq.Nextval, 
		'PRODCATNAME', 
		'COLUMN', 
		Null, 
		'VARCHAR2', 
		'30', 
		5, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWPROD')
From Dual;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
Select 	A2M_Object_Item_Seq.Nextval, 
		'PRODMANUNAME', 
		'COLUMN', 
		Null, 
		'VARCHAR2', 
		'30', 
		6, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWPROD')
From Dual;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
Select 	A2M_Object_Item_Seq.Nextval, 
		'PRODSHIPNAME', 
		'COLUMN', 
		Null, 
		'VARCHAR2', 
		'30', 
		7, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'DWPROD')
From Dual;





--#############
-- a2errorevent


Insert Into A2M_Db_Object (Objectid, Objectname, Objecttype, ASSID)
select A2M_Object_Seq.NEXTVAL, 'A2ERROREVENT', 'TABLE', (select assid from A2M_assignment where assname = 'DS Ass2') FROM DUAL;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)
                                
Select 	A2M_Object_Item_Seq.Nextval, 
		'ERRORID', 
		'COLUMN', 
		Null, 
		'INTEGER', 
		 NULL, 
		1, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'A2ERROREVENT')
From Dual;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)

Select 	A2M_Object_Item_Seq.Nextval, 
		'SOURCE_ROWID', 
		'COLUMN', 
		Null, 
		'ROWID', 
		 NULL, 
		2, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'A2ERROREVENT')
From Dual;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)

Select 	A2M_Object_Item_Seq.Nextval, 
		'SOURCE_TABLE', 
		'COLUMN', 
		Null, 
		'VARCHAR2', 
		 '30', 
		 3, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'A2ERROREVENT')
From Dual;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)

Select 	A2M_Object_Item_Seq.Nextval, 
		'FILTERID', 
		'COLUMN', 
		Null, 
		'INTEGER', 
		 NULL, 
		 4, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'A2ERROREVENT')
From Dual;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)

Select 	A2M_Object_Item_Seq.Nextval, 
		'DATETIME', 
		'COLUMN', 
		Null, 
		'DATE', 
		 NULL, 
		 5, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'A2ERROREVENT')
From Dual;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)

Select 	A2M_Object_Item_Seq.Nextval, 
		'ACTION', 
		'COLUMN', 
		Null, 
		'VARCHAR2', 
		 '6', 
		 6, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'A2ERROREVENT')
From Dual;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, CONDITIONS, Datalength, Itemorder, Objectid)
Select 	A2M_Object_Item_Seq.Nextval, 
		'ERROREVENTACTION', 
		'CONSTRAINT', 
    'CHECK', 
		Null,
    '(ACTION IN (''SKIP'',''MODIFY''))',
    NULL, 
		 7, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'A2ERROREVENT')
From Dual;

Insert Into A2M_Db_Object (Objectid, Objectname, Objecttype, ASSID)
select A2M_Object_Seq.NEXTVAL, 'GENDERSPELLING', 'TABLE', (select assid from A2M_assignment where assname = 'DS Ass2') FROM DUAL;

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, 
                                Datatype, Datalength, Itemorder, Objectid)

Select 	A2M_Object_Item_Seq.Nextval, 
		'PLACEHOLDER', 
		'COLUMN', 
    Null, 
		'VARCHAR2',
    '30',
		 1, 
		(Select Objectid From A2M_Db_Object Where Objectname = 'GENDERSPELLING')
From Dual;

