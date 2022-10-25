
SELECT 
	a.url AS "Unique URL",
	a.name AS "Name", 
	a.gender AS "Gender", 
	a.country AS "Country", 
	a.discipline AS "Discipline", 
	LEFT(m.medal_type, CHARINDEX(' ', m.medal_type)-1) AS "Medal Type",
	m.event AS "Event", 
	CONVERT(DATE, m.medal_date) AS "Medal Date"
FROM dbo.athletes a
LEFT JOIN dbo.medals m
	ON a.url = m.athlete_link;
