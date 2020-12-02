/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT * 
FROM Facilities 
WHERE membercost > 0;

/* Answer: Tennis Court 1 & 2, Massage Room 1 & 2, and Squash Court */

/* Q2: How many facilities do not charge a fee to members? */

SELECT * 
FROM Facilities 
WHERE membercost = 0;

/* Answer: 4 (Badminton Court, Table Tennis, Snooker Table, and Pool Table */

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities 
WHERE membercost > 0 AND membercost < (monthlymaintenance*0.20);

/* Answer: 
0 | Tennis Court 1 | 5.0 | 200
1 | Tennis Court 2 | 5.0 | 200
4 | Massage Room 1 | 9.9 | 3000
5 | Massage Room 2 | 9.9 | 3000
6 | Squash Court   | 3.5 | 80
*/

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT * 
FROM `Facilities` 
WHERE facid IN (1,5);

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
CASE
    WHEN monthlymaintenance > 100 THEN "Expensive"
    ELSE "Cheap"
END AS Category
FROM Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname, surname 
FROM Members 
WHERE joindate=(SELECT MAX(joindate) FROM Members);

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT CONCAT(Members.firstname,' ', Members.surname) AS FullName, Facilities.name
FROM Members, Facilities
/*Tennis Court 1 & 2 have facid: 0 & 1*/
WHERE Facilities.facid IN (0,1)
GROUP BY FullName
ORDER BY FullName ASC;

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT CONCAT(Members.firstname,' ', Members.surname) AS FullName, Facilities.name,
	CASE 
		WHEN Members.memid = 0 THEN Bookings.slots * Facilities.guestcost
        ELSE Bookings.slots * Facilities.membercost
	END as Guest_and_Members_Cost
FROM Members
	INNER JOIN Bookings ON Members.memid = Bookings.memid
	INNER JOIN Facilities ON Bookings.facid = Facilities.facid
	WHERE
		Bookings.starttime >= '2012-09-14' AND Bookings.starttime < '2012-09-15' 
		AND 
		((Members.memid = 0 AND Bookings.slots*Facilities.guestcost > 30) OR
		(Members.memid != 0 AND Bookings.slots*Facilities.membercost > 30))
ORDER BY Guest_and_Members_Cost DESC;  


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT SubQuery.facid, SubQuery.memid, SubQuery.starttime, SubQuery.membercost, SubQuery.guestcost, SubQuery.name, Members.surname, Members.firstname
FROM (
SELECT Bookings.facid, Bookings.memid, Bookings.starttime, Facilities.membercost,
Facilities.guestcost, Facilities.name
FROM Bookings
LEFT JOIN Facilities on Bookings.facid = Facilities.facid
WHERE Bookings.starttime >= '2012-09-14' AND Bookings.starttime < '2012-09-15'
AND (Facilities.membercost >= 30 OR Facilities.guestcost >= 30)) as SubQuery
LEFT JOIN Members ON SubQuery.memid = Members.memid
ORDER BY SubQuery.guestcost DESC;

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT Facilities.name, SUM(Bookings.slots * (
	CASE 
		WHEN Bookings.memid = 0 THEN Facilities.guestcost
		ELSE Facilities.membercost END)) AS Revenue
FROM Bookings
INNER JOIN Facilities ON Bookings.facid = Facilities.facid
GROUP BY Facilities.name
HAVING revenue < 1000
ORDER BY revenue