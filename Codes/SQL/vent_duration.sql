DROP TABLE IF EXISTS vent_duration;
CREATE TABLE vent_duration AS

(
SELECT v.icustay_id, SUM(v.duration_hours) AS vent_duration
FROM ventilation_durations v
GROUP BY v.icustay_id
);