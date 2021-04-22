-- It groups together any administration of the below list of drugs:
-- chartevents
-- "cisatricurium" - 1000
-- "cisatra mcg/kg/min" - 1023
-- "Cisatracurium" - 1028
-- "Cisatricurium" - 1771
-- "cisatracurium" - 1858
-- "CIS/CURIUM MG/KG/HR" - 2301
-- "cisatracuri/mcg/kg/m" - 2310
-- "CISATRACUR MCG/K/MIN" - 2330
-- "cist mcg/kg/min." - 2336
-- "CISATRACUR MCG/KG/MN" - 2360
-- "CISATRICURI MCG/K/MI" - 2413
-- "CISATRACUR.MCG/KG/MI" - 2480
-- "cisatricurium/mc/k/m" - 2497
-- "cisatricurium mg/k/h" - 2502
-- "CISATRACURIUM GTT" - 2511
-- "Cisatracu mg/kg/hr" - 2517
-- "CISATRACURIUMMG/KG/H" - 2546
-- "Cisatr mcg/kg/min" - 2554

-- inputeventscv
-- "Cisatracurium" - 30114
-- "cisatricurium" - 40552
-- "cistatracurium" - 42100
-- "cistacur mcq/kg/min" - 42134
-- "CISATRICARIUM CC/HR" - 42246
-- "cisatricurium cc/hr" - 42310
-- "CISTRACURIUM" - 42353
-- "Cisatracurium gtt" - 42385
-- "Cisat mcg/kg/min" - 42414

-- inputeventsmv
-- "Cisatracurium" - 221555

DROP TABLE IF EXISTS cisatracurium;
CREATE TABLE cisatracurium AS
(

(SELECT i.itemid, i.label, i.dbsource, i.linksto, mv.subject_id, mv.hadm_id, mv.icustay_id, mv.endtime as time 
, DENSE_RANK() OVER (PARTITION BY mv.icustay_id ORDER BY mv.endtime, mv.orderid) AS med_seq
, CASE
    WHEN DENSE_RANK() OVER (PARTITION BY mv.icustay_id ORDER BY mv.endtime, mv.orderid) = 1 THEN True
    ELSE False END AS first_med
FROM d_items i, inputevents_mv  mv
WHERE mv.itemid = i.itemid
AND i.itemid IN 
(221555)
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
(30114, 40552, 42100, 42134, 42246, 42310, 42353, 42385, 42414)
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
(1000, 1023, 1028, 1771, 1858, 2301, 2310, 2330, 
 2336, 2360, 2413, 2480, 2497, 2502, 2511, 2517, 2546, 2554)
ORDER BY i.itemid)
);