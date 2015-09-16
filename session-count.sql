rem ********************************************************************
rem * Author            : Joe Skinner
rem * Description       : Show session count by module and username
rem * Usage             : SQL> @longops
rem ********************************************************************
col username for a60
col module for a70
select count(*) , module , username from v$session group by module, username order by 2,3;
