storage name : s3://raviadulla-snowflake-2025/snowflake_inputfiles/
polciy : snowflake_access
role : mysnowflakerole

Role ARN :  arn:aws:iam::245706660707:role/mysnowflakerole
STORAGE_AWS_IAM_USER_ARN = arn:aws:iam::829545265689:user/externalstages/ci71qa0000
STORAGE_AWS_ROLE_ARN = arn:aws:iam::245706660707:role/mysnowflakerole
STORAGE_AWS_EXTERNAL_ID = MBA00126_SFCRole=4_ck+ykz1/0oL4hTvOVYnB7fwK/6I=

create or replace storage integration s3_int
type = external_stage
storage_provider = 'S3'
enabled = true
storage_aws_role_arn = 'arn:aws:iam::245706660707:role/mysnowflakerole'
storage_allowed_locations = ('s3://raviadulla-snowflake-2025/snowflake_inputfiles/')

describe integration s3_int;

create stage my_s3_stage
storage_integration = s3_int
url = 's3://raviadulla-snowflake-2025/snowflake_inputfiles/'
;

list@my_s3_stage

department_id	department_name	location

create  or replace table emp_s3 (department_id integer,department_name string, location_name string )

select * from emp_s3;


copy into emp_s3
from @my_s3_stage
ON_ERROR = 'CONTINUE';

delete from emp_s3;

copy into emp_s3
from @my_s3_stage
ON_ERROR = 'CONTINUE'
force = true
;

copy into emp_s3
from @my_s3_stage/dep.csv
file_format = (type = 'csv' field_delimiter = '\,' error_on_column_count_mismatch=false)
ON_ERROR = CONTINUE
force = true
;

select * from emp_s3;

desc table emp_s3;

remove @my_s3_stage/dep.csv

copy into emp_s3
from @my_s3_stage/dep.csv
file_format = (type = 'csv' field_delimiter = '\,' skip_header = 1 error_on_column_count_mismatch=false)
ON_ERROR = CONTINUE
force = true
;

copy into emp_s3
from @my_s3_stage/dep.csv
file_format = (type = 'csv' field_delimiter = '\,' skip_header = 1 error_on_column_count_mismatch=false)
ON_ERROR = CONTINUE
force = true
purge = true
;

list@my_s3_stage


