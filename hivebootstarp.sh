beeline
CREATE ROLE sqladmin;
GRANT ROLE sqladmin TO GROUP $ADGROUP;
GRANT ALL ON SERVER server1 TO ROLE sqladmin WITH GRANT OPTION;
