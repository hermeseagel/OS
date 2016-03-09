db2 connect to  TBBDB 
#db2 "SET HEADER OFF"
#db2 "SPOOL  query.sql"
db2  -x -z nquery.sql "select  'select '||''''||TABSCHEMA||'.'||TABNAME||''''||','||' count(*) from '||TABSCHEMA||'.'||TABNAME||';' from syscat.tables " 


