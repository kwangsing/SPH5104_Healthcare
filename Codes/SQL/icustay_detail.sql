-- ------------------------------------------------------------------
-- Title: Detailed information on ICUSTAY_ID
-- Description: This query provides a useful set of information regarding patient
--              ICU stays. The information is combined from the admissions, patients, and
--              icustays tables. It includes age, length of stay, sequence, and expiry flags.
-- MIMIC version: MIMIC-III v1.3
-- ------------------------------------------------------------------

-- This query extracts useful demographic/administrative information for patient ICU stays

DROP TABLE IF EXISTS icustay_detail;
CREATE TABLE icustay_detail AS
(
SELECT ie.subject_id, ie.hadm_id, ie.icustay_id

-- patient level factors
, pat.gender, pat.dod

-- hospital level factors
, adm.admittime, adm.dischtime
, DATETIME_DIFF(adm.dischtime, adm.admittime, 'DAY') as los_hospital
, DATETIME_DIFF(ie.intime, pat.dob, 'YEAR') as admission_age
, DENSE_RANK() OVER (PARTITION BY adm.subject_id ORDER BY adm.admittime) AS hospstay_seq
, CASE
    WHEN DENSE_RANK() OVER (PARTITION BY adm.subject_id ORDER BY adm.admittime) = 1 THEN True
    ELSE False END AS first_hosp_stay

-- 90-day mortality
, (CASE WHEN pat.dod ISNULL THEN 0
	 WHEN DATETIME_DIFF(pat.dod, adm.admittime, 'DAY') >= 90 THEN 0
	 WHEN DATETIME_DIFF(pat.dod, adm.admittime, 'DAY') < 90 THEN 1 END) AS mortality_90day

-- 30-day mortality
, (CASE WHEN pat.dod ISNULL THEN 0
	 WHEN DATETIME_DIFF(pat.dod, adm.admittime, 'DAY') >= 30 THEN 0
	 WHEN DATETIME_DIFF(pat.dod, adm.admittime, 'DAY') < 30 THEN 1 END) AS mortality_30day

-- in-hospital mortality
, (CASE WHEN pat.dod ISNULL THEN 0
	 WHEN DATETIME_DIFF(pat.dod, adm.admittime, 'DAY') > DATETIME_DIFF(adm.dischtime, adm.admittime, 'DAY') THEN 0
	 WHEN DATETIME_DIFF(pat.dod, adm.admittime, 'DAY') <= DATETIME_DIFF(adm.dischtime, adm.admittime, 'DAY') THEN 1 END) AS mortality_hos


-- icu level factors
, ie.intime, ie.outtime
, DATETIME_DIFF(ie.outtime, ie.intime, 'DAY') as los_icu
, DENSE_RANK() OVER (PARTITION BY ie.hadm_id ORDER BY ie.intime) AS icustay_seq
, ie.first_careunit
, ie.last_careunit

-- first ICU stay *for the current hospitalization*
, CASE
    WHEN DENSE_RANK() OVER (PARTITION BY ie.hadm_id ORDER BY ie.intime) = 1 THEN True
    ELSE False END AS first_icu_stay

-- height and weight
, hw.weight_first AS weight
, hw.height_first AS height

FROM icustays ie
INNER JOIN admissions adm
    ON ie.hadm_id = adm.hadm_id
INNER JOIN patients pat
    ON ie.subject_id = pat.subject_id
INNER JOIN heightweight hw ON ie.icustay_id = hw.icustay_id
	
WHERE adm.has_chartevents_data = 1
ORDER BY ie.subject_id, adm.admittime, ie.intime
);