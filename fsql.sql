rem ********************************************************************
rem * Author		: Joe Skinner
rem * Description	: Find sql text by sql_id
rem * Usage		: SQL> @fsql
rem ********************************************************************
set head off
set verify off
set long 99999999
set trimout on
set trimspoo on
set linesize 32767
col sql_fulltext format a32767
select SQL_FULLTEXT from v$sql where sql_id = '&sqlid' and rownum < 2;
set lines 200
set head on
