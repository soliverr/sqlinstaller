--
-- Load initial data into SQLInstalleer configuration table
--

define L_TABLE_NAME = SQLINSTALLER$CONFIG

-- Load if table is empty
declare
  l$cnt  integer := 0;
  l$cntn integer := 0;
begin
  select count(1) into l$cnt from &&L_TABLE_NAME
   where object_name = 'ORADBA_SQLINSTALLER';

  --
  -- Задать действия по умолчанию
  --
  merge into &&L_TABLE_NAME
    using dual
    on ( object_name = 'ORADBA_SQLINSTALLER' and object_type = 'ANY_OBJECT' )
    when matched then update set action=0, value='FALSE'
    when not matched then insert ( object_name, object_type, action, value )
                          values ( 'ORADBA_SQLINSTALLER', 'ANY_OBJECT', 0, 'FALSE'  );

  merge into &&L_TABLE_NAME
    using dual
    on ( object_name = 'ORADBA_SQLINSTALLER' and object_type = 'CHECK_IN_USE' )
    when matched then update set action=0, value='FALSE'
    when not matched then insert ( object_name, object_type, action, value )
                          values ( 'ORADBA_SQLINSTALLER', 'CHECK_IN_USE', 0, 'FALSE'  );


  merge into &&L_TABLE_NAME
    using dual
    on ( object_name = 'ORADBA_SQLINSTALLER' and object_type = 'PACKAGE' )
    when matched then update set action=0, value='FALSE'
    when not matched then insert ( object_name, object_type, action, value )
                          values ( 'ORADBA_SQLINSTALLER', 'PACKAGE', 0, 'FALSE'  );

  merge into &&L_TABLE_NAME
    using dual
    on ( object_name = 'ORADBA_SQLINSTALLER' and object_type = 'PACKAGE_BODY' )
    when matched then update set action=0, value='FALSE'
    when not matched then insert ( object_name, object_type, action, value )
                          values ( 'ORADBA_SQLINSTALLER', 'PACKAGE_BODY', 0, 'FALSE'  );

  merge into &&L_TABLE_NAME
    using dual
    on ( object_name = 'ORADBA_SQLINSTALLER' and object_type = 'TYPE' )
    when matched then update set action=0, value='FALSE'
    when not matched then insert ( object_name, object_type, action, value )
                          values ( 'ORADBA_SQLINSTALLER', 'TYPE', 0, 'FALSE'  );

  merge into &&L_TABLE_NAME
    using dual
    on ( object_name = 'ORADBA_SQLINSTALLER' and object_type = 'TYPE_BODY' )
    when matched then update set action=0, value='FALSE'
    when not matched then insert ( object_name, object_type, action, value )
                          values ( 'ORADBA_SQLINSTALLER', 'TYPE_BODY', 0, 'FALSE'  );

  merge into &&L_TABLE_NAME
    using dual
    on ( object_name = 'ORADBA_SQLINSTALLER' and object_type = 'PROCEDURE' )
    when matched then update set action=0, value='FALSE'
    when not matched then insert ( object_name, object_type, action, value )
                          values ( 'ORADBA_SQLINSTALLER', 'PROCEDURE', 0, 'FALSE'  );

  merge into &&L_TABLE_NAME
    using dual
    on ( object_name = 'ORADBA_SQLINSTALLER' and object_type = 'TABLE' )
    when matched then update set action=0, value='FALSE'
    when not matched then insert ( object_name, object_type, action, value )
                          values ( 'ORADBA_SQLINSTALLER', 'TABLE', 0, 'FALSE'  );

  merge into &&L_TABLE_NAME
    using dual
    on ( object_name = 'ORADBA_SQLINSTALLER' and object_type = 'VIEW' )
    when matched then update set action=0, value='FALSE'
    when not matched then insert ( object_name, object_type, action, value )
                          values ( 'ORADBA_SQLINSTALLER', 'VIEW', 0, 'FALSE'  );

  merge into &&L_TABLE_NAME
    using dual
    on ( object_name = 'ORADBA_SQLINSTALLER' and object_type = 'SEQUENCE' )
    when matched then update set action=0, value='FALSE'
    when not matched then insert ( object_name, object_type, action, value )
                          values ( 'ORADBA_SQLINSTALLER', 'SEQUENCE', 0, 'FALSE'  );

  merge into &&L_TABLE_NAME
    using dual
    on ( object_name = 'ORADBA_SQLINSTALLER' and object_type = 'TRIGGER' )
    when matched then update set action=0, value='FALSE'
    when not matched then insert ( object_name, object_type, action, value )
                          values ( 'ORADBA_SQLINSTALLER', 'TRIGGER', 0, 'FALSE'  );

  merge into &&L_TABLE_NAME
    using dual
    on ( object_name = 'ORADBA_SQLINSTALLER' and object_type = 'SYNONYM' )
    when matched then update set action=0, value='FALSE'
    when not matched then insert ( object_name, object_type, action, value )
                          values ( 'ORADBA_SQLINSTALLER', 'SYNONYM', 0, 'FALSE'  );

  merge into &&L_TABLE_NAME
    using dual
    on ( object_name = 'ORADBA_SQLINSTALLER' and object_type = 'ROLE' )
    when matched then update set action=0, value='FALSE'
    when not matched then insert ( object_name, object_type, action, value )
                          values ( 'ORADBA_SQLINSTALLER', 'ROLE', 0, 'FALSE'  );

  merge into &&L_TABLE_NAME
    using dual
    on ( object_name = 'ORADBA_SQLINSTALLER' and object_type = 'PROFILE' )
    when matched then update set action=0, value='FALSE'
    when not matched then insert ( object_name, object_type, action, value )
                          values ( 'ORADBA_SQLINSTALLER', 'PROFILE', 0, 'FALSE'  );

  merge into &&L_TABLE_NAME
    using dual
    on ( object_name = 'ORADBA_SQLINSTALLER' and object_type = 'USER' )
    when matched then update set action=0, value='FALSE'
    when not matched then insert ( object_name, object_type, action, value )
                          values ( 'ORADBA_SQLINSTALLER', 'USER', 0, 'FALSE'  );

  commit;

  select count(1) into l$cntn from &&L_TABLE_NAME
   where object_name = 'ORADBA_SQLINSTALLER';

  l$cntn := l$cntn - l$cnt;

  dbms_output.put_line( CHR(10) || 'I: ' || l$cntn || ' rows sucessfully loaded');
end;
/

undefine L_TABLE_NAME
