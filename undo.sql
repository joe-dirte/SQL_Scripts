rem ********************************************************************
rem * Author            : Joe Skinner
rem * Description       : Pull undo usage
rem * Usage             : SQL> @undo
rem ********************************************************************
select
   s.sid, 
   s.username,
   r.name       "Undo Segment Name", 
   t.start_time,
   t.used_ublk  "Undo blocks",
   t.used_urec  "Undo recs"
 from
   v$session s,
   v$transaction t,
   v$rollname r
 where
   t.addr = s.taddr and
   r.usn  = t.xidusn;


select s.sid||','||s.serial# sessions,start_time, username, r.name,  
ubafil, ubablk, t.status, (used_ublk*p.value)/1024 blk, used_urec,sql_id
from v$transaction t, v$rollname r, v$session s, v$parameter p
where xidusn=usn
and s.saddr=t.ses_addr
and p.name='db_block_size'
order by 8,9;
