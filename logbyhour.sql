rem ********************************************************************
rem * Author            : Joe Skinner
rem * Description       : Show redo log generation by hour
rem * Usage             : SQL> @blockers
rem ********************************************************************

def aps_prog    = 'logbyhour.sql'
def aps_title   = 'Redo Log Generation by Hour'
start apstitle

set verify off
column hour heading "Hour" format a15
column numlogs heading "Logs" format 9,999
select to_char(first_Time, 'DD-MON-YYYY HH24') hour, count(*) numlogs
from v$log_history
where first_Time > sysdate - 10
group by to_char(first_Time, 'DD-MON-YYYY HH24')
order by to_date(to_char(first_Time, 'DD-MON-YYYY HH24'), 'DD-MON-YYYY HH24') asc
/
start apsclear