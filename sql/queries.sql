-- Create Tables
CREATE TABLE cd.members
(
    memid INTEGER NOT NULL,
    surname VARCHAR(200) NOT NULL,
    firstname VARCHAR(200) NOT NULL,
    address VARCHAR(300) NOT NULL,
    zipcode INTEGER NOT NULL,
    telephone VARCHAR(20) NOT NULL,
    recommendedby INTEGER,
    joindate TIMESTAMP NOT NULL,
    CONSTRAINT members_pk PRIMARY KEY (memid),
    CONSTRAINT fk_members_recommendedby FOREIGN KEY (recommendedby)
    REFERENCES cd.members(memid) ON DELETE SET NULL
);


CREATE TABLE cd.facilities
(
    facid INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL,
    membercost NUMERIC NOT NULL,
    guestcost NUMERIC NOT NULL,
    initialoutlay NUMERIC NOT NULL,
    monthlymaintenance NUMERIC NOT NULL,
    CONSTRAINT facilities_pk PRIMARY KEY (facid)
);

CREATE TABLE cd.bookings
(
    facid INTEGER NOT NULL,
    memid INTEGER NOT NULL,
    starttime TIMESTAMP NOT NULL,
    slots INTEGER NOT NULL,
    CONSTRAINT bookings_pk PRIMARY KEY (facid),
    CONSTRAINT fk_bookings_facid FOREIGN KEY (facid) REFERENCES cd.facilities(facid),
    CONSTRAINT fk_bookings_memid FOREIGN KEY (memid) REFERENCES cd.members(memid)
);

-- Modifying Data

-- Question 1
-- The club is adding a new facility - a spa. We need to add it into the facilities table. Use the following values: facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.

INSERT INTO cd.facilities (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance) VALUES (9, 'Spa', 20, 30, 100000, 800);

-- Question 2
-- Let's try adding the spa to the facilities table again. This time, though, we want to automatically generate the value for the next facid, rather than specifying it as a constant. Use the following values for everything else: Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.

INSERT INTO cd.facilities (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance) VALUES ((SELECT max(facid)+1 FROM cd.facilities),'Spa', 20, 30, 100000, 800);

-- Question 3
-- We made a mistake when entering the data for the second tennis court. The initial outlay was 10000 rather than 8000: you need to alter the data to fix the error.
UPDATE cd.facilities
SET initialoutlay=10000
WHERE name='Tennis Court 2';

-- Question 4
-- We want to alter the price of the second tennis court so that it costs 10% more than the first one. Try to do this without using constant values for the prices, so that we can reuse the statement if we want to.
UPDATE cd.facilities
SET membercost = membercost * 1.1, guestcost = guestcost * 1.1
WHERE facid = 1;

-- Question 5
-- As part of a clearout of our database, we want to delete all bookings from the cd.bookings table. How can we accomplish this?
DELETE FROM cd.bookings;

--Question 6
--We want to remove member 37, who has never made a booking, from our database. How can we achieve that?
DELETE FROM  cd.members
WHERE memid = 37;

