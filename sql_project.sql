/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT *
FROM Facilities
WHERE membercost > 0

-- Squash court, Tennis Court 1, Tennis Court 2, Massage Room 1, Massage Room 2

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(*) AS count
FROM Facilities
WHERE membercost = 0


-- There are 4 facilities that do not charge a fee to members


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */


SELECT facid,
		name,
		membercost,
		monthlymaintenance
FROM Facilities
WHERE membercost > 0 AND membercost < (monthlymaintenance * .2)



/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid in (1,5)


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name,
		monthlymaintenance,
		CASE WHEN monthlymaintenance > 100 THEN 'expensive'
			ELSE 'cheap' END AS label
FROM Facilities


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname,
		surname
From Members 
WHERE joindate = (SELECT MAX(joindate) FROM Members)

-- Darren, Smith


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */


SELECT CASE
            WHEN Members.firstname = 'GUEST' THEN 'GUEST'
            ELSE CONCAT(Members.firstname,' ',Members.surname) END AS name,
		Facilities.name as court_name
FROM Bookings
JOIN Members ON Bookings.memid = Members.memid
JOIN Facilities ON Bookings.facid = Facilities.facid
WHERE Bookings.facid in (0,1)
GROUP BY 1
ORDER BY 1




/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT CASE 
            WHEN Members.firstname = 'GUEST' THEN 'GUEST'
            ELSE CONCAT(Members.firstname,' ',Members.surname) END AS name,
        Facilities.name AS facility_name,
        CASE
            WHEN Members.memid = '0' THEN Facilities.guestcost * Bookings.slots
            ELSE Facilities.membercost * Bookings.slots END AS total_cost
FROM Bookings
JOIN Members ON Bookings.memid = Members.memid
JOIN Facilities ON Bookings.facid = Facilities.facid
WHERE Bookings.starttime BETWEEN '2012-09-14 00:00:00' AND '2012-09-14 23:59:59'
    AND CASE
          WHEN Members.memid = '0' THEN Facilities.guestcost * Bookings.slots
          ELSE Facilities.membercost * Bookings.slots END > 30
ORDER BY 3 DESC


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT name,
       facility_name,
       total_cost
FROM (
     SELECT b1.starttime,
            CASE 
                WHEN Members.firstname = 'GUEST' THEN 'GUEST'
                ELSE CONCAT(Members.firstname,' ',Members.surname) END AS name,
            Facilities.name AS facility_name,
            CASE
                WHEN Members.memid = '0' THEN Facilities.guestcost * b1.slots
                ELSE Facilities.membercost * b1.slots END AS total_cost
    FROM Bookings b1
    JOIN Members ON b1.memid = Members.memid
    JOIN Facilities ON b1.facid = Facilities.facid
    WHERE b1.starttime BETWEEN '2012-09-14 00:00:00' AND '2012-09-14 23:59:59'
    ) b2
WHERE total_cost > 30
ORDER BY 3 DESC


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT *
FROM(
SELECT facility_name,
       SUM(revenue) AS total_revenue
FROM
  ( SELECT facility_name,
           CASE
               WHEN TYPE = 'GUEST' THEN guest_cost * slots
               WHEN TYPE = 'MEMBER' THEN member_cost * slots
           END AS revenue
   FROM
     ( SELECT Facilities.name AS facility_name,
              CASE
                  WHEN Members.memid = '0' then 'GUEST'
                  WHEN Members.memid != '0' THEN 'MEMBER' END AS TYPE,
              Facilities.guestcost AS guest_cost,
              Facilities.membercost AS member_cost,
              b1.slots AS slots
      FROM Bookings b1
      JOIN Members
        ON b1.memid = Members.memid
      JOIN Facilities
        ON b1.facid = Facilities.facid ) b2
        ) b3
GROUP BY 1
ORDER BY 2
) b4
WHERE total_revenue < 1000