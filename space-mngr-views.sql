
create or replace view admin.space_mngr_tablespace_info as
        with next_extents as (
                  select /*+ materialize */ t.tablespace_name,
                         max(round(nvl(nvl(s.next_extent,t.initial_extent),0)*(1+nvl(nvl(s.pct_increase,t.pct_increase),0)/100.0))) max_next_extent,
                         sum(nvl2(s.segment_type,1,0)) as num_segments
                    from dba_tablespaces t,
                         dba_segments s
                   where t.tablespace_name = s.tablespace_name (+)
                   group by t.tablespace_name),
             free_space as (
                    select /*+ materialize */ tablespace_name,
                           sum(nvl(bytes,0)) free_bytes
                      from dba_free_space f
                     group by tablespace_name),
             average_growth as (
                    select /*+ materialize */ tablespace_name,
                           round(avg(used_space_bytes_growth)) as avg_daily_growth
                      from admin.db_tablespace_size_log
                     where collection_date > sysdate - 14
                     group by tablespace_name),
             average_file_size as (
                    select /*+ materialize */ tablespace_name,
                           count(*) as num_files,
                           sum(bytes) as alloc_bytes,
                           max(bytes) as max_file_size,
                           case when tablespace_name in ( 'SYSTEM', 'SYSAUX' ) then  1024*1024*1024
                                when avg(bytes)/1024/1024 > 16384              then 16384*1024*1024
                                when avg(bytes)/1024/1024 >  8192              then  8192*1024*1024
                                else                                                 4096*1024*1024
                           end as next_file_size
                      from dba_data_files
                     group by tablespace_name),
             config_file_size as (
                    select tablespace_name, to_number(parameter_value) as config_file_size
                      from admin.space_mngr_configuration
                     where parameter_name = 'p_file_size_m')
        select t.tablespace_name                                                as tablespace_name,
               round(((fs.alloc_bytes-f.free_bytes)/fs.alloc_bytes)*100)        as perc_util,
               round(fs.alloc_bytes/1024/1024)                                  as alloc_mbytes,
               round(nvl(f.free_bytes/1024/1024,0))                             as free_mbytes,
               fs.num_files                                                     as num_files,
               m.num_segments                                                   as num_segments,
	           nvl(m.max_next_extent,1048576)/1024                              as next_extent_kb,
               trunc(nvl(f.free_bytes,0)/nvl(m.max_next_extent,1048576))        as free_extents,
               least(65536,round(f.free_bytes/greatest(1,ag.avg_daily_growth))) as days_left,
               round(fs.max_file_size/1024/1024)                                as max_file_size_mb,
               nvl(cfs.config_file_size,round(fs.next_file_size/1024/1024))     as next_file_size_mb
          from dba_tablespaces t,
               next_extents m,
               free_space f,
               average_growth ag,
               average_file_size fs,
               config_file_size cfs
         where t.tablespace_name = f.tablespace_name  (+)
           and t.tablespace_name = ag.tablespace_name (+)
           and t.tablespace_name = fs.tablespace_name (+)
           and t.tablespace_name = m.tablespace_name  (+)
           and t.tablespace_name = cfs.tablespace_name (+)
           and t.contents = 'PERMANENT'
         order by t.tablespace_name;

create or replace view admin.space_mngr_filesystem_usage as
        with fs_allocation as (
                select fs,
                       sum(case when is_new = 1 then mbytes else 0 end) as mbytes,
                       count(*) as num_files,
                       sum(is_new) as new_files
                  from (
                        select name,
                               regexp_replace( name, '^(/[^/]+)/.*', '\1' ) as fs,
                               bytes/1024/1024 as mbytes,
                               case when creation_time > (select max(collection_date) from admin.space_mngr_filesystem_info) then 1 else 0 end as is_new
                          from v$datafile
                        union
                        select name,
                               regexp_replace( name, '^(/[^/]+)/.*', '\1' ) as fs,
                               bytes/1024/1024 as mbytes,
                               case when creation_time > (select max(collection_date) from admin.space_mngr_filesystem_info) then 1 else 0 end as is_new
                          from v$tempfile
                       )
                 group by fs
        ),
        space_maximums as (
                select parameter_name,
                       parameter_value,
                       filesystem_prefix
                  from admin.space_mngr_configuration
                 where parameter_name = 'p_filesystem_max_megs'
        )
        select sa.filesystem,
               falloc.num_files,
	       falloc.new_files,
	       -- FIXME: available space does not take max allocation into account
               sa.available_space_megs - nvl(falloc.mbytes,0) as available_space_megs,
               sa.used_space_megs + nvl(falloc.mbytes,0) as used_space_megs,
               sa.total_space_megs,
               round(((sa.used_space_megs + nvl(falloc.mbytes,0))/sa.total_space_megs)*100) as used_pct,
               nvl(falloc.mbytes,0) as new_allocation_megs,
               case when ( falloc.num_files > 0 or sa.filesystem like '/fs-%' )
                    then to_number(nvl(sm.parameter_value,sa.total_space_megs))
                    else to_number(nvl(sm.parameter_value,0)) end as max_allocation_megs
          from admin.space_mngr_filesystem_info sa
          left outer join fs_allocation falloc on sa.filesystem = falloc.fs
          left outer join space_maximums sm on regexp_like(sa.filesystem,sm.filesystem_prefix)
         where sa.collection_date = (select max(collection_date) from admin.space_mngr_filesystem_info)
       ;

