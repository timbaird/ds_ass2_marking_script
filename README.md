# ds_ass2_marking_script
Database Systems Assignment 2 Marking Script

#################################

CONTENTS

#################################

1.	WARRANTY AND SUPPORT
2.	DEPENDENCY
3.	INSTALLATION INSTRUCTIONS
4.	INSTRUCTIONS FOR STUDENT USE


#################################

1.	WARRANTY & SUPPORT

#################################

This work / library is offered without warranty either express of implied.

It is a condition of use of this library that both the original author,
and any other contributing authors are absolved of responsibility for 
any damages real or imagined which arise from the use of this work.

Support is not provided.

#################################

2.	DEPENDENCY

#################################

This marking script has a dependency on my plsql core library available from https://github.com/timbaird/plsql_core_library.git

Please install this library prior to installing this makring script.

#################################

3.	INSTALLATION INSTRUCTIONS

#################################

The library comes with an installation script called INSTALLER.sql 

To use INSTALLER.sql its reference to the file system must be maintained.

This means you need to either:

a. open it though the IDE (e.g. SQL Developer) File menu
OR
b. drag and drop it into the IDE (if the IDE supports this)

DO NOT open the installer script, and copy paste the script from a text editor into your IDE 
as it will lose its reference to its place in the file system and not function correctly.

Once it is open in your IDE run the script and it will install the core library procedures and functions to your database.

#################################

4.	INSTRUCTIONS FOR STUDENT USE

#################################


ACCESS TO SCRIPT
________________

THIS MARKING SCRIPT IS INTENDED TO BE INSTALLED ON A STAFF ACCOUNT AND IS NOT INTENDED TO BE MADE DIRECTLY AVAILABLE TO STUDENTS

THE ONLY FILE THAT SHOULD BE MADE AVAILABLE TO STUDENTS IS  A2_MARKING_SCRIPT.sql

A2_MARKING_SCRIPT.sql CALLS AND UTILISES THE OTHER ASSETS AND SCRIPTS INSTALLED IN THIS MARKING SCRIPT


INSTRUCTIONS TO STUDENTS
________________________

The following instructions (or equivilent) should be provided to students with this marking script

				
		---------------------------------------
		****  WARNING  *****
		---------------------------------------
		
		This marking script AUTOMAGICALLY deletes assignment related TABLES, PROCEDURE AND FUNCTIONS
		from the subject database and re creates them from script
		
		IF YOUR ASSIGNMENT IS STORED ONLY IN YOUR DATABASE AND IS NOT IN SCRIPT FORM 
		OR 
		YOU HAVE OTHER DATABASE OBJECTS, DATA OR CONTENT THAT YOU WISH TO PRESERVE
		
		ENSURE YOU CREATE A DUMP OR OTHER BACKUP OF THESE PRIOR TO USING THIS MARKING SCRIPT.
		
		---------------------------------------
		INSTRUCTIONS FOR USE OF MARKING SCRIPT
		---------------------------------------
		
		a.	ENSURE YOUR SCRIPT IS NAMED:  A2_SQLCODE.sql
		
		b.	PLACE YOUR SCRIPT IN THE SAME FOLDER AS THE FILE NAMED:  A2_MARKING_SCRIPT.sql
		
		c.	EITHER 	A. DRAG AND DROP A2_MARKING_SCRIPT.sql INTO SQL DEVELOPER
			OR	B. OPEN A2_MARKING_SCRIPT.sql THOUGH THE FILE MENU OF SQL DEVELOPER.
			
			*** DO NOT ***. COPY AND PASTE THE CONTENTS OF A2_MARKING_SCRIPT.sql FROM A TEXT EDITOR TO SQL DEVELOPER
			
		d.	RUN THE MARKING SCRIPT IN SQL DEVELOPER - SEE THE OUTPUT FOR FEEDBACK ON YOUR ASSIGNMENT
		
		
	

