--
-- SQLInstaller permissions (configuration) table
--

define L_TABLE_NAME = SQLINSTALLER$CONFIG

declare
  l$cnt integer := 0;

  l$sql varchar2(1024) := '
create table &&L_TABLE_NAME  (
   object_name          VARCHAR2(64) not null,
   object_type          VARCHAR2(64) not null,
   action               INTEGER not null,
   value                VARCHAR2(64) not null,
   constraint pk_sqlinstaller$config primary key (object_name, object_type)
)';

begin
  select count(1) into l$cnt
    from sys.all_tables
   where table_name = '&&L_TABLE_NAME'
     and owner = upper('&&ORA_SCHEMA_OWNER');

   if l$cnt = 0 then
     begin
       execute immediate l$sql || ' tablespace &&ORA_TBSP_TBLS';
       dbms_output.put_line( CHR(10) || 'I: Table &&L_TABLE_NAME created' );
     end;

     --
     -- Table's indexes
     execute immediate '
     create index &&L_TABLE_NAME'||'_act on "&&L_TABLE_NAME" (
        action
     ) tablespace &&ORA_TBSP_INDX';
   else
       dbms_output.put_line( CHR(10) || 'W: Table &&L_TABLE_NAME already exists' );
   end if;
end;
/

comment on table "&&L_TABLE_NAME" is
'SQLInstaller permissions table';

comment on column "&&L_TABLE_NAME".object_name is
'Object name for this permissions';

comment on column "&&L_TABLE_NAME".object_type is
'Object type for this permissions';

comment on column "&&L_TABLE_NAME".action is
'SQLInstaller action name for this permissions';

comment on column "&&L_TABLE_NAME".value is
'Permission: Disable (False) / Enable (True) to execute action with given object_type.object_name';

undefine L_TABLE_NAME
