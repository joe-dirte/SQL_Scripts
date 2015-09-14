rem ********************************************************************
rem * Author            : Joe Skinner
rem * Description       : Show current bind of given sql
rem * Usage             : SQL> @bind_curr
rem ********************************************************************
col name for a10
col VALUE_STRING for a30
SELECT NAME,POSITION,DATATYPE_STRING,VALUE_STRING 
FROM v$sql_bind_capture WHERE sql_id='&sql_id';
