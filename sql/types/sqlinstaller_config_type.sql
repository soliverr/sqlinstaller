create or replace type sqlinstaller_config_type as object (
   --
   -- Paraneter type for SQLInstaller
   --
   object_name          varchar2(64), -- Object name for this permission
   object_type          varchar2(64), -- Object type for this permission
   action               integer,      -- SQLInstaller action name for this permission
   value                varchar2(64)  -- Permission: Disable (False) / Enable (True) to execute action with given object_type.object_name
) instantiable final;
/
