--Nicole Dahlquist
--PROG3200 - Assn 4
--Due date: December 2nd

-- creates the simulated MV table
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
-- runs the procedure to populate NDMV table
BEGIN
  NDProcedure();
END;
/
-- This PL/SQL block populates the NDMV table
CREATE OR REPLACE PROCEDURE NDProcedure IS 
  -- cursor that selects all the required columns from faculty and student tables
  CURSOR cursor_join_student_faculty IS 
    SELECT f.f_id, f_last, f_first, f_mi, loc_id, f_phone, f_rank, f_super,
      f_pin, s_id, s_last, s_first, s_mi, s_address, s_city, s_state, s_zip,
      s_phone, s_class, s_dob, s_pin, time_enrolled 
    FROM faculty f
    LEFT OUTER JOIN student s
      ON f.f_id = s.f_id;
  cursor_row cursor_join_student_faculty%ROWTYPE;
  BEGIN
   -- remove current rows in table before population 
    DELETE FROM NDMV;
    OPEN cursor_join_student_faculty;
    LOOP    
      FETCH cursor_join_student_faculty INTO cursor_row;
      EXIT WHEN cursor_join_student_faculty%NOTFOUND; 
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
    CLOSE cursor_join_student_faculty;  
    EXCEPTION
      WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('An unknown error occured.');
  END;
/
-- Triggers
-- Faculty
-- after insert
CREATE OR REPLACE TRIGGER faculty_after_insert
AFTER INSERT ON faculty
FOR EACH ROW
--DECLARE
BEGIN
  INSERT INTO NDMV
    VALUES(:NEW.f_id, :NEW.f_last, :NEW.f_first, :NEW.f_mi, :NEW.loc_id, 
      :NEW.f_phone, :NEW.f_rank, :NEW.f_super, :NEW.f_pin, NULL, NULL, NULL, 
      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An unknown error occured.');
END;
/
-- after update
CREATE OR REPLACE TRIGGER faculty_after_update
AFTER UPDATE ON faculty
FOR EACH ROW
WHEN (OLD.f_id = NEW.f_id)
--DECLARE
BEGIN
  UPDATE NDMV
  SET f_last = :NEW.f_last, f_first = :NEW.f_first, f_mi = :NEW.f_mi, 
    loc_id = :NEW.loc_id, f_phone = :NEW.f_phone, f_rank = :NEW.f_rank, 
    f_super = :NEW.f_super, f_pin = :NEW.f_pin
  WHERE f_id = :OLD.f_id; 
EXCEPTION
  WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('An unknown error occured.');
END;
/
-- after delete
CREATE OR REPLACE TRIGGER faculty_after_delete
AFTER DELETE ON faculty
FOR EACH ROW
--DECLARE
BEGIN
  DELETE FROM NDMV
    WHERE f_id = :OLD.f_id;
EXCEPTION
  WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('An unknown error occured.');
END;
/
-- Student
-- after insert
CREATE OR REPLACE TRIGGER student_after_insert
AFTER INSERT ON student
FOR EACH ROW
DECLARE
  -- this cursor gets the details of the faculty that advises the inserted student
  CURSOR cursor_insert_get_faculty IS
    SELECT f_last, f_first, f_mi, loc_id, f_phone, f_rank, f_super, f_pin
    FROM faculty
    WHERE f_id = :NEW.f_id;
  insert_get_faculty_row cursor_insert_get_faculty%ROWTYPE;
  rowCount NUMBER:= 0;
BEGIN
  SELECT COUNT(*) INTO rowCount 
  FROM NDMV
  WHERE f_id = :NEW.f_id
    AND s_id IS NULL;
  IF(rowCount = 1 ) THEN
    DELETE FROM NDMV
    WHERE f_id = :NEW.f_id;
  END IF;
  OPEN cursor_insert_get_faculty;
  FETCH cursor_insert_get_faculty INTO insert_get_faculty_row;
  INSERT INTO NDMV
    VALUES(:NEW.f_id, insert_get_faculty_row.f_last, insert_get_faculty_row.f_first, 
      insert_get_faculty_row.f_mi, insert_get_faculty_row.loc_id, 
      insert_get_faculty_row.f_phone, insert_get_faculty_row.f_rank, 
      insert_get_faculty_row.f_super, insert_get_faculty_row.f_pin, :NEW.s_id, 
      :NEW.s_last, :NEW.s_first, :NEW.s_mi, :NEW.s_address, :NEW.s_city, 
      :NEW.s_state,:NEW.s_zip, :NEW.s_phone, :NEW.s_class, :NEW.s_dob, 
      :NEW.s_pin, :NEW.time_enrolled);
  CLOSE cursor_insert_get_faculty;
EXCEPTION
  WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('An unknown error occured.');
END;
/
-- after update
CREATE OR REPLACE TRIGGER student_after_update
AFTER UPDATE ON student
FOR EACH ROW
DECLARE
  -- this cursor gets the details of the faculty that advises the inserted student
  CURSOR cursor_update_get_faculty IS
    SELECT f_last, f_first, f_mi, loc_id, f_phone, f_rank, f_super, f_pin
    FROM faculty
    WHERE f_id = :NEW.f_id;
  update_get_faculty_row cursor_update_get_faculty%ROWTYPE;
  oldRowCount NUMBER:= 0;
  newRowCount NUMBER:= 0;

BEGIN
  IF (:OLD.f_id <> :NEW.f_id) THEN
    SELECT COUNT(*) INTO oldRowCount 
    FROM NDMV
    WHERE f_id = :OLD.f_id;
    OPEN cursor_update_get_faculty;
    FETCH cursor_update_get_faculty INTO update_get_faculty_row;
    IF (oldRowCount = 1) THEN
      UPDATE NDMV
      SET s_id = NULL, s_last = NULL, s_first = NULL, s_mi = NULL, 
        s_address = NULL, s_city = NULL, s_state = NULL, s_zip = NULL, 
        s_phone = NULL, s_class = NULL, s_dob = NULL, s_pin = NULL, 
        time_enrolled = NULL
      WHERE f_id = :OLD.f_id;
      SELECT COUNT(*) INTO newRowCount
      FROM NDMV
      WHERE f_id = :NEW.f_id
        AND s_id IS NULL;
      IF(newRowCount = 1) THEN
        UPDATE NDMV
        SET s_id = :NEW.s_id, s_last = :NEW.s_last, s_first = :NEW.s_first, 
          s_mi = :NEW.s_mi, s_address = :NEW.s_address, s_city = :NEW.s_city, 
          s_state = :NEW.s_state, s_zip = :NEW.s_zip, s_phone = :NEW.s_phone, 
          s_class = :NEW.s_class, s_dob = :NEW.s_dob, s_pin = :NEW.s_pin, 
          time_enrolled = :NEW.time_enrolled
        WHERE f_id = :NEW.f_id;
      ELSIF(newRowCount = 0) THEN
        INSERT INTO NDMV
          VALUES (:NEW.f_id, update_get_faculty_row.f_last, update_get_faculty_row.f_first, 
            update_get_faculty_row.f_mi, update_get_faculty_row.loc_id, 
            update_get_faculty_row.f_phone, update_get_faculty_row.f_rank, 
            update_get_faculty_row.f_super, update_get_faculty_row.f_pin, 
            :NEW.s_id, :NEW.s_last, :NEW.s_first, :NEW.s_mi, :NEW.s_address, 
            :NEW.s_city, :NEW.s_state, :NEW.s_zip, :NEW.s_phone, :NEW.s_class, 
            :NEW.s_dob, :NEW.s_pin, :NEW.time_enrolled);
      END IF;
    ELSIF(oldRowCount > 1) THEN
      SELECT COUNT(*) INTO newRowCount
      FROM NDMV
      WHERE f_id = :NEW.f_id
        AND s_id IS NULL;
      IF(newRowCount = 1) THEN
        DELETE FROM NDMV
        WHERE f_id = :NEW.f_id;
      END IF;
      UPDATE NDMV
      SET f_id = :NEW.f_id, f_last = update_get_faculty_row.f_last, 
        f_first = update_get_faculty_row.f_first, f_mi = update_get_faculty_row.f_mi, 
        loc_id = update_get_faculty_row.loc_id, f_phone = update_get_faculty_row.f_phone, 
        f_rank = update_get_faculty_row.f_rank, f_super = update_get_faculty_row.f_super, 
        f_pin = update_get_faculty_row.f_pin, s_id = :NEW.s_id, s_last = :NEW.s_last, 
        s_first = :NEW.s_first, s_mi = :NEW.s_mi, s_address = :NEW.s_address, 
        s_city = :NEW.s_city, s_state = :NEW.s_state, s_zip = :NEW.s_zip, 
        s_phone = :NEW.s_phone, s_class = :NEW.s_class, s_dob = :NEW.s_dob, 
        s_pin = :NEW.s_pin, time_enrolled = :NEW.time_enrolled
     WHERE f_id = :OLD.f_id
        AND s_id = :OLD.s_id; 
    END IF;
    CLOSE cursor_update_get_faculty;
  ELSIF (:OLD.f_id = :NEW.f_id) THEN
    UPDATE NDMV
    SET s_id = :NEW.s_id, s_last = :NEW.s_last, 
      s_first = :NEW.s_first, s_mi = :NEW.s_mi, s_address = :NEW.s_address, 
      s_city = :NEW.s_city, s_state = :NEW.s_state, s_zip = :NEW.s_zip, 
      s_phone = :NEW.s_phone, s_class = :NEW.s_class, s_dob = :NEW.s_dob, 
      s_pin = :NEW.s_pin, time_enrolled = :NEW.time_enrolled
    WHERE f_id = :OLD.f_id
      AND s_id = :OLD.s_id;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('An unknown error occured.');
END;
/
-- after delete
CREATE OR REPLACE TRIGGER student_after_delete
AFTER DELETE ON student
FOR EACH ROW
DECLARE
  rowCount NUMBER :=0;
BEGIN  
  SELECT COUNT(*) INTO rowCount 
  FROM NDMV
  WHERE f_id = :OLD.f_id;
  IF(rowCount = 1) THEN
    UPDATE NDMV
    SET s_id = NULL, s_last = NULL, s_first = NULL, s_mi = NULL,
      s_address = NULL, s_city = NULL, s_state = NULL, s_zip = NULL, 
      s_phone = NULL, s_class = NULL, s_dob = NULL, 
      s_pin = NULL, time_enrolled = NULL
    WHERE f_id = :OLD.f_id;
  ELSIF(rowCount > 1) THEN
    DELETE FROM NDMV
    WHERE s_id = :OLD.s_id;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('An unknown error occured.');
END;
/