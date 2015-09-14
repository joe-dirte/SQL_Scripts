rem ********************************************************************
rem * Author		: Joe Skinner
rem * Description	: Show current running sqls
rem * Usage		: SQL> @rsqls
rem ********************************************************************
col FIRST_LOAD_TIME form a18
select inst_id,sql_id,users_executing,ROWS_PROCESSED,EXECUTIONS,PLAN_HASH_VALUE,SORTS,VERSION_COUNT,LAST_LOAD_TIME,
INVALIDATIONS,PARSE_CALLS,DISK_READS,BUFFER_GETS,round(CPU_TIME/1000000) CPU_ms,sql_text
from gv$sqlarea
where users_executing >0 
order by 3 desc;