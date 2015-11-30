--Nicole Dahlquist
--PROG3200 - Assn 4
--Due date: December 2nd

-- Print original studentJoinFaculty query and NDMV table
BEGIN
NDOutput();
END;
/

-- Test Cases for Task 1

--1 The addition of a new student for a faculty member that does not currently have any students
BEGIN
INSERT INTO student
  VALUES ('HH100', 'Hulk', 'Hogan', 'H', '123 Somewhere', 'Augusta', 'GE', 12345, 5555551212, 'FR', TO_DATE('08/11/1953', 'MM/DD/YYYY'), 1230, 5, TO_YMINTERVAL('4-2'));
NDOutput();
ROLLBACK;
END;   
/  
--2 The addition of a new student for a faculty member that already has students
BEGIN
INSERT INTO student
  VALUES ('MA101', 'Margaret', 'Atwood', 'E', '123 Somewhere', 'Ottawa', 'ON', 54320, 6135551212, 'FR', TO_DATE('11/18/1939', 'MM/DD/YYYY'), 1250, 1, TO_YMINTERVAL('1-2'));
NDOutput();
ROLLBACK;
END;   
/
--3 The addition of a new faculty member
BEGIN
INSERT INTO faculty
  VALUES (6, 'Incredible', 'Bob', 'H', 9, '8075551212', 'Associate', 1, 6399, EMPTY_BLOB());
NDOutput();
ROLLBACK;
END;  
/
--4 The change of a student's advisor from one faculty member to another 
--a) When they aren't the last student of the old advisor nor the first student of the new advisor
BEGIN
  UPDATE student
  SET f_id = 2
  WHERE s_id = 'MA100';
  NDOutput();
  ROLLBACK;
END;
/
--b) When they aren't the last student but are the first for the new advisor
BEGIN
  UPDATE student
  SET f_id = 5
  WHERE s_id = 'MA100';
  NDOutput();
  ROLLBACK;
END;
/
--c) When they are the last student but not the first of the new advisor
BEGIN
  UPDATE student
  SET f_id = 1
  WHERE s_id = 'SM100';
  NDOutput();
  ROLLBACK;
END;
/
--d) When they are last and first for the new advisor
BEGIN
  UPDATE student
  SET f_id = 5
  WHERE s_id = 'SM100';
  NDOutput();
  ROLLBACK;
END;
/
--5 The update of a student's information for various columns
--a) Assortment of columns
BEGIN
  UPDATE student
  SET s_last = 'Davidson', s_first = 'Harley'
  WHERE s_id = 'SM100';
  NDOutput();
  ROLLBACK;
END;
/
--b) Assortment of columns
BEGIN
  UPDATE student
  SET s_address = '123 Kenogami', s_city = 'Thunder Bay', s_state = 'ON'
  WHERE s_id = 'JO101';
  NDOutput();
  ROLLBACK;
END;
/
--6 The update of a faculty member's information for various columns
--a) Assortment of columns
BEGIN
  UPDATE faculty
  SET f_last = 'Tchaikovsky', f_first = 'Pyotr', f_mi = 'I'
  WHERE f_id = '1';
  NDOutput();
  ROLLBACK;
END;
/
--b) Assortment of columns
BEGIN
  UPDATE faculty
  SET loc_id = 9, f_rank = 'Full', f_super = 1, f_pin = '8888'
  WHERE f_id = '3';
  NDOutput();
  ROLLBACK;
END;
/
--7 The deletion of all of the students for a specific faculty member so that
--a) Only one student to start
BEGIN
  DELETE FROM enrollment
  WHERE s_id = 'SM100';
  DELETE FROM student
  WHERE s_id = 'SM100';
  NDOutput();
  ROLLBACK;
END;
/
--b) Multiple students to start
BEGIN
  DELETE FROM enrollment
  WHERE s_id = 'JO100'
    OR s_id = 'MA100'
    OR s_id = 'PE100';
  DELETE FROM student
  WHERE s_id = 'JO100'
    OR s_id = 'MA100'
    OR s_id = 'PE100';
  NDOutput();
  ROLLBACK;
END;
/
-- the materialized view table will contain a null-supplied student row for that 
-- faculty member

-- Procedure that displays the changed tables in DMBS_OUTPUT  
CREATE OR REPLACE PROCEDURE NDOutput  IS  
  CURSOR cursor_output_NDMV IS 
    SELECT * 
    FROM NDMV
    ORDER BY f_id, s_id;
  cursor_row_NDMV cursor_output_NDMV%ROWTYPE;
  CURSOR cursor_output_student_faculty IS 
    SELECT f.f_id, f_last, f_first, f_mi, loc_id, f_phone, f_rank, f_super,
      f_pin, s_id, s_last, s_first, s_mi, s_address, s_city, s_state, s_zip,
      s_phone, s_class, s_dob, s_pin, time_enrolled  
    FROM faculty f
    LEFT OUTER JOIN student s 
      ON(f.f_id = s.f_id)
    ORDER BY f_id, s_id;
  cursor_row_student_faculty cursor_output_student_faculty%ROWTYPE;  
BEGIN
  OPEN cursor_output_student_faculty;
  DBMS_OUTPUT.PUT_LINE('Faculty-Join-Student:');
  LOOP
    FETCH cursor_output_student_faculty INTO cursor_row_student_faculty;
    EXIT WHEN cursor_output_student_faculty%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('f_id: ' || cursor_row_student_faculty.f_id 
      || ', f_last: ' || cursor_row_student_faculty.f_last 
      || ', f_first: ' || cursor_row_student_faculty.f_first 
      || ', f_mi: ' || cursor_row_student_faculty.f_mi
      || ', loc_id: ' || cursor_row_student_faculty.loc_id 
      || ', f_phone: ' || cursor_row_student_faculty.f_phone
      || ', f_rank: ' || cursor_row_student_faculty.f_rank 
      || ', f_super: ' || cursor_row_student_faculty.f_super
      || ', f_pin: ' || cursor_row_student_faculty.f_pin 
      || ', s_id: ' || NVL(TO_CHAR(cursor_row_student_faculty.s_id), 'NULL')
      || ', s_last: ' || NVL(cursor_row_student_faculty.s_last, 'NULL')
      || ', s_first: ' || NVL(cursor_row_student_faculty.s_first, 'NULL')
      || ', s_mi: ' || NVL(cursor_row_student_faculty.s_mi, 'NULL')
      || ', s_address: ' || NVL(cursor_row_student_faculty.s_address, 'NULL')
      || ', s_city: ' || NVL(cursor_row_student_faculty.s_city, 'NULL')
      || ', s_state: ' || NVL(cursor_row_student_faculty.s_state, 'NULL')
      || ', s_zip: ' || NVL(TO_CHAR(cursor_row_student_faculty.s_zip), 'NULL')
      || ', s_phone: ' || NVL(TO_CHAR(cursor_row_student_faculty.s_class), 'NULL')
      || ', s_dob: ' || NVL(TO_CHAR(cursor_row_student_faculty.s_dob), 'NULL')
      || ', s_pin: ' || NVL(TO_CHAR(cursor_row_student_faculty.s_pin), 'NULL')
      || ', time_enrolled: ' || NVL(TO_CHAR(cursor_row_student_faculty.time_enrolled), 'NULL'));
    DBMS_OUTPUT.PUT_LINE('');  
  END LOOP;
  CLOSE cursor_output_student_faculty;      
  DBMS_OUTPUT.PUT_LINE('');
  OPEN cursor_output_NDMV;
  DBMS_OUTPUT.PUT_LINE('NDMV Table:');
  LOOP
    FETCH cursor_output_NDMV INTO cursor_row_NDMV;
    EXIT WHEN cursor_output_NDMV%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('f_id: ' || cursor_row_NDMV.f_id 
      || ', f_last: ' || cursor_row_NDMV.f_last 
      || ', f_first: ' || cursor_row_NDMV.f_first 
      || ', f_mi: ' || cursor_row_NDMV.f_mi
      || ', loc_id: ' || cursor_row_NDMV.loc_id 
      || ', f_phone: ' || cursor_row_NDMV.f_phone
      || ', f_rank: ' || cursor_row_NDMV.f_rank 
      || ', f_super: ' || cursor_row_NDMV.f_super
      || ', f_pin: ' || cursor_row_NDMV.f_pin 
      || ', s_id: ' || NVL(TO_CHAR(cursor_row_NDMV.s_id), 'NULL')
      || ', s_last: ' || NVL(cursor_row_NDMV.s_last, 'NULL')
      || ', s_first: ' || NVL(cursor_row_NDMV.s_first, 'NULL')
      || ', s_mi: ' || NVL(cursor_row_NDMV.s_mi, 'NULL')
      || ', s_address: ' || NVL(cursor_row_NDMV.s_address, 'NULL')
      || ', s_city: ' || NVL(cursor_row_NDMV.s_city, 'NULL')
      || ', s_state: ' || NVL(cursor_row_NDMV.s_state, 'NULL')
      || ', s_zip: ' || NVL(TO_CHAR(cursor_row_NDMV.s_zip), 'NULL')
      || ', s_phone: ' || NVL(TO_CHAR(cursor_row_NDMV.s_class), 'NULL')
      || ', s_dob: ' || NVL(TO_CHAR(cursor_row_NDMV.s_dob), 'NULL')
      || ', s_pin: ' || NVL(TO_CHAR(cursor_row_NDMV.s_pin), 'NULL')
      || ', time_enrolled: ' || NVL(TO_CHAR(cursor_row_NDMV.time_enrolled), 'NULL'));
      DBMS_OUTPUT.PUT_LINE('');
  END LOOP;
  CLOSE cursor_output_NDMV;
END;
/
  