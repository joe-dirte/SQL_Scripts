
-- FIXME: Ensure we are running as SYSDBA, because the import procedure requires it.
DECLARE
    v_is_partitioned VARCHAR2 (15) := '';
BEGIN
    BEGIN
        /* Create Admin.SPACE_MNGR_FILESYSTEM_INFO*/
        SELECT partitioned
        INTO   v_is_partitioned
        FROM   dba_tables
        WHERE  table_name = 'SPACE_MNGR_FILESYSTEM_INFO';
    EXCEPTION
        WHEN no_data_found THEN
          v_is_partitioned := 'NO TABLE';
    END;

    IF v_is_partitioned = 'NO' THEN
      dbms_output.put_line( 'Dropping table admin.space_mngr_filesystem_info' );
      EXECUTE IMMEDIATE 'drop table admin.space_mngr_filesystem_info';
      v_is_partitioned := 'NO TABLE';
    END IF;
    IF v_is_partitioned = 'NO TABLE' THEN
      dbms_output.put_line( 'Creating table admin.space_mngr_filesystem_info' );
      EXECUTE IMMEDIATE 'create table admin.space_mngr_filesystem_info (
      collection_date      date,
      host_name            varchar2(60),
      filesystem           varchar2(60),
      available_space_megs integer,
      used_space_megs      integer,
      total_space_megs     integer,
      used_pct             integer,
      real_path            varchar2(255),
      real_mount_point     varchar2(60) )
      tablespace administrator
      partition by range (collection_date)
      (     partition space_mngr_fsinfo_20090115 values less than (to_date('' 2009-01-16 00:00:00'', ''syyyy-mm-dd hh24:mi:ss'', ''nls_calendar=gregorian'')) )';

      EXECUTE IMMEDIATE 'create unique index admin.ui_space_mngr_fsinfo on admin.space_mngr_filesystem_info ( collection_date, host_name, filesystem ) tablespace administrator_idx local';
    END IF;

    BEGIN
        /* Create admin.space_mngr_decision_log*/
        SELECT partitioned
        INTO   v_is_partitioned
        FROM   dba_tables
        WHERE  table_name = 'SPACE_MNGR_DECISION_LOG';
    EXCEPTION
        WHEN no_data_found THEN
          v_is_partitioned := 'NO TABLE';
    END;

    IF v_is_partitioned = 'NO' THEN
      dbms_output.put_line( 'Dropping table admin.space_mngr_decision_log' );
      EXECUTE IMMEDIATE 'drop table admin.SPACE_MNGR_DECISION_LOG';
      v_is_partitioned := 'NO TABLE';
    END IF;
    IF v_is_partitioned = 'NO TABLE' THEN
      dbms_output.put_line( 'Creating table admin.space_mngr_decision_log' );
      EXECUTE IMMEDIATE 'create table admin.space_mngr_decision_log (
      execution_id     integer,
      decision_time    date,
      decision_id      integer,
      decision_name    varchar2(30),
      decision_status  varchar2(255),
      decision_details varchar2(500) )
      tablespace administrator
      partition by range (decision_time)
      (     partition space_mngr_log_20090115 values less than (to_date('' 2009-01-16 00:00:00'', ''syyyy-mm-dd hh24:mi:ss'', ''nls_calendar=gregorian'')) )';

      EXECUTE IMMEDIATE 'create index admin.i_space_mngr_decision on admin.space_mngr_decision_log ( decision_time, decision_name ) tablespace administrator_idx local';
    END IF;
END;
/

insert into db_rolling_partitions (owner, table_name,partition_name_prefix, rolling_partition_type,retain_num_partitions, pre_create_num_partitions,disable_rep_triggers_on_move)
VALUES ('ADMIN', 'SPACE_MNGR_FILESYSTEM_INFO', 'SPACE_MNGR_FSINFO', 'DAILY', 14, 5,'N');
commit;

exec rolling_partition_util.manage_rolling_partitions('ADMIN','SPACE_MNGR_FILESYSTEM_INFO');

insert into db_rolling_partitions (owner, table_name,partition_name_prefix, rolling_partition_type,retain_num_partitions, pre_create_num_partitions,disable_rep_triggers_on_move)
VALUES ('ADMIN', 'SPACE_MNGR_DECISION_LOG', 'SPACE_MNGR_LOG', 'DAILY', 14, 5,'N');
commit;

exec rolling_partition_util.manage_rolling_partitions('ADMIN','SPACE_MNGR_DECISION_LOG');

create table admin.space_mngr_configuration (
    parameter_name    varchar2(30)  not null,
    parameter_value   varchar2(30)  not null,
    tablespace_name   varchar2(30)      null,
    filesystem_prefix varchar2(128)     null
) tablespace administrator;

create unique index admin.ui_space_mngr_cfg
on admin.space_mngr_configuration ( parameter_name, tablespace_name, filesystem_prefix )
tablespace administrator_idx;

@@space-mngr-views.sql

@@space-mngr-import.sql

@@space-mngr.pkg

grant alter tablespace to admin;
grant alter system to admin;

exec admin.space_mngr.set_parameter( 'p_file_size_m', 4096, 'SYSAUX' );
exec admin.space_mngr.set_parameter( 'p_file_size_m', 4096, 'SYSTEM' );
exec admin.space_mngr.set_parameter( 'p_file_size_m', 4096, 'ORA_AUD' );
exec admin.space_mngr.set_parameter( 'p_prefer_resize', 'YES' );

insert into admin.space_adder_disable_tool values ( 'Y' );
commit;
