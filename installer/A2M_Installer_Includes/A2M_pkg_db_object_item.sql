/*

-- ##########################################################
-- MS DB OBJECT ITEM Package - functions related to that table.
-- ##########################################################

Create Or Replace Package A2M_Pkg_Db_Object_Item As

Function Add(Pitemname Varchar2, Pitemtype Varchar2, Pitemsubtype Varchar2, 
              Pdatatype Varchar2, Pdatalength Integer, pItemorder Integer, pObjectid Integer) Return Integer;
              
Procedure Upd(Pitemid Integer, pitemname varchar2, Pitemtype Varchar2, Pitemsubtype Varchar2, Pdatatype Varchar2, 
              Pdatalength Integer, pItemorder Integer);

End A2M_Pkg_DB_OBJECT_item;
/


Create Or Replace Package BODY A2M_Pkg_Db_Object_item As

Function Add(Pitemname Varchar2, Pitemtype Varchar2, Pitemsubtype Varchar2, 
              Pdatatype Varchar2, Pdatalength Integer, pItemorder Integer, pObjectid Integer) Return Integer as

vPK integer;

Begin

Insert Into A2M_Db_Object_Item (Itemid, Itemname, Itemtype, Itemsubtype, Datatype, Datalength, Itemorder, Objectid)
Values (A2M_object_item_Seq.Nextval, pitemname, pitemtype, pitemsubtype, pdatatype, pdatalength, pitemorder, pobjectid);

Select Max(Itemid) Into Vpk
from A2M_db_object_item;

return vPK;

Exception
When Others Then
Raise_Application_Error(-20000, Sqlerrm);
End ADD;

Procedure Upd(Pitemid Integer, pitemname varchar2, Pitemtype Varchar2, Pitemsubtype Varchar2, Pdatatype Varchar2, 
              Pdatalength Integer, pItemorder Integer)as

begin

Update A2M_Db_Object_Item
Set itemname = pitemname, Itemtype = Pitemtype, Itemsubtype = Pitemsubtype, Datatype = Pdatatype, 
    Datalength = Pdatalength, Itemorder = Pitemorder
where itemid = pitemid;

Exception
When Others Then
Raise_Application_Error(-20000, Sqlerrm);
End UPD;

End A2M_Pkg_Db_Object_item;
/
*/