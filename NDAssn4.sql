--Nicole Dahlquist
--PROG3200 - Assn 4
--Due date: December 2nd


CREATE TABLE NDMV (
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
  time_enrolled INTERVAL YEAR(2) TO MONTH
);
/
BEGIN
  NDProcedure();
END;
/
-- This PL/SQL block populates the NDMV table
CREATE OR REPLACE PROCEDURE NDProcedure IS 
  -- cursor that selects all the required columns from faculty and student tables
  CURSOR c IS 
    SELECT f.f_id, f_last, f_first, f_mi, loc_id, f_phone, f_rank, f_super,
      f_pin, s_id, s_last, s_first, s_mi, s_address, s_city, s_state, s_zip,
      s_phone, s_class, s_dob, s_pin, time_enrolled 
    FROM faculty f
    LEFT OUTER JOIN student s
      ON f.f_id = s.f_id;
  cursor_row c%ROWTYPE;
  BEGIN
    DELETE FROM NDMV;
    OPEN c;
    LOOP    
      FETCH c INTO cursor_row;
      EXIT WHEN c%NOTFOUND; 
      INSERT INTO NDMV(f_id, f_last, f_first, f_mi, loc_id, f_phone, f_rank,
        f_super, f_pin, s_id, s_last, s_first, s_mi, s_address, s_city, s_state,
        s_zip, s_phone, s_class, s_dob, s_pin, time_enrolled)
        VALUES (cursor_row.f_id, cursor_row.f_last, cursor_row.f_first, 
          cursor_row.f_mi, cursor_row.loc_id, cursor_row.f_phone, 
          cursor_row.f_rank, cursor_row.f_super, cursor_row.f_pin, 
          cursor_row.s_id, cursor_row.s_last, cursor_row.s_first, 
          cursor_row.s_mi, cursor_row.s_address, cursor_row.s_city, 
          cursor_row.s_state, cursor_row.s_zip, cursor_row.s_phone, 
          cursor_row.s_class, cursor_row.s_dob, cursor_row.s_pin, cursor_row.time_enrolled);             
    END LOOP;
    CLOSE c;  
  END;
/