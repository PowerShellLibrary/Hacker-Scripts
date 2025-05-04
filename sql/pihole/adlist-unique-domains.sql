-- This SQL query retrieves the number of unique domains and total domains for each adlist from the vw_gravity view.
-- It calculates the uniqueness percentage and orders the results by this percentage in ascending order.

SELECT
    adlist_id,
    COUNT(DISTINCT domain) AS unique_domains,
    COUNT(domain) AS total_domains,
    ROUND(CAST(COUNT(DISTINCT domain) AS FLOAT) / COUNT(domain) * 100, 2) AS uniqueness_percent
FROM
    vw_gravity
GROUP BY
    adlist_id
ORDER BY
    uniqueness_percent ASC;


-- Example output:
-- adlist_id	unique_domains	total_domains	uniqueness_percent
-- 7	        30873	        31461	        98.13
-- 6	        42363	        42536	        99.59
-- 1	        106610	        106611	        100.0
-- 2	        2194	        2194	        100.0
-- 3	        162079	        162079	        100.0
-- 4	        319548	        319548	        100.0
-- 5	        307383	        307383	        100.0