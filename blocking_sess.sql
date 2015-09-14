rem ********************************************************************
rem * Author            : Joe Skinner
rem * Description       : Show all the sessions that have someone waiting on a lock they hold, but that are not themselves waiting on a lock.
rem * Usage             : SQL> @blocking_sess
rem ********************************************************************
col wait_class for a30
select inst_id,BLOCKING_INSTANCE,blocking_session,FINAL_BLOCKING_SESSION_STATUS,FINAL_BLOCKING_INSTANCE,FINAL_BLOCKING_SESSION,sid,serial#,username "waiting_user",wait_class,seconds_in_wait,sql_id
from gv$session where blocking_session is not NULL order by  8,9;
