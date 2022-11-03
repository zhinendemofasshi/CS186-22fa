-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS lslg;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era) -- replace this line
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE people.weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE namefirst LIKE '% %'
  ORDER BY namefirst, namelast
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  HAVING COUNT(*) >= 1
  ORDER BY birthyear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  HAVING COUNT(*) >= 1 AND AVG(height) > 70
  ORDER BY birthyear
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, namelast, HallofFame.playerid, yearid
  FROM people INNER JOIN HallofFame
  ON people.playerid = HallofFame.playerid AND HallofFame.inducted = 'Y'
  ORDER BY yearid DESC, HallofFame.playerid
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT namefirst, namelast, a.playerid, CollegePlaying.schoolID, yearid
  FROM (
    SELECT namefirst, namelast, HallofFame.playerid, yearid
    FROM people INNER JOIN HallofFame
    ON people.playerid = HallofFame.playerid AND HallofFame.inducted = 'Y'
  ) AS a INNER JOIN CollegePlaying INNER JOiN Schools
  ON a.playerid = CollegePlaying.playerid AND CollegePlaying.schoolID = Schools.schoolID AND Schools.schoolState = 'CA'

  ORDER BY yearid DESC, CollegePlaying.schoolID, a.playerid
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT a.playerid, namefirst, namelast, schoolID
  FROM (
    SELECT namefirst, namelast, HallofFame.playerid, yearid
    FROM people INNER JOIN HallofFame
    ON people.playerid = HallofFame.playerid AND HallofFame.inducted = 'Y'
  ) AS a LEFT OUTER JOIN CollegePlaying
  ON a.playerid = CollegePlaying.playerid

  ORDER BY a.playerid DESC, schoolID
;

-- Question 3i


CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT s.playerid, namefirst, namelast, yearid, slg
  FROM(
    SELECT playerid, yearid, (H + H2B + 2 * H3B + 3 * HR + 0.0) / (AB + 0.0) AS slg
    FROM Batting
    WHERE AB > 50
  ) AS s INNER JOIN people
  ON s.playerid = people.playerid
  ORDER BY s.slg DESC
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT people.playerid, namefirst, namelast, (SUM(H) + SUM(H2B) + 2 * SUM(H3B) + 3 * SUM(HR) + 0.0) / (SUM(AB) + 0.0) AS lslg
  FROM Batting INNER JOIN people
  ON people.playerid = Batting.playerid
  GROUP BY Batting.playerid
  HAVING SUM(AB) > 50
  ORDER BY lslg DESC, people.playerid
  LIMIT 10
;


-- Question 3iii

CREATE VIEW lslg(playerid, lslgv)
AS
  SELECT playerid, (SUM(H) + SUM(H2B) + 2 * SUM(H3B) + 3 * SUM(HR) + 0.0) / (SUM(AB) + 0.0) AS lslgv
  FROM Batting
  GROUP BY playerid
  HAVING SUM(AB) > 50
;

CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT namefirst, namelast, lslg.lslgv
  FROM people INNER JOIN lslg
  ON people.playerid = lslg.playerid
  WHERE lslg.lslgv > (
    SELECT lslgv
    FROM people INNER JOIN lslg
    ON people.playerid = lslg.playerid AND people.namefirst = 'Willie' AND people.namelast = 'Mays'
  )
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid, min(salary), max(salary), avg(salary)
  FROM Salaries
  GROUP BY yearid
  ORDER BY yearid
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  SELECT binid, 507500.0 + binid * 3249250.0, 3756750.0 + binid * 3249250.0, COUNT(*)
  FROM binids, Salaries
  WHERE yearid = 2016 AND salary between 507500.0 + binid * 3249250.0 and 3756750.0 + binid * 3249250.0
  GROUP BY binid
  ORDER BY binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT s1.yearid, min(s1.salary) - min(s2.salary), max(s1.salary) - max(s2.salary), avg(s1.salary) - avg(s2.salary)
  FROM Salaries s1 INNER JOIN Salaries s2
  ON s1.yearid - 1 = s2.yearid
  WHERE s1.yearid between 1986 and 2016
  GROUP BY s1.yearid
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT people.playerid, namefirst, namelast, salary, yearid
  FROM people INNER JOIN Salaries
  ON people.playerid = Salaries.playerid
  WHERE yearid = 2000 AND salary = (
    SELECT MAX(salary)
    FROM Salaries
    WHERE yearid = 2000
  )
  UNION
  SELECT people.playerid, namefirst, namelast, salary, yearid
  FROM people INNER JOIN Salaries
  ON people.playerid = Salaries.playerid
  WHERE yearid = 2001 AND salary = (
    SELECT MAX(salary)
    FROM Salaries
    WHERE yearid = 2001
  )
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT allstarfull.teamID, MAX(salary) - MIN(salary)
  FROM allstarfull INNER JOIN Salaries
  ON allstarfull.playerid = Salaries.playerid and allstarfull.teamID = Salaries.teamID AND allstarfull.yearid = Salaries.yearid
  WHERE allstarfull.yearid = 2016
  GROUP BY allstarfull.teamID
;

