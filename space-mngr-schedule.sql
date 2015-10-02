
declare
    v_job_count number;
    v_job_owner varchar2(20);
    v_job_name  varchar2(128);
begin
    v_job_owner := 'ADMIN';
    v_job_name  := 'SPACE_MANAGER_JOB';
    select count(*) into v_job_count from dba_scheduler_jobs where job_name = v_job_name and owner = v_job_owner;
    if v_job_count < 1 then
        dbms_scheduler.create_job(
            job_name        => v_job_owner || '.' || v_job_name,
            job_type        => 'PLSQL_BLOCK',
            job_action      => 'BEGIN ADMIN.SPACE_MNGR.RUN_SPACE_MNGR( P_IMPORT_FS_INFO => TRUE ); END;',
            start_date      => systimestamp,
            repeat_interval => 'freq=minutely; bysecond=45; interval=10',
            end_date        => null,
            enabled         => true
        );
    end if;
end;
/

exec admin.space_mngr.set_parameter( 'p_import_fs_info', 'yes' );

delete from admin.space_adder_disable_tool;
insert into admin.space_adder_disable_tool values ( 'Y' );
commit;
