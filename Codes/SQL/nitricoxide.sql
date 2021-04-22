-- It groups together any administration of nitric oxide:
-- chartevents
-- "Inhaled Nitric Oxide" - 7988
-- "INO" - 6095
-- "nitric oxide" - 5952
-- "Nitric oxide" - 2131
-- "Nitric Oxide" - 224749
-- "Nitric Oxide" - 2056
-- "NITRIC OXIDE" - 2717
-- "no" - 2504
-- "N.O." - 2643
-- "NO" - 2665

DROP TABLE IF EXISTS nitricoxide;
CREATE TABLE nitricoxide AS
(
SELECT i.itemid, i.label, i.dbsource, i.linksto, e.subject_id, e.hadm_id, e.icustay_id, e.charttime as time

FROM d_items i, chartevents  e
WHERE e.itemid = i.itemid
AND i.itemid IN 
(7988, 6095, 5952, 2131, 224749, 2056, 2717, 2504, 2643, 2665)
ORDER BY i.itemid
);