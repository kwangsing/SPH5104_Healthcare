-- It groups together any administration of the below list of drugs:
-- chartevents
-- "rocuronium" - 1052
-- "Vecuronium mcg/min" - 1856

-- inputeventscv
-- "Pancuronium" - 30129
-- "Vecuronium" - 30138
-- "Vecuronium drip" - 45096

-- inputeventsmv
-- "Vecuronium" - 222062

DROP TABLE IF EXISTS nmba_others;
CREATE TABLE nmba_others AS
(

(SELECT i.itemid, i.label, i.dbsource, i.linksto, mv.subject_id, mv.hadm_id, mv.icustay_id, mv.endtime as time 
, DENSE_RANK() OVER (PARTITION BY mv.icustay_id ORDER BY mv.endtime, mv.orderid) AS med_seq
, CASE
    WHEN DENSE_RANK() OVER (PARTITION BY mv.icustay_id ORDER BY mv.endtime, mv.orderid) = 1 THEN True
    ELSE False END AS first_med
FROM d_items i, inputevents_mv  mv
WHERE mv.itemid = i.itemid
AND i.itemid IN 
(222062)
ORDER BY i.itemid)
UNION
(SELECT i.itemid, i.label, i.dbsource, i.linksto, cv.subject_id, cv.hadm_id, cv.icustay_id, cv.charttime as time
, DENSE_RANK() OVER (PARTITION BY cv.icustay_id ORDER BY cv.charttime) AS med_seq
, CASE
    WHEN DENSE_RANK() OVER (PARTITION BY cv.icustay_id ORDER BY cv.charttime) = 1 THEN True
    ELSE False END AS first_med
FROM d_items i, inputevents_cv  cv
WHERE cv.itemid = i.itemid
AND i.itemid IN 
(30129, 30138, 45096)
ORDER BY i.itemid)
UNION
(SELECT i.itemid, i.label, i.dbsource, i.linksto, e.subject_id, e.hadm_id, e.icustay_id, e.charttime as time
, DENSE_RANK() OVER (PARTITION BY e.icustay_id ORDER BY e.charttime) AS med_seq
, CASE
    WHEN DENSE_RANK() OVER (PARTITION BY e.icustay_id ORDER BY e.charttime) = 1 THEN True
    ELSE False END AS first_med
FROM d_items i, chartevents  e
WHERE e.itemid = i.itemid
AND i.itemid IN 
(1052, 1856)
ORDER BY i.itemid)
);