--
-- Drop view
--
-- Usage: drop_view VIEW_NAME [SCHEMA]
--

set verify off

col 1 new_value 1
col 2 new_value 2

set feedback off
select NULL "1", NULL "2" from dual where rownum = 0;
set feedback on

declare
  l$cnt    integer := 0;
  l$schema varchar2(64);
begin
  -- Current schema
  if length('&2') > 0 then
     l$schema := '&2';
  else
     select sys_context( 'userenv', 'current_schema' ) into l$schema from dual;
  end if;

  select count(1) into l$cnt
    from sys.all_views
   where view_name = upper('&1')
     and owner = l$schema;

   if l$cnt > 0 then
     execute immediate 'drop view ' || l$schema || '.' || '&1';
     dbms_output.put_line( CHR(10) || 'I: View ' || l$schema || '.' || upper('&1') || ' droped' );
   else
     dbms_output.put_line( CHR(10) || 'W: View ' || l$schema || '.' || upper('&1') || ' does not exists' );
   end if;
end;
/

undefine 1 2
