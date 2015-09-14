rem ********************************************************************
rem * Author            : Joe Skinner
rem * Description       : Pull the top 20largest objects 
rem * Usage             : SQL> @large_objects
rem ********************************************************************
select * from (
select owner, segment_name,segment_type, bytes/1024/1024/1024 Size_GB from dba_segments order by 
bytes/1024/1024  DESC ) where rownum <= 20;