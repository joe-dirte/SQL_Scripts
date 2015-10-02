set pages 200 lines 150
col TOTAL_MB format 9999999.00
col USED_MB format 9999999.00
col FREE_MB format 9999999.00
col PCT_FREE format 999.9

select u.tablespace_name
      ,u.size_mb total_mb
      ,u.size_mb-f.free_mb used_mb
      ,f.free_mb
      ,(f.free_mb/u.size_mb)*100 pct_free
from
     (select a.tablespace_name,sum(a.bytes)/1024/1024 size_mb
      from dba_data_files a
      group by a.tablespace_name) u
     ,(select b.tablespace_name,sum(b.bytes)/1024/1024 free_mb
      from dba_free_space b
      group by b.tablespace_name ) f
where u.tablespace_name=f.tablespace_name(+)
and u.tablespace_name='&TS_NAME'
order by 1
/
pause;pause;
 col file_name format a50
   select a.file_id, a.file_name, a.bytes/1024/1024 MB
   from dba_data_files a, v$datafile b
   where b.file#=a.file_id
   and a.tablespace_name = '&tablespace_name';
pause;

!df -g|grep $ORACLE_SID
