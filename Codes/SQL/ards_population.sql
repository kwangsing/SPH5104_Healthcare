SET search_path TO group4,mimiciii;

DROP TABLE IF EXISTS ARDS_population;
CREATE TABLE ARDS_population AS

(
SELECT i.subject_id, i.hadm_id, i.icustay_id

-- patient level factors
, i.gender, i.dod

-- hospital level factors
, i.admittime, i.dischtime
, i.los_hospital
, i.admission_age
, i.first_hosp_stay

-- mortality
, i.mortality_90day
, i.mortality_30day
, i.mortality_hos

-- icu level factors
, i.intime, i.outtime
, i.los_icu
, i.first_careunit
, i.last_careunit

-- first ICU stay *for the current hospitalization*
, i.first_icu_stay

-- diagnosis
, d.icd9_code

-- height and weight
, i.height
, i.weight

-- use of Cisatracurium
, (CASE WHEN i.subject_id  IN (SELECT cis.subject_id FROM cisatracurium cis) THEN 1
	 ELSE 0 END) AS cisatracurium

-- use of other NMBAs
, (CASE WHEN i.subject_id  IN (SELECT n.subject_id FROM nmba_others n) THEN 1
	 ELSE 0 END) AS nmba_others

-- whether above 18 years old
, (CASE WHEN i.admission_age  >= 18 THEN 1
	 ELSE 0 END) AS above18

-- whether longer than 24h stay
, (CASE WHEN i.los_icu >= 1 THEN 1
	 ELSE 0 END) AS longer_than_24h

-- use of ECMO
, (CASE WHEN i.subject_id  IN (SELECT e.subject_id FROM ecmo e) THEN 1
	 ELSE 0 END) AS ecmo

-- use of inhaled nitric oxide
, (CASE WHEN i.subject_id  IN (SELECT ino.subject_id FROM nitricoxide ino) THEN 1
	 ELSE 0 END) AS nitric_oxide

-- use of ECMO
, (CASE WHEN i.subject_id  IN (SELECT h.subject_id FROM hfov h) THEN 1
	 ELSE 0 END) AS hfov



FROM icustay_detail i 
INNER JOIN diagnoses_icd d ON i.hadm_id = d.hadm_id

WHERE (d.icd9_code='51882' OR d.icd9_code = '5185') -- ARDS diagnosis
AND i.first_icu_stay = 'True' -- TAKE ONLY FIRST ICUSTAY RECORD
ORDER BY i.subject_id, i.admittime, i.intime
);