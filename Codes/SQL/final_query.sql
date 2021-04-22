SET search_path TO group4,mimiciii;


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
, i.icd9_code

-- height and weight
, i.height
, i.weight

-- use of Cisatracurium
, c.time AS time_cisatra -- TIME WHEN FIRST DOSE OF CISATRACURIUM WAS GIVEN
, (CASE WHEN  c.time ISNULL THEN NULL
  	WHEN DATETIME_DIFF(c.time, i.intime, 'HOUR') <0 THEN 0
  	ELSE DATETIME_DIFF(c.time, i.intime, 'HOUR') END) 
	AS admin_duration -- NUMBER OF HOURS BETWEEN CIS ADMINISTRATION AND ICU ADMISSION

-- use of other NMBAs
, i.nmba_others

-- whether above 18 years old
, i.above18

-- whether longer than 24h stay
, i.longer_than_24h

-- use of ECMO
, i.ecmo

-- use of inhaled nitric oxide
, i.nitric_oxide

-- ventilation duration
, vd.vent_duration

-- SAPSII score
, sap.sapsii

-- SOFA score
, sof.sofa

-- whether value is before or after 48hour cisatracurium administration. 
-- for unexposed, use median duration of 17hours
, CASE WHEN c.time ISNULL THEN
	(CASE WHEN DATETIME_DIFF(bg.charttime, DATETIME_ADD(i.intime, INTERVAL '17' HOUR), 'HOUR') <0 THEN 'BEFORE'
	 WHEN DATETIME_DIFF(bg.charttime, DATETIME_ADD(i.intime, INTERVAL '17' HOUR), 'HOUR') BETWEEN 0  AND 47.99 THEN 'DURING'
	 WHEN DATETIME_DIFF(bg.charttime, DATETIME_ADD(i.intime, INTERVAL '17' HOUR), 'HOUR') >=48 THEN 'AFTER' END)
	 ELSE (CASE WHEN DATETIME_DIFF(bg.charttime, c.time, 'HOUR') <0 THEN 'BEFORE'
		   WHEN DATETIME_DIFF(bg.charttime, c.time, 'HOUR') BETWEEN 0  AND 47.99 THEN 'DURING'
   		   WHEN DATETIME_DIFF(bg.charttime, c.time, 'HOUR') >=48 THEN 'AFTER' END) END AS hour48
		   
-- whether value is before or after 24hour cisatracurium administration. 
-- for unexposed, use median duration of 17hours
, CASE WHEN c.time ISNULL THEN
	(CASE WHEN DATETIME_DIFF(bg.charttime, DATETIME_ADD(i.intime, INTERVAL '17' HOUR), 'HOUR') <0 THEN 'BEFORE'
	 WHEN DATETIME_DIFF(bg.charttime, DATETIME_ADD(i.intime, INTERVAL '17' HOUR), 'HOUR') BETWEEN 0  AND 23.99 THEN 'DURING'
	 WHEN DATETIME_DIFF(bg.charttime, DATETIME_ADD(i.intime, INTERVAL '17' HOUR), 'HOUR') >=24 THEN 'AFTER' END)
	 ELSE (CASE WHEN DATETIME_DIFF(bg.charttime, c.time, 'HOUR') <0 THEN 'BEFORE'
		   WHEN DATETIME_DIFF(bg.charttime, c.time, 'HOUR') BETWEEN 0  AND 23.99 THEN 'DURING'
   		   WHEN DATETIME_DIFF(bg.charttime, c.time, 'HOUR') >=24 THEN 'AFTER' END) END AS hour48

-- whether value is before or after 96hour cisatracurium administration. 
-- for unexposed, use median duration of 17hours
, CASE WHEN c.time ISNULL THEN
	(CASE WHEN DATETIME_DIFF(bg.charttime, DATETIME_ADD(i.intime, INTERVAL '17' HOUR), 'HOUR') <0 THEN 'BEFORE'
	 WHEN DATETIME_DIFF(bg.charttime, DATETIME_ADD(i.intime, INTERVAL '17' HOUR), 'HOUR') BETWEEN 0  AND 95.99 THEN 'DURING'
	 WHEN DATETIME_DIFF(bg.charttime, DATETIME_ADD(i.intime, INTERVAL '17' HOUR), 'HOUR') >=96 THEN 'AFTER' END)
	 ELSE (CASE WHEN DATETIME_DIFF(bg.charttime, c.time, 'HOUR') <0 THEN 'BEFORE'
		   WHEN DATETIME_DIFF(bg.charttime, c.time, 'HOUR') BETWEEN 0  AND 95.99 THEN 'DURING'
   		   WHEN DATETIME_DIFF(bg.charttime, c.time, 'HOUR') >=96 THEN 'AFTER' END) END AS hour48



-- spo2 and pao2/fio2
, bg.charttime, bg.spo2, bg.pao2fio2, bg.peep

-- prone position
, p.value AS prone_position

-- use of hfov
, i.hfov


FROM ards_population i 
LEFT JOIN vent_duration vd ON i.icustay_id = vd.icustay_id
LEFT JOIN sapsii sap ON i.icustay_id = sap.icustay_id
LEFT JOIN sofa sof ON i.icustay_id = sof.icustay_id
LEFT JOIN blood_gas_first_day_arterial bg ON i.hadm_id = bg.hadm_id
LEFT JOIN prone p ON i.icustay_id = p.icustay_id
LEFT JOIN cisatracurium_first c ON i.icustay_id = c.icustay_id

ORDER BY i.subject_id, i.admittime, i.intime
;