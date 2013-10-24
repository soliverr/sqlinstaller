set verify off
set echo off
set serveroutput on size 20000
set time off
set timing on
set pagesize 0
set linesize 256
set trimout on
set trimspool on
set sqlprompt 'sqlinstaller>'

whenever sqlerror exit sql.sqlcode

prompt
