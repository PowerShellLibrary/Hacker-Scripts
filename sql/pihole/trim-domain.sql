-- Trim leading and trailing characters from the domain field in the gravity table
UPDATE gravity
SET domain = TRIM(
                TRIM(SUBSTR(domain, CASE WHEN domain LIKE '||%' THEN 3 ELSE 1 END), '^')
            )
WHERE adlist_id = 26;