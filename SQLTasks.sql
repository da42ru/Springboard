/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name
FROM Facilities
WHERE membercost > 0

/* Q2: How many facilities do not charge a fee to members? */

4 facilities

SELECT COUNT(*)
FROM Facilities
WHERE membercost = 0

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities 
WHERE membercost > 0
AND membercost < 0.2 * monthlymaintenance

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT * 
FROM Facilities 
WHERE facid IN (1, 5)

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
CASE 
	WHEN monthlymaintenance > 100 THEN 'expensive'
    ELSE 'cheap'
	END AS label
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM Members 
WHERE joindate = 
	(SELECT MAX(joindate)
     FROM Members)

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT f.name AS court, m.firstname || ' ' || m.surname AS name
FROM Facilities as f
INNER JOIN Bookings as b
    ON f.facid = b.facid
INNER JOIN Members as m
    ON b.memid = m.memid
WHERE f.name LIKE 'Tennis Court%'
ORDER BY name

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name AS facility, m.firstname || ' ' || m.surname AS name,
CASE WHEN b.memid = 0 THEN f.guestcost * b.slots
    ELSE f.membercost * b.slots
    END AS cost
FROM Facilities as f
INNER JOIN Bookings as b
    ON f.facid = b.facid
INNER JOIN Members as m
    ON b.memid = m.memid
WHERE b.starttime LIKE '2012-09-14%'
AND cost > 30
ORDER BY cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT sub.facility, sub.name, sub.cost AS 
FROM (SELECT f.name AS facility, m.firstname || ' ' || m.surname AS name,
CASE WHEN b.memid = 0 THEN f.guestcost * b.slots
    ELSE f.membercost * b.slots
    END AS cost
FROM Facilities as f
INNER JOIN Bookings as b
    ON f.facid = b.facid
INNER JOIN Members as m
    ON b.memid = m.memid
WHERE b.starttime LIKE '2012-09-14%'
AND cost > 30
ORDER BY cost DESC) AS sub

/* PART 2: SQLite
 
/* QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT *
FROM
(SELECT sub1.facility, SUM(sub1.cost) AS revenue
FROM
(SELECT f.name AS facility,
CASE WHEN b.memid = 0 THEN f.guestcost * b.slots
    ELSE f.membercost * b.slots
    END AS cost
FROM Facilities as f
INNER JOIN Bookings as b
    ON f.facid = b.facid) AS sub1
GROUP BY sub1.facility) AS sub2
WHERE sub2.revenue < 1000
ORDER BY sub2.revenue

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT m1.surname || ',' || m1.firstname as member,
        m2.surname || ',' || m2.firstname as recommendedby
FROM Members as m1
INNER JOIN Members as m2
ON m1.recommendedby = m2.memid
ORDER BY member

/* Q12: Find the facilities with their usage by member, but not guests */

SELECT f.name, COUNT(b.memid) AS member_usage
FROM 
(SELECT facid, memid
FROM Bookings
WHERE memid != 0) as b
LEFT JOIN Facilities as f
ON b.facid = f.facid
GROUP BY f.name
ORDER BY member_usage DESC

/* Q13: Find the facilities usage by month, but not guests */

SELECT b.month, f.name AS facility, COUNT(b.memid) AS member_usage
FROM
(SELECT strftime('%m', starttime) AS month, memid, facid
FROM Bookings
WHERE memid != 0) AS b
LEFT JOIN Facilities AS f
ON b.facid = f.facid
GROUP BY b.month, f.name