-- CLEN OUT ANY OLD INSTALLATION
Exec Drop_If_Exists('A2M_assignment', True, True);
exec drop_if_exists('A2M_Db_Object_Type', true, true);
exec drop_if_exists('A2M_Db_Object', true, true);
exec drop_if_exists('A2M_Db_Object_Item_Type', true, true);
exec drop_if_exists('A2M_Data_Type', true, true);
exec drop_if_exists('A2M_Db_Object_Item', true, true);
Exec Drop_If_Exists('A2M_NOT_ATTEMPTED', True, True);
Exec Drop_If_Exists('A2M_Object_Seq', True, True);
exec drop_if_exists('A2M_Object_Item_Seq', true, true);
Exec Drop_If_Exists('A2M_Assign_Seq', True, True);

CREATE SEQUENCE A2M_OBJECT_Seq;
CREATE SEQUENCE A2M_OBJECT_ITEM_Seq;
create sequence A2M_Assign_Seq;

CREATE TABLE A2M_ASSIGNMENT(
Assid Integer,
ASSNAME VARCHAR2(50) not null,
Assdesc Varchar2(1000),
Constraint A2M_Pk_Assignment Primary Key (Assid)
);

Create Table A2M_Db_Object_Type(
Objecttype Varchar2(50),
Constraint Pk_Db_Object_Type Primary Key (Objecttype)
);

Create Table A2M_Db_Object(
Objectid Integer,
Objectname Varchar2(50),
Objecttype Varchar2(50),
assid integer not null,
Constraint A2M_Pk_Db_Object Primary Key (Objectid),
Constraint A2M_Fk_Object_Objtype Foreign Key (Objecttype) References A2M_Db_Object_Type,
constraint A2M_fk_assignment foreign key (assid) references A2M_Assignment,
constraint A2M_db_obj_name_unique unique(objectname)
);

-- TABLE TO HOLD DIFFERENT DB OBJECT ELEMENT TYPES, EG COLUMN, PARAMETER, RETYURN VALUE
-- FOR EACH OBJECT IN A2M_DB_OBJECT_ITEM

Create Table A2M_Db_Object_Item_Type(
Itemtype Varchar2(50), -- EG PARAMETER, COLUMN
Itemsubtype Varchar2(50), -- EG IN OR OUR PARAMETER, CHECK CONSTRAINT ETC
Constraint A2M_Pk_Object_Item_Type Primary Key(Itemtype, Itemsubtype)
);

Create Table A2M_Data_Type(
Datatype Varchar2(50),
Constraint A2M_Pk_Data_Type Primary Key (Datatype)
);

Create Table A2M_Db_Object_Item(
Itemid Integer,
Itemname Varchar2(50) Not Null,
Itemtype Varchar2(50) Not Null,
ITEMSUBTYPE VARCHAR2(50),
Datatype Varchar2(50),
CONDITIONS VARCHAR(200),
Datalength VARCHAR2(10), -- HOLDS THE NUMBER ELEMENT OF A DATA TYPE WHERE NEEDED EG FOR VARCHAR2(30) 
Itemorder Integer, -- THE ORDER ITEMS NEED TO BE INCLUDED IN THE OBJECT EG : PARAMETERS ON A FUNCTION NEED TO BE IN A PARTICULAR ORDER
objectid integer, -- the id of the object the item belongs to
Constraint A2M_Pk_Db_Object_Item Primary Key (Itemid),
Constraint A2M_Fk_Objitem_Type Foreign Key (Itemtype, Itemsubtype) References A2M_Db_Object_Item_Type,
Constraint A2M_Fk_Objitem_Datatype Foreign Key (Datatype) References A2M_Data_Type,
Constraint A2M_Fk_Objitem_Object Foreign Key (Objectid) References A2M_Db_Object
);
