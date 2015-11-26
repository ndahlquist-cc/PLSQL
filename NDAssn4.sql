--Nicole Dahlquist
--PROG3200 - Assn 4
--Due date: December 2nd

CREATE OR REPLACE TABLE NDMV (
  f_id NUMBER(6,0),
  f_last VARCHAR2(30),
  f_first VARCHAR2(30),
  f_mi CHAR(1),
  loc_id NUMBER(5,0),
  f_phone VARCHAR2(10),
  f_rank VARCHAR2(9),
  f_super NUMBER(6,0),
  f_pin NUMBER(4,0),
  s_id VARCHAR2(6),
  s_last VARCHAR2(30),
  s_first VARCHAR2(30),
  s_mi CHAR(1),
  s_address VARCHAR2(25),
  s_city VARCHAR2(20),
  s_state CHAR(2),
  s_zip VARCHAR2(10),
  s_phone VARCHAR2(10),
  s_class CHAR(2),
  s_dob DATE,
  s_pin NUMBER(4,0),
  f_id_1 NUMBER(6,0),
  time_enrolled INTERVAL YEAR(2) TO MONTH
);

SELECT * 
FROM faculty f
LEFT OUTER JOIN student s
  ON(f.f_id = s.f_id);