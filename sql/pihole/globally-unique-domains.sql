-- This SQL query calculates the percentage of globally unique domains in each adlist from the vw_gravity view.
-- Run trim-domain.sql before executing this query to ensure that the domain field is clean and trimmed.
SELECT
    g1.adlist_id,
    COUNT(*) AS total_domains,
    SUM(CASE WHEN dup_counts.domain_count = 1 THEN 1 ELSE 0 END) AS globally_unique_domains,
    ROUND(SUM(CASE WHEN dup_counts.domain_count = 1 THEN 1.0 ELSE 0 END) / COUNT(*) * 100, 2) AS uniqueness_percent
FROM
    vw_gravity g1
JOIN (
    SELECT domain, COUNT(DISTINCT adlist_id) AS domain_count
    FROM vw_gravity
    GROUP BY domain
) dup_counts ON g1.domain = dup_counts.domain
GROUP BY
    g1.adlist_id
ORDER BY
    uniqueness_percent DESC;

-- Example output:
-- adlist_id	total_domains	globally_unique_domains	uniqueness_percent
-- 4	        319548	        319548	                100.0
-- 2	        2194	        2194	                100.0
-- 7	        31461	        29665	                94.29
-- 1	        106611	        100485	                94.25
-- 6	        42536	        38253	                89.93
-- 5	        307383	        249377	                81.13
-- 3	        162079	        96220	                59.37