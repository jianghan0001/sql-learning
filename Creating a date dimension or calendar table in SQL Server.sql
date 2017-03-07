--Creating a date dimension or calendar table in SQL Server
/*Problem
A calendar table can be immensely useful, particularly for reporting purposes, 
and for determining things like business days between two dates. I often see
 people struggling with manually populating a calendar or date dimension table; 
 usually there are lots of loops and iterative code constructs being used. In this 
 tip I will show you how to build and use a calendar table.

Solution
I build calendar tables all the time, for a variety of business applications, 
and have come up with a few ways to handle things. Sharing them here will 
hopefully prevent you from re-inventing any wheels when populating your own tables.

One of the biggest objections I hear to calendar tables is that people don't
want to create a table. I can't stress enough how cheap a table can be in 
terms of size and memory usage, especially as storage continues to be larger
and faster, compared to using all kinds of functions to determine date-related
information on every single query. The table I create below probably has a lot
more materialized columns than you would ever need, but it takes a whopping 
1.29 MB on disk and in memory (that covers 20 years; 30 years would be 1.86 MB,
and 50 years would be 3.08 MB). That will go up as you implement additional 
indexes, but still represents an extremely negligible impact in most systems.
I also always explicitly set things like DATEFORMAT, DATEFIRST, and LANGUAGE to avoid
ambiguity, default to English for month and day names, and assume that quarters for 
the fiscal year align with the calendar year. You may need to change some of these 
things depending on your display language, your fiscal year, and other factors.

This is a one-time population, so I'm not worried about the costs of using 
intermediate storage like temp tables. I like to materialize all of the columns
to disk, rather than rely on computed columns, since the table becomes read-only
after initial population. So I'm going to do a lot of those calculations during 
the initial population of the #temp table:
*/
DECLARE @StartDate DATE = '20000101', @NumberOfYears INT = 30;

-- prevent set or regional settings from interfering with 
-- interpretation of dates / literals

SET DATEFIRST 7;
SET DATEFORMAT mdy;
SET LANGUAGE US_ENGLISH;

DECLARE @CutoffDate DATE = DATEADD(YEAR, @NumberOfYears, @StartDate);

-- this is just a holding table for intermediate calculations:

CREATE TABLE #dim
(
  [date]       DATE PRIMARY KEY, 
  [day]        AS DATEPART(DAY,      [date]),
  [month]      AS DATEPART(MONTH,    [date]),
  FirstOfMonth AS CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, 0, [date]), 0)),
  [MonthName]  AS DATENAME(MONTH,    [date]),
  [week]       AS DATEPART(WEEK,     [date]),
  [ISOweek]    AS DATEPART(ISO_WEEK, [date]),
  [DayOfWeek]  AS DATEPART(WEEKDAY,  [date]),
  [quarter]    AS DATEPART(QUARTER,  [date]),
  [year]       AS DATEPART(YEAR,     [date]),
  FirstOfYear  AS CONVERT(DATE, DATEADD(YEAR,  DATEDIFF(YEAR,  0, [date]), 0)),
  Style112     AS CONVERT(CHAR(8),   [date], 112),
  Style101     AS CONVERT(CHAR(10),  [date], 101)
);

-- use the catalog views to generate as many rows as we need

INSERT #dim([date]) 
SELECT d
FROM
(
  SELECT d = DATEADD(DAY, rn - 1, @StartDate)
  FROM 
  (
    SELECT TOP (DATEDIFF(DAY, @StartDate, @CutoffDate)) 
      rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
    FROM sys.all_objects AS s1
    CROSS JOIN sys.all_objects AS s2
    -- on my system this would support > 5 million days
    ORDER BY s1.[object_id]
  ) AS x
) AS y;

/*At this point, #dim looks like this, just showing the first 5 and last 5 dates:

Truncated contents of #dim temporary table
Now these pre-calculated values can help to derive all of the other materialized 
columns you might want in your calendar table. The following is just a sampling of
 the things I see most commonly; I am sure that you do not need all of these columns, 
 and that there might be other columns you need. You should just use this as a starting point:
 */
 CREATE TABLE dbo.DateDimension
(
  DateKey             INT         NOT NULL PRIMARY KEY,
  [Date]              DATE        NOT NULL,
  [Day]               TINYINT     NOT NULL,
  DaySuffix           CHAR(2)     NOT NULL,
  [Weekday]           TINYINT     NOT NULL,
  WeekDayName         VARCHAR(10) NOT NULL,
  IsWeekend           BIT         NOT NULL,
  IsHoliday           BIT         NOT NULL,
  HolidayText         VARCHAR(64) SPARSE,
  DOWInMonth          TINYINT     NOT NULL,
  [DayOfYear]         SMALLINT    NOT NULL,
  WeekOfMonth         TINYINT     NOT NULL,
  WeekOfYear          TINYINT     NOT NULL,
  ISOWeekOfYear       TINYINT     NOT NULL,
  [Month]             TINYINT     NOT NULL,
  [MonthName]         VARCHAR(10) NOT NULL,
  [Quarter]           TINYINT     NOT NULL,
  QuarterName         VARCHAR(6)  NOT NULL,
  [Year]              INT         NOT NULL,
  MMYYYY              CHAR(6)     NOT NULL,
  MonthYear           CHAR(7)     NOT NULL,
  FirstDayOfMonth     DATE        NOT NULL,
  LastDayOfMonth      DATE        NOT NULL,
  FirstDayOfQuarter   DATE        NOT NULL,
  LastDayOfQuarter    DATE        NOT NULL,
  FirstDayOfYear      DATE        NOT NULL,
  LastDayOfYear       DATE        NOT NULL,
  FirstDayOfNextMonth DATE        NOT NULL,
  FirstDayOfNextYear  DATE        NOT NULL
);
GO
/*
A couple of notes:

DateKey is an INT not because that is my preference (I would always store this as a DATE), 
but because that seems to be the preference of most data warehousing professionals.
DOWInMonth is the occurrence of that weekday within the current month - 1st Sunday, 3rd Monday, etc.
Now to populate this table from our #dim object, it is a relatively straightforward INSERT/SELECT; 
still, you'll see why I pre-calculated some of the values, since many of the expressions are used multiple times:
 */


INSERT dbo.DateDimension WITH (TABLOCKX)
SELECT
  DateKey       = CONVERT(INT, Style112),
  [Date]        = [date],
  [Day]         = CONVERT(TINYINT, [day]),
  DaySuffix     = CONVERT(CHAR(2), CASE WHEN [day] / 10 = 1 THEN 'th' ELSE 
                  CASE RIGHT([day], 1) WHEN '1' THEN 'st' WHEN '2' THEN 'nd' 
	              WHEN '3' THEN 'rd' ELSE 'th' END END),
  [Weekday]     = CONVERT(TINYINT, [DayOfWeek]),
  [WeekDayName] = CONVERT(VARCHAR(10), DATENAME(WEEKDAY, [date])),
  [IsWeekend]   = CONVERT(BIT, CASE WHEN [DayOfWeek] IN (1,7) THEN 1 ELSE 0 END),
  [IsHoliday]   = CONVERT(BIT, 0),
  HolidayText   = CONVERT(VARCHAR(64), NULL),
  [DOWInMonth]  = CONVERT(TINYINT, ROW_NUMBER() OVER 
                  (PARTITION BY FirstOfMonth, [DayOfWeek] ORDER BY [date])),
  [DayOfYear]   = CONVERT(SMALLINT, DATEPART(DAYOFYEAR, [date])),
  WeekOfMonth   = CONVERT(TINYINT, DENSE_RANK() OVER 
                  (PARTITION BY [year], [month] ORDER BY [week])),
  WeekOfYear    = CONVERT(TINYINT, [week]),
  ISOWeekOfYear = CONVERT(TINYINT, ISOWeek),
  [Month]       = CONVERT(TINYINT, [month]),
  [MonthName]   = CONVERT(VARCHAR(10), [MonthName]),
  [Quarter]     = CONVERT(TINYINT, [quarter]),
  QuarterName   = CONVERT(VARCHAR(6), CASE [quarter] WHEN 1 THEN 'First' 
                  WHEN 2 THEN 'Second' WHEN 3 THEN 'Third' WHEN 4 THEN 'Fourth' END), 
  [Year]        = [year],
  MMYYYY        = CONVERT(CHAR(6), LEFT(Style101, 2)    + LEFT(Style112, 4)),
  MonthYear     = CONVERT(CHAR(7), LEFT([MonthName], 3) + LEFT(Style112, 4)),
  FirstDayOfMonth     = FirstOfMonth,
  LastDayOfMonth      = MAX([date]) OVER (PARTITION BY [year], [month]),
  FirstDayOfQuarter   = MIN([date]) OVER (PARTITION BY [year], [quarter]),
  LastDayOfQuarter    = MAX([date]) OVER (PARTITION BY [year], [quarter]),
  FirstDayOfYear      = FirstOfYear,
  LastDayOfYear       = MAX([date]) OVER (PARTITION BY [year]),
  FirstDayOfNextMonth = DATEADD(MONTH, 1, FirstOfMonth),
  FirstDayOfNextYear  = DATEADD(YEAR,  1, FirstOfYear)
FROM #dim
OPTION (MAXDOP 1);

/*
We're not done yet; all of the IsHoliday values are still set to 0. Since I am in the United States, 
I'm going to deal with statutory holidays here; of course, if you live in another country, you'll need 
to use different logic here. You'll also need to add your own company's holidays manually, but hopefully 
if you have things that are deterministic, like bank holidays, Boxing Day, or the third Monday of July 
is your annual off-site arm-wrestling tournament, you should be able to do most of that without much work 
by following the same sort of pattern I use below. We can update most of the stat holidays with a single 
pass and rather simple criteria:
*/

WITH x AS 
(
  SELECT DateKey, [Date], IsHoliday, HolidayText, FirstDayOfYear,
    DOWInMonth, [MonthName], [WeekDayName], [Day],
    LastDOWInMonth = ROW_NUMBER() OVER 
    (
      PARTITION BY FirstDayOfMonth, [Weekday] 
      ORDER BY [Date] DESC
    )
  FROM dbo.DateDimension
)
UPDATE x SET IsHoliday = 1, HolidayText = CASE
  WHEN ([Date] = FirstDayOfYear) 
    THEN 'New Year''s Day'
  WHEN ([DOWInMonth] = 3 AND [MonthName] = 'January' AND [WeekDayName] = 'Monday')
    THEN 'Martin Luther King Day'    -- (3rd Monday in January)
  WHEN ([DOWInMonth] = 3 AND [MonthName] = 'February' AND [WeekDayName] = 'Monday')
    THEN 'President''s Day'          -- (3rd Monday in February)
  WHEN ([LastDOWInMonth] = 1 AND [MonthName] = 'May' AND [WeekDayName] = 'Monday')
    THEN 'Memorial Day'              -- (last Monday in May)
  WHEN ([MonthName] = 'July' AND [Day] = 4)
    THEN 'Independence Day'          -- (July 4th)
  WHEN ([DOWInMonth] = 1 AND [MonthName] = 'September' AND [WeekDayName] = 'Monday')
    THEN 'Labour Day'                -- (first Monday in September)
  WHEN ([DOWInMonth] = 2 AND [MonthName] = 'October' AND [WeekDayName] = 'Monday')
    THEN 'Columbus Day'              -- Columbus Day (second Monday in October)
  WHEN ([MonthName] = 'November' AND [Day] = 11)
    THEN 'Veterans'' Day'            -- Veterans' Day (November 11th)
  WHEN ([DOWInMonth] = 4 AND [MonthName] = 'November' AND [WeekDayName] = 'Thursday')
    THEN 'Thanksgiving Day'          -- Thanksgiving Day (fourth Thursday in November)
  WHEN ([MonthName] = 'December' AND [Day] = 25)
    THEN 'Christmas Day'
  END
WHERE 
  ([Date] = FirstDayOfYear)
  OR ([DOWInMonth] = 3     AND [MonthName] = 'January'   AND [WeekDayName] = 'Monday')
  OR ([DOWInMonth] = 3     AND [MonthName] = 'February'  AND [WeekDayName] = 'Monday')
  OR ([LastDOWInMonth] = 1 AND [MonthName] = 'May'       AND [WeekDayName] = 'Monday')
  OR ([MonthName] = 'July' AND [Day] = 4)
  OR ([DOWInMonth] = 1     AND [MonthName] = 'September' AND [WeekDayName] = 'Monday')
  OR ([DOWInMonth] = 2     AND [MonthName] = 'October'   AND [WeekDayName] = 'Monday')
  OR ([MonthName] = 'November' AND [Day] = 11)
  OR ([DOWInMonth] = 4     AND [MonthName] = 'November' AND [WeekDayName] = 'Thursday')
  OR ([MonthName] = 'December' AND [Day] = 25);



 -- Black Friday is a little trickier, because it's the Friday after the fourth Thursday in November, and so it might be the fourth Friday, but several times a century it is actually the fifth Friday:

UPDATE d SET IsHoliday = 1, HolidayText = 'Black Friday'
FROM dbo.DateDimension AS d
INNER JOIN
(
  SELECT DateKey, [Year], [DayOfYear]
  FROM dbo.DateDimension 
  WHERE HolidayText = 'Thanksgiving Day'
) AS src 
ON d.[Year] = src.[Year] 
AND d.[DayOfYear] = src.[DayOfYear] + 1;

--And then there's Easter. This has always been a complicated problem; the rules for calculating the exact date are so convoluted, I suspect most people can only mark those dates where they have physical calendars they can look at to confirm. If your company doesn't recognize Easter, you can skip ahead; if it does, you can use the following function, which will return the Easter holiday dates for any given year:

CREATE FUNCTION dbo.GetEasterHolidays(@year INT) 
RETURNS TABLE
WITH SCHEMABINDING
AS 
RETURN 
(
  WITH x AS 
  (
    SELECT [Date] = CONVERT(DATE, RTRIM(@year) + '0' + RTRIM([Month]) 
        + RIGHT('0' + RTRIM([Day]),2))
      FROM (SELECT [Month], [Day] = DaysToSunday + 28 - (31 * ([Month] / 4))
      FROM (SELECT [Month] = 3 + (DaysToSunday + 40) / 44, DaysToSunday
      FROM (SELECT DaysToSunday = paschal - ((@year + @year / 4 + paschal - 13) % 7)
      FROM (SELECT paschal = epact - (epact / 28)
      FROM (SELECT epact = (24 + 19 * (@year % 19)) % 30) 
        AS epact) AS paschal) AS dts) AS m) AS d
  )
  SELECT [Date], HolidayName = 'Easter Sunday' FROM x
    UNION ALL SELECT DATEADD(DAY,-2,[Date]), 'Good Friday'   FROM x
    UNION ALL SELECT DATEADD(DAY, 1,[Date]), 'Easter Monday' FROM x
);

--(You can adjust the function easily, depending on whether they recognize just Easter Sunday or also Good Friday and/or Easter Monday. There is also another tip here that will show you how to determine the date for Mardi Gras, given the date for Easter.)

--Now, to use that function to mark the Easter holidays in the calendar table:

WITH x AS 
(
  SELECT d.[Date], d.IsHoliday, d.HolidayText, h.HolidayName
    FROM dbo.DateDimension AS d
    CROSS APPLY dbo.GetEasterHolidays(d.[Year]) AS h
    WHERE d.[Date] = h.[Date]
)
UPDATE x SET IsHoliday = 1, HolidayText = HolidayName;