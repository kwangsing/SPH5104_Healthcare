-- It groups together any administration ECMO:
-- chartevents
-- "ecmo" -- 6758
-- "ECMO" -- 224660
-- "ECMO" -- 5931
-- "Oxygenator/ECMO" - 228193


DROP TABLE IF EXISTS ecmo;
CREATE TABLE ecmo AS
(
SELECT i.itemid, i.label, i.dbsource, i.linksto, e.subject_id, e.hadm_id, e.icustay_id, e.charttime as time
, DENSE_RANK() OVER (PARTITION BY e.icustay_id ORDER BY e.charttime) AS med_seq

FROM d_items i, chartevents  e
WHERE e.itemid = i.itemid
AND i.itemid IN 
(6758, 224660, 5931, 228193)
ORDER BY i.itemid
);