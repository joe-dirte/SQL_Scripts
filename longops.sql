rem ********************************************************************
rem * Author            : Joe Skinner
rem * Description       : Show sqls showing up in the session_longops table 
rem * Usage             : SQL> @longops
rem ********************************************************************
column ssid format 9999 heading SID
column opname format a15 Heading Operation
column target format a28 Heading Target
column es format 999.9 Heading "Time|Ran"
column tr format 99999.90 Heading "Time|Left"
column pct format 990 Heading "PCT"
column RATE Heading "I/O |Rate/m" just right form A20
select INST_ID,
sid ssid, SQL_ID,USERNAME,
substr(OPNAME,1,15) opname,
target, 
trunc((sofar/totalwork)*100) pct,
to_char(60*sofar*8192/(24*60*(last_update_time - start_time))/1024/1024/60,
'999999.0')||'M' Rate,
elapsed_seconds/60 es,
time_remaining/60 tr
from gv$session_longops
where time_remaining > 0
order by start_time;

