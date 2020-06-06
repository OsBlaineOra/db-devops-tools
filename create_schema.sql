DROP USER hol_dev CASCADE;

CREATE USER hol_dev IDENTIFIED BY HandsOnLabUser1;
ALTER USER hol_dev TEMPORARY TABLESPACE temp;

GRANT CREATE SESSION, RESOURCE, UNLIMITED TABLESPACE TO hol_dev;

GRANT CREATE TABLE,
CREATE VIEW,
CREATE SEQUENCE,
CREATE PROCEDURE,
CREATE TYPE,
CREATE SYNONYM
TO hol_dev;

BEGIN
 ords_admin.enable_schema(
  p_enabled => TRUE,
  p_schema => 'hol_dev',
  p_url_mapping_type => 'BASE_PATH',
  p_url_mapping_pattern => 'hol_dev',
  p_auto_rest_auth => NULL
 );
 commit;
END;
/

DROP USER hol_test CASCADE;

CREATE USER hol_test IDENTIFIED BY HandsOnLabUser1;
ALTER USER hol_test TEMPORARY TABLESPACE temp;

GRANT CREATE SESSION, RESOURCE, UNLIMITED TABLESPACE TO hol_test;

GRANT CREATE TABLE,
CREATE VIEW,
CREATE SEQUENCE,
CREATE PROCEDURE,
CREATE TYPE,
CREATE SYNONYM
TO hol_test;

BEGIN
 ords_admin.enable_schema(
  p_enabled => TRUE,
  p_schema => 'hol_test',
  p_url_mapping_type => 'BASE_PATH',
  p_url_mapping_pattern => 'hol_test',
  p_auto_rest_auth => NULL
 );
 commit;
END;
/
exit;
