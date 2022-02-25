--  CREATED BY JIE DING ON 25/02/2022
use Call_Center_Agent_Metrics;

-- -------------------prepping, cleaning, and unioning month data-----------------
-- ------------------------------------------------------------------------

-- add Transfers for month 1-4 
Alter table month_0 add Transfers bigint default Null after Sentiment;
Alter table month_1 add Transfers bigint default Null after Sentiment;
Alter table month_2 add Transfers bigint default Null after Sentiment;
Alter table month_3 add Transfers bigint default Null after Sentiment;

-- Create a temp table 
DROP TABLE IF EXISTS temp;
CREATE TABLE IF NOT EXISTS temp AS SELECT * FROM
    month_0
WHERE
    1 = 2;

-- call stored procedure to fill the temp table 
Call Temp_fill();

-- update month_0
ALTER TABLE month_0 ADD primary key (AgentID);
REPLACE INTO month_0
-- use backtick instead of single quotes
SELECT temp.AgentID, m.`Calls Offered`, m.`Calls Not Answered`, m.`Calls Answered`, m.`Total Duration`, m.`Sentiment`, m.`Transfers`
FROM month_0 AS m
RIGHT JOIN temp using (AgentID);

ALTER TABLE month_0 ADD Month_start_Date date after AgentID;
UPDATE month_0 SET Month_start_Date='2021-01-01';

-- update month_1
ALTER TABLE month_1 ADD primary key (AgentID);
REPLACE INTO month_1
SELECT temp.AgentID, m.`Calls Offered`, m.`Calls Not Answered`, m.`Calls Answered`, m.`Total Duration`, m.`Sentiment`, m.`Transfers`
FROM month_1 AS m
RIGHT JOIN temp using (AgentID);

ALTER TABLE month_1 ADD Month_start_Date date after AgentID;
UPDATE month_1 SET Month_start_Date='2021-02-01';

-- update month_2
ALTER TABLE month_2 ADD primary key (AgentID);
REPLACE INTO month_2
SELECT temp.AgentID, m.`Calls Offered`, m.`Calls Not Answered`, m.`Calls Answered`, m.`Total Duration`, m.`Sentiment`, m.`Transfers`
FROM month_2 as m
RIGHT JOIN temp using (AgentID);

ALTER TABLE month_2 ADD Month_start_Date date after AgentID;
UPDATE month_2 SET Month_start_Date='2021-03-01';

-- update month_3
ALTER TABLE month_3 ADD primary key (AgentID);
REPLACE INTO month_3
SELECT temp.AgentID, m.`Calls Offered`, m.`Calls Not Answered`, m.`Calls Answered`, m.`Total Duration`, m.`Sentiment`, m.`Transfers`
FROM month_3 as m
RIGHT JOIN temp using (AgentID);

ALTER TABLE month_3 ADD Month_start_Date date after AgentID;
UPDATE month_3 SET Month_start_Date='2021-04-01';

-- update month_4-11
ALTER TABLE month_4 ADD Month_start_Date date after AgentID;
UPDATE month_4 SET Month_start_Date='2021-05-01';

ALTER TABLE month_5 ADD Month_start_Date date after AgentID;
UPDATE month_5 SET Month_start_Date='2021-06-01';

ALTER TABLE month_6 ADD Month_start_Date date after AgentID;
UPDATE month_6 SET Month_start_Date='2021-07-01';

ALTER TABLE month_7 ADD Month_start_Date date after AgentID;
UPDATE month_7 SET Month_start_Date='2021-08-01';

ALTER TABLE month_8 ADD Month_start_Date date after AgentID;
UPDATE month_8 SET Month_start_Date='2021-09-01';

ALTER TABLE month_9 ADD Month_start_Date date after AgentID;
UPDATE month_9 SET Month_start_Date='2021-10-01';

ALTER TABLE month_10 ADD Month_start_Date date after AgentID;
UPDATE month_10 SET Month_start_Date='2021-11-01';

ALTER TABLE month_11 ADD Month_start_Date date after AgentID;
UPDATE month_11 SET Month_start_Date='2021-12-01';


-- union all month tables  --1620 ROWS
DROP TABLE IF EXISTS Month_all;
CREATE TABLE IF NOT EXISTS Month_all 
AS
SELECT 
    *
FROM
    month_0
UNION ALL TABLE month_1
UNION ALL TABLE month_2
UNION ALL TABLE month_3
UNION ALL TABLE month_4
UNION ALL TABLE month_5
UNION ALL TABLE month_6
UNION ALL TABLE month_7
UNION ALL TABLE month_8
UNION ALL TABLE month_9
UNION ALL TABLE month_10
UNION ALL TABLE month_11;

-- ADD columns 'Not Answered Rate'
ALTER TABLE month_all ADD Not_Answered_Rate float after `Calls Answered`;
UPDATE month_all SET Not_Answered_Rate= `Calls Not Answered`/`Calls Offered`;

-- ADD columns 'Not Answered Rate'
ALTER TABLE month_all ADD Met_Not_Answered_Rate varchar(16) after Not_Answered_Rate;
UPDATE month_all 
SET Met_Not_Answered_Rate= 
(CASE 
WHEN Not_Answered_Rate< 0.05 THEN 'True'
ELSE 'False'
END);

-- ADD columns 'Agent Avg Duration'
ALTER TABLE month_all ADD Agent_Avg_Duration float after `Total Duration`;
UPDATE month_all SET Agent_Avg_Duration= `Total Duration`/`Calls Offered`;

-- ADD columns 'Met Sentiment Goal'
ALTER TABLE month_all ADD Met_Sentiment_Goal varchar(16) after Sentiment;
UPDATE month_all 
SET Met_Sentiment_Goal= 
(CASE 
WHEN Sentiment>= 0 THEN 'True'
ELSE 'False'
END);

-- ------------------------------------------------------------------------
-- --------------- join people data --------------------------------
DROP TABLE IF EXISTS people_data;
CREATE TABLE IF NOT EXISTS people_data as 
SELECT p.id, concat_ws(', ', p.first_name, p.last_name) AS Agent_Name, p.`Leader 1`, 
concat_ws(', ', l.first_name, l.last_name) AS Leader_Name, Location
FROM people as p
LEFT JOIN leaders as l 
ON  p.`leader 1`=l.id
LEFT JOIN location 	USING (`Location ID`)
ORDER BY id;


-- ------------------------------------------------------------------------
-- --------------- join people_data AND month_all--------------------------------
DROP TABLE IF EXISTS output_table;
CREATE TABLE IF NOT EXISTS output_table as 
SELECT *
FROM people_data as pd
LEFT JOIN month_all as ma
ON pd.id=ma.AgentID
ORDER BY id, Month_start_Date;

ALTER TABLE output_table DROP AgentID;