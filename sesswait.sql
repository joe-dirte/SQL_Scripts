rem ********************************************************************
rem * Author		: Joe Skinner
rem * Description	: Show current session waits
rem * Usage		: SQL> @sess_wait
rem ********************************************************************

def aps_prog    = 'sesswait.sql'
def aps_title   = 'Session Wait Information'
start apstitle

col event heading "Event" format a35
#col p1text for a30
#col p2text for a30
col p1 for 999999999999999999999999
col p2 for 999999999999999999999999
col seconds_in_wait heading "Wait|(Sec.)" format 9,999,999
col wait_class for a15
select inst_id,event, 
       sid,
       p1,sql_id,
--       p1text,
     p2,
--       p2text,
SECONDS_IN_WAIT,
state,
wait_time,
wait_class
from gv$session
where event not in ('SQL*Net message from client',
		'SQL*Net message to client',
		'pipe get',
		'pmon timer',
		'rdbms ipc message',
		'Streams AQ: waiting for messages in the queue',
                'Streams AQ: qmn coordinator idle wait',
                'Streams AQ: waiting for time management or cleanup tasks',
		'PL/SQL lock timer',
                'Streams AQ: qmn slave idle wait',
		'jobq slave wait',
		'queue messages',
		'io done',
		'i/o slave wait',
		'sbtwrite2',
		'async disk IO',
		'smon timer')
order by inst_id,event,sql_id;


start apsclear
