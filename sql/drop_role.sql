--
-- Drop role
--
-- Usage: drop_role ROLE_NAME
--

set verify off

col 1 new_value 1
col 2 new_value 2

set feedback off
select NULL "1", NULL "2" from dual where rownum = 0;
set feedback on

declare
  l$cnt integer := 0;
  l$sql varchar2(1024) := 'drop role &1';
begin
  select count(1) into l$cnt
    from sys.dba_roles
   where role = upper('&1');

   if l$cnt > 0 then
     begin
       execute immediate l$sql;
       dbms_output.put_line( CHR(10) || 'I: Role &1 droped' );
     end;
   else
       dbms_output.put_line( CHR(10) || 'W: Role &1 does not exists' );
   end if;
end;
/

undefine 1
