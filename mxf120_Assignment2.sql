/*
* File: Assignment2_SubmissionTemplate.sql
* 
* 1) Rename this file according to the instructions in the assignment statement.
* 2) Use this file to insert your solution.
*
*
* Author: Fallon, Matthew
* Student ID Number: 2381420
* Institutional mail prefix: mxf120
*/


/*
*  Assume a user account 'fsad' with password 'fsad2022' with permission
* to create  databases already exists. You do NO need to include the commands
* to create the user nor to give it permission in you solution.
* For your testing, the following command may be used:
*
* CREATE USER fsad PASSWORD 'fsad2022' CREATEDB;
* GRANT pg_read_server_files TO fsad;
*/


/* *********************************************************
* Exercise 1. Create the Smoked Trout database
* 
************************************************************ */

-- The first time you login to execute this file with \i it may
-- be convenient to change the working directory.
  -- In PostgreSQL, folders are identified with '/'


-- 1) Create a database called SmokedTrout.

DROP DATABASE IF EXISTS "SmokedTrout";

CREATE DATABASE "SmokedTrout"
ENCODING = 'UTF8'
CONNECTION LIMIT = -1;

-- 2) Connect to the database

\c "SmokedTrout"


/* *********************************************************
* Exercise 2. Implement the given design in the Smoked Trout database
* 
************************************************************ */

-- 1) Create a new ENUM type called materialState for storing the raw material state

CREATE TYPE "MaterialState" AS ENUM ('Solid', 'Liquid', 'Gas', 'Plasma');

-- 2) Create a new ENUM type called materialComposition for storing whether
-- a material is Fundamental or Composite.

CREATE TYPE "MaterialComposition" AS ENUM ('Fundamental', 'Composite');

-- 3) Create the table TradingRoute with the corresponding attributes.

CREATE TABLE "TradingRoute"(
"MonitoringKey" SERIAL,
"FleetSize" integer,
"OperatingCompany" varchar(40),
"LastYearRevenue" real NOT NULL,
PRIMARY KEY ("MonitoringKey")
);

-- 4) Create the table Planet with the corresponding attributes.

CREATE TABLE "Planet" (
"PlanetID" SERIAL,
"StarSystem" varchar(40),
"Name" varchar(40),
"Population" integer,
PRIMARY KEY ("PlanetID")
);


-- 5) Create the table SpaceStation with the corresponding attributes.

CREATE TABLE "SpaceStation" (
"StationID" SERIAL,
"PlanetID" integer,
"Name" varchar(40),
"Longitude" varchar(40),
"Latitude" varchar(40),
PRIMARY KEY ("StationID"),
FOREIGN KEY ("PlanetID") REFERENCES "Planet"("PlanetID") ON DELETE CASCADE ON UPDATE CASCADE
);

-- 6) Create the parent table Product with the corresponding attributes.

CREATE TABLE "Product" (
"ProductID" SERIAL,
"Name" varchar(40),
"VolumePerTon" real,
"ValuePerTon" real,
PRIMARY KEY ("ProductID")
);

-- 7) Create the child table RawMaterial with the corresponding attributes.

CREATE TABLE "RawMaterial"(
"FundamentalOrComposite" "MaterialComposition",
"State" "MaterialState",
PRIMARY KEY ("ProductID")
)
INHERITS ("Product");

-- 8) Create the child table ManufacturedGood. 

CREATE TABLE "ManufacturedGood"(
PRIMARY KEY ("ProductID")
)
INHERITS ("Product");

-- 9) Create the table MadeOf with the corresponding attributes.

CREATE TABLE "MadeOf"(
"ManufacturedGoodID" integer NOT NULL,
"ProductID" integer NOT NULL
);


-- 10) Create the table Batch with the corresponding attributes.

CREATE TABLE "Batch"(
"BatchID" SERIAL,
"ProductID" integer NOT NULL,
"ExtractionOrManufacturingDate" date,
"OriginalFrom" integer NOT NULL,
PRIMARY KEY ("BatchID"),
FOREIGN KEY ("OriginalFrom") REFERENCES "Planet"("PlanetID") ON DELETE CASCADE ON UPDATE CASCADE
);


-- 11) Create the table Sells with the corresponding attributes.

CREATE TABLE "Sells" (
"BatchID" integer NOT NULL,
"StationID" integer NOT NULL,
FOREIGN KEY ("BatchID") REFERENCES "Batch"("BatchID") ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY ("StationID") REFERENCES "SpaceStation"("StationID") ON DELETE CASCADE ON UPDATE CASCADE
);


-- 12)  Create the table Buys with the corresponding attributes.

CREATE TABLE "Buys"(
"BatchID" integer NOT NULL,
"StationID" integer NOT NULL,
FOREIGN KEY ("BatchID") REFERENCES "Batch"("BatchID") ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY ("StationID") REFERENCES "SpaceStation"("StationID") ON DELETE CASCADE ON UPDATE CASCADE
);

-- 13)  Create the table CallsAt with the corresponding attributes.

CREATE TABLE "CallsAt" (
"MonitoringKey" integer NOT NULL,
"StationID" integer NOT NULL,
"VisitOrder" integer,
FOREIGN KEY ("MonitoringKey") REFERENCES "TradingRoute"("MonitoringKey") ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY ("StationID") REFERENCES "SpaceStation"("StationID") ON DELETE CASCADE ON UPDATE CASCADE
);

-- 14)  Create the table Distance with the corresponding attributes.

CREATE TABLE "Distance" (
"PlanetOrigin" integer NOT NULL,
"PlanetDestination" integer NOT NULL,
"AvgDistance" real,
FOREIGN KEY ("PlanetOrigin") REFERENCES "Planet"("PlanetID") ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY ("PlanetDestination") REFERENCES "Planet"("PlanetID") ON DELETE CASCADE ON UPDATE CASCADE
);

/* *********************************************************
* Exercise 3. Populate the Smoked Trout database
* 
************************************************************ */
/* *********************************************************
* NOTE: The copy statement is NOT standard SQL.
* The copy statement does NOT permit on-the-fly renaming columns,
* hence, whenever necessary, we:
* 1) Create a dummy table with the column name as in the file
* 2) Copy from the file to the dummy table
* 3) Copy from the dummy table to the real table
* 4) Drop the dummy table (This is done further below, as I keep
*    the dummy table also to imporrt the other columns)
************************************************************ */



-- 1) Unzip all the data files in a subfolder called data from where you have your code file 
-- NO CODE GOES HERE. THIS STEP IS JUST LEFT HERE TO KEEP CONSISTENCY WITH THE ASSIGNMENT STATEMENT

-- 2) Populate the table TradingRoute with the data in the file TradeRoutes.csv.

\copy "TradingRoute"("MonitoringKey", "FleetSize", "OperatingCompany", "LastYearRevenue") FROM './data/TradeRoutes.csv'  DELIMITER ',' CSV HEADER;

-- 3) Populate the table Planet with the data in the file Planets.csv.

\copy "Planet"("PlanetID", "StarSystem", "Name", "Population") FROM './data/Planets.csv'  DELIMITER ',' CSV HEADER;

-- 4) Populate the table SpaceStation with the data in the file SpaceStations.csv.

\copy "SpaceStation"("StationID", "PlanetID", "Name", "Longitude", "Latitude") FROM './data/SpaceStations.csv'  DELIMITER ',' CSV HEADER;

-- 5) Populate the tables RawMaterial and Product with the data in the file Products_Raw.csv. 

CREATE TABLE "DummyRaw"(
"ProductID" integer NOT NULL,
"Product" varchar(40),
"FundamentalOrComposite" varchar(40),
"VolumePerTon" real,
"ValuePerTon" real,
"State" "MaterialState"
);

\copy "DummyRaw"("ProductID", "Product", "FundamentalOrComposite", "VolumePerTon", "ValuePerTon", "State") FROM './data/Products_Raw.csv'  DELIMITER ',' CSV HEADER;

UPDATE "DummyRaw"
SET "FundamentalOrComposite" = 'Fundamental'
WHERE "FundamentalOrComposite" = 'No';

UPDATE "DummyRaw"
SET "FundamentalOrComposite" = 'Composite'
WHERE "FundamentalOrComposite" = 'Yes';

ALTER TABLE "DummyRaw"
ALTER "FundamentalOrComposite"
TYPE "MaterialComposition"
USING "FundamentalOrComposite"::"MaterialComposition";

INSERT INTO "RawMaterial" ("ProductID", "Name", "FundamentalOrComposite", "VolumePerTon", "ValuePerTon", "State")

SELECT "ProductID", "Product", "FundamentalOrComposite", "VolumePerTon", "ValuePerTon", "State"
FROM "DummyRaw";

DROP TABLE "DummyRaw" CASCADE;


-- 6) Populate the tables ManufacturedGood and Product with the data in the file  Products_Manufactured.csv.

\copy "ManufacturedGood"("ProductID", "Name", "VolumePerTon", "ValuePerTon") FROM './data/Products_Manufactured.csv'  DELIMITER ',' CSV HEADER;

-- 7) Populate the table MadeOf with the data in the file MadeOf.csv.

\copy "MadeOf"("ManufacturedGoodID", "ProductID") FROM './data/MadeOf.csv'  DELIMITER ',' CSV HEADER;

-- 8) Populate the table Batch with the data in the file Batches.csv.

\copy "Batch"("BatchID", "ProductID", "ExtractionOrManufacturingDate", "OriginalFrom") FROM './data/Batches.csv'  DELIMITER ',' CSV HEADER;

-- 9) Populate the table Sells with the data in the file Sells.csv.

\copy "Sells"("BatchID", "StationID") FROM './data/Sells.csv'  DELIMITER ',' CSV HEADER;

-- 10) Populate the table Buys with the data in the file Buys.csv.

\copy "Buys"("BatchID", "StationID") FROM './data/Buys.csv'  DELIMITER ',' CSV HEADER;

-- 11) Populate the table CallsAt with the data in the file CallsAt.csv.

\copy "CallsAt"("MonitoringKey", "StationID", "VisitOrder") FROM './data/CallsAt.csv'  DELIMITER ',' CSV HEADER;

-- 12) Populate the table Distance with the data in the file PlanetDistances.csv.

\copy "Distance"("PlanetOrigin", "PlanetDestination", "AvgDistance") FROM './data/PlanetDistances.csv'  DELIMITER ',' CSV HEADER;




/* *********************************************************
* Exercise 4. Query the database
* 
************************************************************ */

-- 4.1 Report last year taxes per company

-- 1) Add an attribute Taxes to table TradingRoute

ALTER TABLE "TradingRoute"
ADD "Taxes" real;

-- 2) Set the derived attribute taxes as 12% of LastYearRevenue

UPDATE "TradingRoute"
SET "Taxes" = "LastYearRevenue" * 0.12;

-- 3) Report the operating company and the sum of its taxes group by company.

SELECT "OperatingCompany", SUM("Taxes")
FROM "TradingRoute"
GROUP BY "OperatingCompany";




-- 4.2 What's the longest trading route in parsecs?

-- 1) Create a dummy table RouteLength to store the trading route and their lengths.

CREATE TABLE "RouteLength"(
"RouteMonitoringKey" integer NOT NULL,
"RouteTotalDistance" numeric,
FOREIGN KEY ("RouteMonitoringKey") REFERENCES "TradingRoute"("MonitoringKey") ON DELETE CASCADE ON UPDATE CASCADE
);


-- 2) Create a view EnrichedCallsAt that brings together trading route, space stations and planets.

CREATE VIEW "EnrichedCallsAt"
AS SELECT "SpaceStation"."StationID", "SpaceStation"."PlanetID" AS "Planet", "SpaceStation"."Name", "SpaceStation"."Longitude", "SpaceStation"."Latitude", "CallsAt"."MonitoringKey", "CallsAt"."VisitOrder"
FROM "SpaceStation"
INNER JOIN "CallsAt" ON "SpaceStation"."StationID" = "CallsAt"."StationID";


-- 3) Add the support to execute an anonymous code block as follows;

DO
$$
DECLARE

-- 4) Within the declare section, declare a variable of type real to store a route total distance.

"TotalDistance" real := 0.0;

-- 5) Within the declare section, declare a variable of type real to store a hop partial distance.

"RouteDistancePartial" real := 0.0;

-- 6) Within the declare section, declare a variable of type record to iterate over routes.

"RRoute" record;

-- 7) Within the declare section, declare a variable of type record to iterate over hops.

"RHop" record;

-- 8) Within the declare section, declare a variable of type text to transiently build dynamic queries.

"Query" text;

-- 9) Within the main body section, loop over routes in TradingRoutes

BEGIN

    FOR "RRoute" IN SELECT "MonitoringKey" FROM "TradingRoute"

    LOOP
-- 10) Within the loop over routes, get all visited planets (in order) by this trading route.

        "Query" := 'CREATE VIEW "PortsOfCall" AS '
        || 'SELECT "Planet" , "VisitOrder" '
        || 'FROM "EnrichedCallsAt" '
        || 'WHERE "MonitoringKey" = ' || "RRoute"."MonitoringKey"
        || ' ORDER BY "VisitOrder"';

-- 11) Within the loop over routes, execute the dynamic view

        EXECUTE "Query";

-- 12) Within the loop over routes, create a view Hops for storing the hops of that route. 

        CREATE VIEW "Hops" AS
        SELECT "P1"."Planet" AS "PlanetOrigin", "P2"."Planet" AS "PlanetDestination"
        FROM "PortsOfCall" "P1"
        INNER JOIN "PortsOfCall" "P2"
        ON "P1"."VisitOrder" = "P2"."VisitOrder" -1;


-- 13) Within the loop over routes, initialize the route total distance to 0.0.

        "TotalDistance" := 0.0;

-- 14) Within the loop over routes, create an inner loop over the hops

        FOR "RHop" IN SELECT "PlanetOrigin", "PlanetDestination" FROM "Hops"

            LOOP

-- 15) Within the loop over hops, get the partial distances of the hop. 

            "Query" := 'SELECT "AvgDistance" '
            || 'FROM "Distance" '
            || 'WHERE "PlanetOrigin" = ' || "RHop"."PlanetOrigin"
            || ' AND "PlanetDestination" = ' || "RHop"."PlanetDestination";

-- 16)  Within the loop over hops, execute the dynamic view and store the outcome INTO the hop partial distance.

            EXECUTE "Query" INTO "RouteDistancePartial";

-- 17)  Within the loop over hops, accumulate the hop partial distance to the route total distance.

            "TotalDistance" := "TotalDistance" + "RouteDistancePartial";

            END LOOP;
-- 18)  Go back to the routes loop and insert into the dummy table RouteLength the pair (RouteMonitoringKey,RouteTotalDistance).

    INSERT INTO "RouteLength"("RouteMonitoringKey", "RouteTotalDistance")
    VALUES ("RRoute"."MonitoringKey", "TotalDistance");

-- 19)  Within the loop over routes, drop the view for Hops (and cascade to delete dependent objects).

    DROP VIEW "Hops" CASCADE;

-- 20)  Within the loop over routes, drop the view for PortsOfCall (and cascade to delete dependent objects).
    DROP VIEW "PortsOfCall" CASCADE;

    END LOOP;
END;
$$;


-- 21)  Finally, just report the longest route in the dummy table RouteLength.

SELECT "RouteMonitoringKey", "RouteTotalDistance"
FROM "RouteLength"
WHERE "RouteTotalDistance" = (SELECT MAX("RouteTotalDistance") FROM "RouteLength");


