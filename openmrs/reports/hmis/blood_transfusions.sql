-- Blood transfusion  - NUMBER
SELECT 'Patients Blood Transfusions' as "String", CONCAT(CAST(COUNT(DISTINCT(person_id)) AS CHAR), ' Patients  -- ', CAST(SUM(Count)/1000 AS CHAR), ' Litres') AS Result
FROM
(SELECT obs1.person_id, con1.name AS Provided, con2.name AS Quantity, obs2.value_numeric AS Count 
	FROM obs obs1 
	INNER JOIN obs obs2 on obs1.encounter_id = obs2.encounter_id 
    INNER JOIN concept_name con2 on obs2.concept_id = con2.concept_id and 
		con2.name IN ('ANC, Blood Transfusion Quantity','Delivery Note, Blood transfusion quantity','PNC, Blood Transfusion Quantity') and con2.concept_name_type = 'FULLY_SPECIFIED'
	INNER JOIN concept_name con1 on obs1.concept_id = con1.concept_id and 
		con1.name IN ('ANC, Blood Transfusion Provided','Delivery Note, Blood transfusion provided','PNC, Blood Transfusion Provided') and con1.concept_name_type = 'FULLY_SPECIFIED'
    WHERE (cast(obs1.obs_datetime as date) BETWEEN "#startDate#" AND "#endDate#") AND (cast(obs2.obs_datetime as date) BETWEEN "#startDate#" AND "#endDate#")) AS result_view;