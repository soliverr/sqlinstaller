create or replace package body sqlinstaller as
------------------------------------------------------------------------------------------------
--
-- SQLInstaller package
--
--
-- Copyright (c) 2010, Kryazhevskikh Sergey, <soliverr@gmail.com>
--
------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------
-- Internal procedures
------------------------------------------------------------------------------------------------
--
-- Get owner name of OWNER.OBJECT object
function get_owner( objname IN varchar2 ) return varchar2
as
  t$owner varchar2(128);
  i$i     integer;
begin
   if objname is NULL then
      i$i := 0;
   else
      i$i := instr(objname,'.');
   end if;

   if i$i = 0 then
      t$owner := sys_context( 'userenv', 'session_user' );
   else
      t$owner := substr(objname, 1, i$i - 1);
   end if;

   return upper(t$owner);
end get_owner;

--
-- Get object name of OWNER.OBJECT object
function get_name( objname IN varchar2 ) return varchar2
as
  t$name varchar2(128);
  i$i     integer;
begin
   if objname is NULL then
      i$i := 0;
   else
      i$i := instr(objname,'.');
   end if;

   if i$i = 0 then
     t$name := objname;
   else
     t$name := substr(objname, i$i + 1);
   end if;

   return upper(t$name);
end get_name;

function check_in_use( otype IN sqlinstaller$config.object_name%type,
                       name IN varchar2 ) return integer
as
  l$par   sqlinstaller_config_type;
  l$rc    integer :=0;
begin
  l$par := sqlinstaller_config_type( p_object_name, p_inuse, action_any, disabled );

  if cfg_get_value( l$par ) = TRUE then
    -- FIXME: Check if object is in use
    NULL;
  end if;

  return l$rc;
end check_in_use;

--
-- Output line to dbms_output
--
procedure do_dbms_output( str IN varchar2 ) as
begin
   -- FIXME: Split long lines by 250 char chunks
   dbms_output.put_line( str );
end do_dbms_output;

--
-- Actions with database object
--
function do_object( action IN sqlinstaller$config.action%type,
                    otype  IN sqlinstaller$config.object_type%type,
                    name   IN sqlinstaller$config.object_name%type,
                    script IN varchar2 ) return varchar2
as
  l$par   sqlinstaller_config_type;
  run$c   varchar2(3000) := NULL;
  cnt$i   integer        := 0;
  chr$c   char(1);
  l$ex    boolean;
  l$act   boolean;
begin
   run$c := CHR(10);

   if name is NULL or otype is NULL then
     return run$c;
   end if;

   cnt$i := nvl(instr( script, '@' ), 0);
   if cnt$i = 1 then
     chr$c := NULL;
   else
     chr$c := '@';
   end if;

   if otype = p_package or otype = p_package_body or
      otype = p_type or otype = p_type_body or
      otype = p_table or otype = p_view or otype = p_synonym
   then
     if chk_synonym( name ) = TRUE then
       run$c := run$c ||
                'exec dbms_output.put_line( CHR(10)||''W: ' || otype || ' NAME ' ||
                get_owner(name) || '.' || get_name(name) ||
                ' ALREADY EXISTS as SYNONYM name'');';
       return run$c;
     end if;
   end if;

   -- Check object existence
   l$ex := case otype
      when p_package      then chk_package( name )
      when p_package_body then chk_package_body( name )
      when p_type         then chk_type( name )
      when p_type_body    then chk_type_body( name )
      when p_procedure    then chk_procedure( name )
      when p_trigger      then chk_trigger( name )
      when p_synonym      then chk_synonym( name )
      when p_sequence     then chk_sequence( name )
      when p_table        then chk_table( name )
      when p_view         then chk_view( name )
      when p_role         then chk_role( name )
      when p_profile      then chk_profile( name )
      when p_user         then chk_user( name )
      else                     TRUE
   end;

   -- Get permissions for this objects
   l$par := sqlinstaller_config_type(name, otype, action, disabled );
   l$act := cfg_get_value( l$par );

   if l$ex = TRUE then
     -- Object exists
     if check_in_use( p_package, name ) > 0 then
       run$c := run$c ||
                'exec dbms_output.put_line( CHR(10)||''W: ' || otype || ' ' ||
                get_owner(name) || '.' || get_name(name) ||
                ' IS USED NOW'');';
     else
       -- Object is not used
       if l$act = FALSE and (action = action_drop or action = action_modify) then
         -- Actions disabled in SQLInstaller configuration table
         run$c := run$c ||
                  'exec dbms_output.put_line( CHR(10)||''W: Drop/Modify action for ' || otype || ' ' ||
                  get_owner(name) || '.' || get_name(name) ||
                  ' IS DISABLED by SQLInstaller configuration'');';
       elsif action = action_drop then
         run$c := run$c || chr$c || nvl(script, datadir || '/drop_' || lower(otype)) || ' '
                  || get_name(name) || ' ' || get_owner(name);
       elsif action = action_modify then
         run$c := run$c || chr$c || nvl(script, datadir || '/empty');
         run$c := run$c || chr(10) ||
                  'exec dbms_output.put_line( CHR(10)||''I: ' || otype || ' ' ||
                  get_owner(name) || '.' || get_name(name) ||
                  ' MODIFIED'');';
       elsif action = action_create then
         run$c := run$c ||
                  'exec dbms_output.put_line( CHR(10)||''W: ' || otype || ' ' ||
                  get_owner(name) || '.' || get_name(name) ||
                  ' ALREADY EXISTS'');';
       end if;
     end if;
   else
     -- Object is not exists
     if l$act = FALSE and (action = action_create or action = action_modify) then
       -- Actions disabled in SQLInstaller configuration table
       run$c := run$c ||
                'exec dbms_output.put_line( CHR(10)||''W: Create/modify action for ' || otype || ' ' ||
                get_owner(name) || '.' || get_name(name) ||
                ' IS DISABLED by SQLInstaller configuration'');';
     elsif action = action_create or action = action_modify then
       run$c := run$c || chr$c || nvl(script, datadir || '/empty');
       run$c := run$c || chr(10) ||
                'exec dbms_output.put_line( CHR(10)||''I: ' || otype || ' ' ||
                      get_owner(name) || '.' || get_name(name) ||
                      ' CREATED'');';
     end if;
   end if;

   return run$c;

end do_object;


------------------------------------------------------------------------------------------------
-- Public procedures
------------------------------------------------------------------------------------------------
--
-- Set configuration parameter
--
procedure cfg_set( parameter sqlinstaller_config_type ) as
 l$par sqlinstaller_config_type;
begin
  -- Values normalization
  l$par := sqlinstaller_config_type( upper(parameter.object_name),
                                     upper(parameter.object_type),
                                     parameter.action,
                                     case upper( parameter.value )
                                       when enabled then enabled
                                       else              disabled
                                     end );

  if parameter.action >= 0 and parameter.action <= action_modify then
    l$par.action := parameter.action;
  else
    l$par.action := action_any;
  end if;

  merge into sqlinstaller$config
    using dual
    on ( object_name = l$par.object_name and object_type = l$par.object_type )
    when matched then update set action=l$par.action, value=l$par.value
    when not matched then insert ( object_name, object_type, action, value )
             values ( l$par.object_name, l$par.object_type, l$par.action, l$par.value );
  commit;
end cfg_set;

--
-- Get configuration parameter
--
function cfg_get( parameter sqlinstaller_config_type) return sqlinstaller_config_type as
 l$val sqlinstaller$config%rowtype;
 l$par sqlinstaller_config_type;
begin
  -- Values normalization
  l$par := sqlinstaller_config_type( upper(parameter.object_name),
                                     upper(parameter.object_type),
                                     parameter.action,
                                     case upper( parameter.value )
                                       when enabled then enabled
                                       else              disabled
                                     end );
  if parameter.action >= 0 and parameter.action <= action_modify then
    l$par.action := parameter.action;
  else
    l$par.action := action_any;
  end if;

  begin
    select object_name, object_type, action, value into l$val from (
      --
      -- Find permissions for given database objects
      -- OBJECT_NAME  OBJECT_TYPE  OBJECT_ACTION
      select 0 idx, object_name, object_type, action, value  from sqlinstaller$config
       where object_name = l$par.object_name and object_type = l$par.object_type and action=l$par.action
      union
        -- OBJECT_NAME  OBJECT_TYPE  'ANY ACTION'
        select 1 idx, object_name, object_type, action, value  from sqlinstaller$config
         where object_name = l$par.object_name and object_type = l$par.object_type and action=action_any
        union
        -- OBJECT_NAME  'ANY TYPE'  OBJECT_ACTION
        select 2 idx, object_name, object_type, action, value  from sqlinstaller$config
         where object_name = l$par.object_name and object_type = p_any_type and action=l$par.action
        union
        -- OBJECT_NAME  'ANY TYPE'  'ANY ACTION'
        select 3 idx, object_name, object_type, action, value  from sqlinstaller$config
         where object_name = l$par.object_name and object_type = p_any_type and action=action_any
        --
        -- Find default permissions
        --
        union
        -- 'ANY OBJECT NAME'  OBJECT_TYPE  OBJECT_ACTION
        select 10 idx, object_name, object_type, action, value  from sqlinstaller$config
         where object_name = p_object_name and object_type = l$par.object_type and action=l$par.action
        union
        -- 'ANY OBJECT NAME'  OBJECT_TYPE  'ANY ACTION'
        select 11 idx, object_name, object_type, action, value  from sqlinstaller$config
         where object_name = p_object_name and object_type = l$par.object_type and action=action_any
        union
        -- 'ANY OBJECT NAME'  'ANY TYPE'  OBJECT_ACTION
        select 12 idx, object_name, object_type, action, value  from sqlinstaller$config
         where object_name = p_object_name and object_type = p_any_type and action=l$par.action
        union
        -- 'ANY OBJECT NAME'  'ANY TYPE'  'ANY ACTION'
        select 13 idx, object_name, object_type, action, value  from sqlinstaller$config
         where object_name = p_object_name and object_type = p_any_type and action=action_any
    ) where rownum < 2;

    l$par.object_name := l$val.object_name;
    l$par.object_type := l$val.object_type;
    l$par.action      := l$val.action;
    l$par.value       := l$val.value;
  exception
    when NO_DATA_FOUND then
      l$par.value := disabled;
  end;

  return l$par;
end cfg_get;

--
-- Get configuration parameter value
--
function cfg_get_value( parameter sqlinstaller_config_type) return boolean as
 l$par sqlinstaller_config_type;
 l$rc boolean;
begin
  l$par := sqlinstaller_config_type(parameter.object_name, parameter.object_type,
                                    parameter.action, parameter.value );
  l$par := cfg_get( parameter );
  l$rc := case l$par.value
           when enabled then TRUE
           else              FALSE
          end;

  return l$rc;
end cfg_get_value;

--
-- Check if database object is in use
--
function is_object_in_use( otype IN varchar2, name IN varchar2 ) return integer as
begin
  return check_in_use( otype, name );
end is_object_in_use;
--
function is_object_in_use( otype IN varchar2, name IN varchar2 ) return boolean as
begin
  if check_in_use( otype, name ) > 0 then
    return TRUE;
  end if;

  return FALSE;
end is_object_in_use;

--
-- Support for package header actions
--
function chk_package( name varchar2 ) return boolean as
  run$c   varchar2(3000) := NULL;
  cnt$i   integer        := 0;
begin
   if name is NULL then
     return FALSE;
   end if;

   run$c := 'select count(1)
               from sys.all_procedures
              where object_name = :n
                and owner = :o
                and procedure_name is not NULL';

   execute immediate run$c into cnt$i using get_name(name), get_owner(name);

   if cnt$i > 0 then
     return TRUE;
   end if;

   return FALSE;
end chk_package;

procedure do_package( action IN integer, name IN varchar2, script IN varchar2 default NULL ) as
begin
   do_dbms_output( do_object(action, p_package, name, script) );
end do_package;

--
-- Support for package body actions
--
function chk_package_body( name varchar2 ) return boolean as
  run$c   varchar2(3000) := NULL;
  cnt$i   integer        := 0;
begin
   if name is NULL then
     return FALSE;
   end if;

   run$c := 'select count(1)
               from sys.all_objects
              where object_name = :n
                and owner = :o
                and object_type = ''PACKAGE BODY''';

   execute immediate run$c into cnt$i using get_name(name), get_owner(name);

   if cnt$i > 0 then
     return TRUE;
   end if;

   return FALSE;
end chk_package_body;

procedure do_package_body( action IN integer, name IN varchar2, script IN varchar2 default NULL ) as
begin
   do_dbms_output( do_object(action, p_package_body, name, script) );
end do_package_body;

--
-- Support for type header actions
--
function chk_type( name varchar2 ) return boolean as
  run$c   varchar2(3000) := NULL;
  cnt$i   integer        := 0;
begin
   if name is NULL then
     return FALSE;
   end if;

   run$c := 'select count(1)
               from sys.all_types
              where type_name = :n
                and owner = :o';

   execute immediate run$c into cnt$i using get_name(name), get_owner(name);

   if cnt$i > 0 then
     return TRUE;
   end if;

   return FALSE;
end chk_type;

procedure do_type( action IN integer, name IN varchar2, script IN varchar2 default NULL ) as
begin
   do_dbms_output( do_object(action, p_type, name, script) );
end do_type;

--
-- Support for type body actions
--
function chk_type_body( name varchar2 ) return boolean as
  run$c   varchar2(3000) := NULL;
  cnt$i   integer        := 0;
begin
   if name is NULL then
     return FALSE;
   end if;

   run$c := 'select count(1)
               from sys.all_objects
              where object_name = :n
                and owner = :o
                and object_type = ''TYPE BODY''';

   execute immediate run$c into cnt$i using get_name(name), get_owner(name);

   if cnt$i > 0 then
     return TRUE;
   end if;

   return FALSE;
end chk_type_body;

procedure do_type_body( action IN integer, name IN varchar2, script IN varchar2 default NULL ) as
begin
   do_dbms_output( do_object(action, p_type_body, name, script) );
end do_type_body;

--
-- Support for procedure actions
--
function chk_procedure( name varchar2 ) return boolean as
  run$c   varchar2(3000) := NULL;
  cnt$i   integer        := 0;
begin
   if name is NULL then
     return FALSE;
   end if;

   run$c := 'select count(1)
               from sys.all_procedures
              where object_name = :n
                and owner = :o
                and procedure_name is NULL';

   execute immediate run$c into cnt$i using get_name(name), get_owner(name);

   if cnt$i > 0 then
     return TRUE;
   end if;

   return FALSE;
end chk_procedure;

procedure do_procedure( action IN integer, name IN varchar2, script IN varchar2 default NULL ) as
begin
   do_dbms_output( do_object(action, p_procedure, name, script) );
end do_procedure;

--
-- Support for trigger actions
--
function chk_trigger( name varchar2 ) return boolean as
  run$c   varchar2(3000) := NULL;
  cnt$i   integer        := 0;
begin
   if name is NULL then
     return FALSE;
   end if;

   run$c := 'select count(1)
               from sys.all_triggers
              where trigger_name = :n
                and owner = :o';

   execute immediate run$c into cnt$i using get_name(name), get_owner(name);

   if cnt$i > 0 then
     return TRUE;
   end if;

   return FALSE;
end chk_trigger;

procedure do_trigger( action IN integer, name IN varchar2, script IN varchar2 default NULL ) as
begin
   do_dbms_output( do_object(action, p_trigger, name, script) );
end do_trigger;

--
-- Support for table actions
--
function chk_table( name varchar2 ) return boolean as
  run$c   varchar2(3000) := NULL;
  cnt$i   integer        := 0;
begin
   if name is NULL then
     return FALSE;
   end if;

   run$c := 'select count(1)
               from sys.all_tables
              where table_name = :n
                and owner = :o';

   execute immediate run$c into cnt$i using get_name(name), get_owner(name);

   if cnt$i > 0 then
     return TRUE;
   end if;

   return FALSE;
end chk_table;

procedure do_table( action IN integer, name IN varchar2, script IN varchar2 default NULL ) as
begin
   do_dbms_output( do_object(action, p_table, name, script) );
end do_table;

--
-- Support for view actions
--
function chk_view( name varchar2 ) return boolean as
  run$c   varchar2(3000) := NULL;
  cnt$i   integer        := 0;
begin
   if name is NULL then
     return FALSE;
   end if;

   run$c := 'select count(1)
               from sys.all_views
              where view_name = :n
                and owner = :o';

   execute immediate run$c into cnt$i using get_name(name), get_owner(name);

   if cnt$i > 0 then
     return TRUE;
   end if;

   return FALSE;
end chk_view;

procedure do_view( action IN integer, name IN varchar2, script IN varchar2 default NULL ) as
begin
   do_dbms_output( do_object(action, p_view, name, script) );
end do_view;

--
-- Support for synonym actions
--
function chk_synonym( name varchar2 ) return boolean as
  run$c   varchar2(3000) := NULL;
  cnt$i   integer        := 0;
begin
   if name is NULL then
     return FALSE;
   end if;

   run$c := 'select count(1)
               from sys.all_synonyms
              where synonym_name = :n
                and owner = :o';

   execute immediate run$c into cnt$i using get_name(name), get_owner(name);

   if cnt$i > 0 then
     return TRUE;
   end if;

   return FALSE;
end chk_synonym;

procedure do_synonym( action IN integer, name IN varchar2, script IN varchar2 default NULL ) as
begin
   do_dbms_output( do_object(action, p_synonym, name, script) );
end do_synonym;

--
-- Support for sequence actions
--
function chk_sequence( name varchar2 ) return boolean as
  run$c   varchar2(3000) := NULL;
  cnt$i   integer        := 0;
begin
   if name is NULL then
     return FALSE;
   end if;

   run$c := 'select count(1)
               from sys.all_sequences
              where sequence_name = :n
                and sequence_owner = :o';

   execute immediate run$c into cnt$i using get_name(name), get_owner(name);

   if cnt$i > 0 then
     return TRUE;
   end if;

   return FALSE;
end chk_sequence;

procedure do_sequence( action IN integer, name IN varchar2, script IN varchar2 default NULL ) as
begin
   do_dbms_output( do_object(action, p_sequence, name, script) );
end do_sequence;

--
-- Support for role actions
--
function chk_role( name varchar2 ) return boolean as
  run$c   varchar2(3000) := NULL;
  cnt$i   integer        := 0;
begin
   if name is NULL then
     return FALSE;
   end if;

   run$c := 'select count(1)
               from sys.dba_roles
              where role = :n';

   execute immediate run$c into cnt$i using upper(name);

   if cnt$i > 0 then
     return TRUE;
   end if;

   return FALSE;
end chk_role;

procedure do_role( action IN integer, name IN varchar2, script IN varchar2 default NULL ) as
begin
   do_dbms_output( do_object(action, p_role, name, script) );
end do_role;

--
-- Support for profile actions
--
function chk_profile( name varchar2 ) return boolean as
  run$c   varchar2(3000) := NULL;
  cnt$i   integer        := 0;
begin
   if name is NULL then
     return FALSE;
   end if;

   run$c := 'select count(1)
               from sys.dba_profiles
              where profile = :n';

   execute immediate run$c into cnt$i using get_name(name);

   if cnt$i > 0 then
     return TRUE;
   end if;

   return FALSE;
end chk_profile;

procedure do_profile( action IN integer, name IN varchar2, script IN varchar2 default NULL ) as
begin
   do_dbms_output( do_object(action, p_profile, name, script) );
end do_profile;

--
-- Support for user actions
--
function chk_user( name varchar2 ) return boolean as
  run$c   varchar2(3000) := NULL;
  cnt$i   integer        := 0;
begin
   if name is NULL then
     return FALSE;
   end if;

   run$c := 'select count(1)
               from sys.all_users
              where username = :n';

   execute immediate run$c into cnt$i using get_name(name);

   if cnt$i > 0 then
     return TRUE;
   end if;

   return FALSE;
end chk_user;

procedure do_user( action IN integer, name IN varchar2, script IN varchar2 default NULL ) as
begin
   do_dbms_output( do_object(action, p_user, name, script) );
end do_user;

begin
  NULL;
end;
/
