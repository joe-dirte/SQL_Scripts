rem ********************************************************************
rem * Author            : Joe Skinner
rem * Description       : Show temp allocations and current temp usage
rem * Usage             : SQL> @longops
rem ********************************************************************
set pagesize 60
column "Tablespace" heading "Tablespace Name" format a30
column "Size" heading "Tablespace|Size (mb)" format 9999999.9
column "Used" heading "Used|Space (mb)" format 9999999.9
column "Left" heading "Available|Space (mb)" format 9999999.9
column "PCTFree" heading "% Free" format 999.99

ttitle left "Tablespace Space Allocations"
break on report
-- compute sum of "Size", "Left", "Used" on report
select /*+ RULE */
t.tablespace_name,
NVL(round(((sum(u.blocks)*p.value)/1024/1024),2),0) Used_mb,
t.Tot_MB,
NVL(round(sum(u.blocks)*p.value/1024/1024/t.Tot_MB*100,2),0) "USED %"
from v$sort_usage u,
v$parameter p,
(select tablespace_name,sum(bytes)/1024/1024 Tot_MB
from dba_temp_files
group by tablespace_name
) t
where p.name = 'db_block_size'
and u.tablespace (+) = t.tablespace_name
group by
t.tablespace_name,p.value,t.Tot_MB
order by 1,2;


PROMPT ======================= Total TEMP_TS consuming =======================
select tablespace, sum(blocks)*8192/1024/1024 consuming_TEMP_MB from
v$session, v$sort_usage where tablespace in (select tablespace_name from
dba_tablespaces where contents = 'TEMPORARY') and session_addr=saddr
group by tablespace;


PROMPT ======================= Sessions consuming TEMP_TS more than 10 MB =======================
select sid, tablespace,
sum(blocks)*8192/1024/1024 consuming_TEMP_MB from v$session,
v$sort_usage where tablespace in (select tablespace_name from
dba_tablespaces where contents = 'TEMPORARY') and session_addr=saddr
group by sid, tablespace having sum(blocks)*8192/1024/1024 > 10
order by sum(blocks)*8192/1024/1024 desc ;