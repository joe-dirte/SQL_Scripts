rem ********************************************************************
rem * Author		: Joe Skinner
rem * Description	: Show Details of Session by specific SID
rem * Usage		: SQL> @sess_dtl
rem ********************************************************************
set lines 1000 pages 100
col sid for 9999
col machine for a30
col program for a30
col event for a30
col status for a10
col SECONDS_IN_WAIT for 999999
col username for a15
select inst_id,sid,serial#,username,machine,program,sql_id,status,prev_sql_id,event,logon_time,seconds_in_wait,blocking_session from gv$session where sid in (&sid) order by inst_id;
