-- It groups together any administration of prone position:
-- chartevents
-- "position" - 1844
-- "Position" - 547
-- "Position" - 224093

DROP TABLE IF EXISTS prone;
CREATE TABLE prone AS
(
SELECT i.itemid, i.label, i.dbsource, i.linksto, e.subject_id, e.hadm_id, e.icustay_id, e.charttime as time,
	e.value

FROM d_items i, chartevents  e
WHERE e.itemid = i.itemid
AND i.itemid IN 
(1844, 547, 224093)
AND e.value ILIKE '%prone%'
ORDER BY i.itemid
);