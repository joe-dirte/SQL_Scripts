rem ********************************************************************
rem * Author            : Joe Skinner
rem * Description       : Show all the sessions that have someone waiting on a lock they hold, but that are not themselves waiting on a lock.
rem * Usage             : SQL> @blockers
rem ********************************************************************

select /*+ordered */ distinct s.ksusenum holding_session
  from v$session_wait w, x$ksqrs r, v$_lock l, x$ksuse s
 where w.wait_Time = 0
   and w.event = 'enqueue'
   and r.ksqrsid1 = w.p2
   and r.ksqrsid2 = w.p3
   and r.ksqrsidt = chr(bitand(p1,-16777216)/16777215)||
                   chr(bitand(p1,16711680)/65535)
   and l.block = 1
   and l.saddr = s.addr
   and l.raddr = r.addr
   and s.inst_id = userenv('Instance');
