CREATE TABLE employee (
  id integer NOT NULL DEFAULT nextval('employee_id_seq'::regclass) PRIMARY KEY,  -- Primary Key 
  name character varying,  -- Variable-length string 
  position character varying,  -- Variable-length string 
  salary numeric
);