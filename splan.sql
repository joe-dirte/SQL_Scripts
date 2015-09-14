rem ********************************************************************
rem * Author            : Joe Skinner
rem * Description       : Show sql plan for a given sqlid
rem * Usage             : SQL> @splan
rem ********************************************************************
select * from table(dbms_xplan.display_cursor('&sql_id',null,'typical'));