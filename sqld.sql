rem ********************************************************************
rem * Author            : Joe Skinner
rem * Description       : Pull SQL exection information for a given sql 
rem * Usage             : SQL> @sqld  (sql_id , day to start from , day to end from)
rem ********************************************************************

set pages 50 lines 300
col EXECUTIONS format 999,999,999,999
col dt format a20
select
                b.SQL_ID,
                b.PLAN_HASH_VALUE,
                b.snap_id, 
                to_char(a.BEGIN_INTERVAL_TIME,'DD-MON-YY HH24:MI') dt,
                sum(b.EXECUTIONS_DELTA)  "EXECUTIONS",
                round(sum(b.CPU_TIME_DELTA) /1000000,2) "CPU_TIME",
                round((sum(b.CPU_TIME_DELTA) /1000)/sum(decode(b.EXECUTIONS_DELTA,0,1,b.EXECUTIONS_DELTA)) ,2) "CPUms/Esec",
                round(sum(b.ELAPSED_TIME_DELTA) /1000000,2) "ELAPSED_TIME",
                round((sum(b.ELAPSED_TIME_DELTA )/1000)/sum(decode(b.EXECUTIONS_DELTA,0,1,b.EXECUTIONS_DELTA)) ,2) "ET(ms)/Esec",
                sum(b.BUFFER_GETS_DELTA ) "BUFFER_GETS",
                round(sum(b.BUFFER_GETS_DELTA)/sum(decode(b.EXECUTIONS_DELTA,0,1,b.EXECUTIONS_DELTA)) ,2) "BGETS/Esec",
                round((sum(b.IOWAIT_DELTA )/1000)/sum(decode(b.EXECUTIONS_DELTA,0,1,b.EXECUTIONS_DELTA)) ,2) "IO(ms)/Esec",
                round((sum(b.APWAIT_DELTA )/1000)/sum(decode(b.EXECUTIONS_DELTA,0,1,b.EXECUTIONS_DELTA)) ,2) "APP(ms)/Esec",
                round((sum(b.CCWAIT_DELTA )/1000)/sum(decode(b.EXECUTIONS_DELTA,0,1,b.EXECUTIONS_DELTA)) ,2) "CC(ms)/Esec",
                sum(b.DISK_READS_DELTA)   "DISK_READS",
                round(sum(b.DISK_READS_DELTA)/sum(decode(b.EXECUTIONS_DELTA,0,1,b.EXECUTIONS_DELTA)) ,2) "DISK_READs/Esec",
                sum(b.rows_processed_delta) "ROWS_Procs",
                round(sum(b.rows_processed_delta)/sum(decode(b.EXECUTIONS_DELTA,0,1,b.EXECUTIONS_DELTA)) ,2) "ROWS_PPRO/Esec",
                sum(b.PARSE_CALLS_DELTA) "Parses"
from
                sys.DBA_HIST_SQLSTAT b, sys.dba_hist_snapshot a
where b.sql_id='&sql_id'
AND   a.DBID = b.dbid
--AND   a.DBID=2740498006
AND   a.INSTANCE_NUMBER = b.INSTANCE_NUMBER
and   a.SNAP_ID = b.SNAP_ID 
and   a.END_INTERVAL_TIME >= (sysdate - &days_back)
and   a.END_INTERVAL_TIME <= (sysdate - &up_to_daysexit
)
and   decode(b.EXECUTIONS_DELTA,0,1,b.EXECUTIONS_DELTA) > 0
group by b.SQL_ID,b.PLAN_HASH_VALUE,to_char(a.BEGIN_INTERVAL_TIME,'DD-MON-YY HH24:MI'),b.snap_id
order by        b.snap_id                       
/
