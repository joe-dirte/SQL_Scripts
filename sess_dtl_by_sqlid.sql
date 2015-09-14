rem ********************************************************************
rem * Author		: Joe Skinner
rem * Description	: Show Details of Session by specific SQLID
rem * Usage		: SQL> @sess_dtl_by_sqlid
rem ********************************************************************
set lines 1000 pages 100
col sid for 9999
col machine for a30
col program for a30
col event for a30
col status for a10
col SECONDS_IN_WAIT for 999999
col username for a15
select sid,serial#,username,machine,program,sql_id,status,prev_sql_id,event,logon_time,seconds_in_wait,last_call_et from v$session where sql_id in ('&sql_id');
