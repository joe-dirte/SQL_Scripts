
create or replace procedure sys.space_mngr_import_fs_info
is
    v_job_name    varchar2(80);
    v_script_name varchar2(256);
    v_db_name     varchar2(30);
begin
    v_job_name    := 'IMPORT_FILESYSTEM_INFO';
    v_script_name := '/opt/app/oracle/bin/import-filesystem-info';
    select lower(name) into v_db_name from v$database;
    begin
        dbms_scheduler.drop_job( v_job_name );
    exception when others then
        null;
    end;
    dbms_scheduler.create_job(
        job_name            => v_job_name,
        job_type            => 'EXECUTABLE',
        number_of_arguments => 2,
        job_action          => v_script_name,
        enabled             => false,
        auto_drop           => true
    );
    dbms_scheduler.set_job_argument_value(
        job_name            => v_job_name,
        argument_position   => 1,
        argument_value      => '--sid'
    );
    dbms_scheduler.set_job_argument_value(
        job_name            => v_job_name,
        argument_position   => 2,
        argument_value      => v_db_name
    );
    dbms_scheduler.run_job( v_job_name );
end;
/

grant execute on sys.space_mngr_import_fs_info to admin;

