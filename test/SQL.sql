-- Single line comment
/* Multi line
   comment */

-- Definitions
CREATE TABLE users (
  id serial PRIMARY KEY,
  name varchar(255) NOT NULL,
  email text UNIQUE,
  balance numeric(10, 2) DEFAULT 0.0,
  is_active boolean DEFAULT true,
  team_id int REFERENCES teams (id) ON DELETE CASCADE
);

create table if not exists public.teams (id int);
create temporary table `sessions` (id int);
CREATE OR REPLACE VIEW active_users AS
  SELECT * FROM users WHERE is_active = TRUE;
CREATE MATERIALIZED VIEW stats AS SELECT 1;
CREATE TYPE mood AS ENUM ('sad', 'ok', 'happy');
CREATE UNIQUE INDEX users_email ON users (email);

CREATE OR REPLACE FUNCTION add_numbers(a integer, b integer)
RETURNS integer AS $$
  SELECT a + b;
$$ LANGUAGE sql;

-- Stored procedures
CREATE PROCEDURE public.transfer(sender int, receiver int, amount numeric)
LANGUAGE plpgsql AS $$
DECLARE
  current_balance numeric;
BEGIN
  SELECT balance INTO current_balance FROM users WHERE id = sender;
  IF current_balance < amount THEN
    RAISE EXCEPTION 'Not enough money';
  END IF;
  UPDATE users SET balance = balance - amount WHERE id = sender;
  UPDATE users SET balance = balance + amount WHERE id = receiver;
END;
$$;

CALL transfer(1, 2, 100.50);

create proc dbo.GetUser @id int
as
begin
  select * from users where id = @id;
end;

EXEC dbo.GetUser @id = 1;

-- Conditionals and loops
CREATE FUNCTION grade(score int) RETURNS text AS $body$
DECLARE
  i int := 0;
  item text;
  result text;
BEGIN
  IF score IS NULL THEN
    RETURN NULL;
  ELSIF score >= 90 THEN
    result := 'A';
  ELSIF score >= 50 AND score < 90 THEN
    result := 'B';
  ELSE
    result := 'C';
  END IF;

  LOOP
    i := i + 1;
    EXIT WHEN i > 10;
    CONTINUE WHEN i % 2 = 0;
  END LOOP;

  WHILE i > 0 LOOP
    i := i - 1;
  END LOOP;

  FOR i IN 1..10 LOOP
    RAISE NOTICE 'i = %', i;
  END LOOP;

  FOR item IN SELECT name FROM users LOOP
    RAISE NOTICE '%', item;
  END LOOP;

  FOREACH item IN ARRAY ARRAY['a', 'b'] LOOP
    RAISE NOTICE '%', item;
  END LOOP;

  RETURN result;
END;
$body$ LANGUAGE plpgsql;

-- T-SQL
IF EXISTS (SELECT 1 FROM users WHERE id = 1)
  PRINT 'exists';
ELSE
  PRINT 'missing';

WHILE @i < 10
BEGIN
  SET @i = @i + 1;
  IF @i = 5 CONTINUE;
  IF @i = 8 BREAK;
END;

-- MySQL
CREATE PROCEDURE counter()
BEGIN
  DECLARE i INT DEFAULT 0;
  counter_loop: LOOP
    SET i = i + 1;
    IF i < 5 THEN
      ITERATE counter_loop;
    ELSEIF i = 7 THEN
      SET i = i + 1;
    END IF;
    IF i > 10 THEN
      LEAVE counter_loop;
    END IF;
  END LOOP counter_loop;

  REPEAT
    SET i = i - 1;
  UNTIL i <= 0
  END REPEAT;
END;

DROP TABLE old_users CASCADE;
ALTER TABLE users ADD COLUMN age int;

-- Queries
SELECT
  u.id,
  u.name AS user_name,
  count(*) AS total,
  coalesce(u.email, 'none') AS email,
  u.balance / 100 / 3 AS ratio,
  1.5e3 + .5 - 3.14 * 2 % 7 AS math,
  'a' || 'b' AS concat
FROM users AS u
LEFT JOIN teams t ON t.id = u.team_id
WHERE u.name LIKE 'A%'
  AND u.email IS NOT NULL
  AND u.age IS NULL
  AND u.id IN (1, 2, 3)
  AND u.balance BETWEEN 10 AND 20
  AND u.age <> 18 AND u.age != 21 AND u.age >= 30
GROUP BY u.id, u.name
HAVING count(*) > 1
ORDER BY total DESC, u.name ASC
LIMIT 10;

SELECT CASE WHEN x > 0 THEN 'positive' ELSE 'other' END FROM t;

WITH recent AS (
  SELECT * FROM users WHERE created_at > now() - INTERVAL '1 day'
)
SELECT * FROM recent;

INSERT INTO users (name, email, is_active) VALUES ('Ann', NULL, false);
UPDATE users SET name = 'Bob' WHERE id = 1;
DELETE FROM users WHERE id = 1;

BEGIN;
COMMIT;
ROLLBACK;

GRANT SELECT ON users TO reader;
