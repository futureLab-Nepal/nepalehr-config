SELECT IF(cn.name = 'ANC, HIV Counseling', cn.name, 'ANC, HIV Result Received') result, count(distinct person_id)
FROM obs obs
  INNER JOIN concept_name cn ON obs.concept_id = cn.concept_id AND obs.voided = 0 and cn.name in ('ANC, HIV Counseling','ANC, HIV Result Received') and cn.concept_name_type = 'FULLY_SPECIFIED'
  INNER JOIN concept_name trueConcept
    ON obs.value_coded = trueConcept.concept_id AND trueConcept.concept_name_type = 'FULLY_SPECIFIED' and trueConcept.name = 'True'
GROUP BY result
UNION
SELECT 'ANC, HIV Test Result' as result1, count(distinct person_id)
FROM obs obs
  INNER JOIN concept_name cn ON obs.concept_id = cn.concept_id AND obs.voided = 0 and cn.name = 'ANC, HIV Test Result' and cn.concept_name_type = 'FULLY_SPECIFIED'
  INNER JOIN concept_name trueConcept
    ON obs.value_coded = trueConcept.concept_id AND trueConcept.concept_name_type = 'FULLY_SPECIFIED' and trueConcept.name ='Positive'
GROUP BY result1
UNION
SELECT 'HTC, Pre-test Counseling' as result2, count(distinct obs.person_id)
FROM obs obs
  INNER JOIN person on person.person_id = obs.person_id
  INNER JOIN obs deliveryMethodObs on deliveryMethodObs.person_id = person.person_id and deliveryMethodObs.voided = 0 and deliveryMethodObs.value_coded is not null
  INNER JOIN concept_name deliveryMethodConcept ON deliveryMethodObs.concept_id = deliveryMethodConcept.concept_id and deliveryMethodConcept.name = 'Delivery Note, Method of Delivery' and deliveryMethodConcept.concept_name_type = 'FULLY_SPECIFIED' 
  INNER JOIN concept_name cn ON obs.concept_id = cn.concept_id AND obs.voided = 0 and cn.name = 'HTC, Pre-test Counseling' and cn.concept_name_type = 'FULLY_SPECIFIED'
  INNER JOIN concept_name trueConcept
    ON obs.value_coded = trueConcept.concept_id AND trueConcept.concept_name_type = 'FULLY_SPECIFIED' and trueConcept.name ='True'
GROUP BY result2
UNION
SELECT 'Labour and Delivery - Tested' as result,count(distinct person.person_id)
FROM obs obs
  INNER JOIN person on person.person_id = obs.person_id and obs.voided = 0
  INNER JOIN obs deliveryMethodObs on deliveryMethodObs.person_id = person.person_id and deliveryMethodObs.voided = 0 and deliveryMethodObs.value_coded is not null
  INNER JOIN concept_name deliveryMethodConcept ON deliveryMethodObs.concept_id = deliveryMethodConcept.concept_id and deliveryMethodConcept.name = 'Delivery Note, Method of Delivery' and deliveryMethodConcept.concept_name_type = 'FULLY_SPECIFIED'
  LEFT JOIN
  (select testedBeforeObs.obs_id 
        from obs testedBeforeObs 
          INNER JOIN concept_name testedBeforeCname ON testedBeforeObs.concept_id = testedBeforeCname.concept_id AND testedBeforeObs.voided = 0 and testedBeforeCname.name = 'HTC, Tested before' and testedBeforeCname.concept_name_type = 'FULLY_SPECIFIED'
          INNER JOIN concept_name testedBeforeYes on testedBeforeObs.value_coded = testedBeforeYes.concept_id and testedBeforeYes.name ='True' and testedBeforeYes.concept_name_type = 'FULLY_SPECIFIED') testedBefore on testedBefore.obs_id = obs.obs_id
  
  LEFT JOIN
  (select htcConfirmatoryObs.obs_id
   from obs htcConfirmatoryObs
     INNER JOIN concept_name htcConfirmatoryCname ON htcConfirmatoryObs.concept_id = htcConfirmatoryCname.concept_id AND htcConfirmatoryObs.voided = 0 and htcConfirmatoryCname.name = 'HTC, Confirmatory' and htcConfirmatoryCname.concept_name_type = 'FULLY_SPECIFIED' and htcConfirmatoryObs.value_coded is not null) htcConfirmatory on htcConfirmatory.obs_id = obs.obs_id
  LEFT JOIN 
  (select htcInitialObs.obs_id
    from obs htcInitialObs
      INNER JOIN concept_name htcInitialCname ON htcInitialObs.concept_id = htcInitialCname.concept_id AND htcInitialObs.voided = 0 and htcInitialCname.name = 'HTC, Initial' and htcInitialCname.concept_name_type = 'FULLY_SPECIFIED' and htcInitialObs.value_coded is not null) htcInitial on htcInitial.obs_id = obs.obs_id
  LEFT JOIN
  (select htcTieBreakerObs.obs_id
   from obs htcTieBreakerObs
     INNER JOIN concept_name htcTieBreakerCname ON htcTieBreakerObs.concept_id = htcTieBreakerCname.concept_id AND htcTieBreakerObs.voided = 0 and htcTieBreakerCname.name = 'HTC, Tie Breaker' and htcTieBreakerCname.concept_name_type = 'FULLY_SPECIFIED' and htcTieBreakerObs.value_coded is not null) htcTieBreaker on htcTieBreaker.obs_id = obs.obs_id
 where testedBefore.obs_id is not null or htcConfirmatory.obs_id is not null or htcInitial.obs_id is not null or htcTieBreaker.obs_id is not null
UNION
SELECT 'Labour and Delivery - Positive' as result,count(distinct person.person_id)
FROM obs obs
  INNER JOIN person on person.person_id = obs.person_id and obs.voided = 0
  INNER JOIN obs deliveryMethodObs on deliveryMethodObs.person_id = person.person_id and deliveryMethodObs.voided = 0 and deliveryMethodObs.value_coded is not null
  INNER JOIN concept_name deliveryMethodConcept ON deliveryMethodObs.concept_id = deliveryMethodConcept.concept_id and deliveryMethodConcept.name = 'Delivery Note, Method of Delivery' and deliveryMethodConcept.concept_name_type = 'FULLY_SPECIFIED'
  LEFT JOIN
  (select resultIfTestedObs.obs_id
   from obs resultIfTestedObs
     INNER JOIN concept_name resultIfTestedCname ON resultIfTestedObs.concept_id = resultIfTestedCname.concept_id AND resultIfTestedObs.voided = 0 and resultIfTestedCname.name = 'HTC, Result if tested' and resultIfTestedCname.concept_name_type = 'FULLY_SPECIFIED'
     INNER JOIN concept_name resultIfTestedPositive on resultIfTestedObs.value_coded = resultIfTestedPositive.concept_id and resultIfTestedPositive.name ='Positive' and resultIfTestedPositive.concept_name_type = 'FULLY_SPECIFIED') resultIfTested on resultIfTested.obs_id = obs.obs_id

  LEFT JOIN
  (select htcConfirmatoryObs.obs_id
   from obs htcConfirmatoryObs
     INNER JOIN concept_name htcConfirmatoryCname ON htcConfirmatoryObs.concept_id = htcConfirmatoryCname.concept_id AND htcConfirmatoryObs.voided = 0 and htcConfirmatoryCname.name = 'HTC, Confirmatory' and htcConfirmatoryCname.concept_name_type = 'FULLY_SPECIFIED'
     INNER JOIN concept_name htcConfirmatoryPositive on htcConfirmatoryObs.value_coded = htcConfirmatoryPositive.concept_id and htcConfirmatoryPositive.name ='Positive' and htcConfirmatoryPositive.concept_name_type = 'FULLY_SPECIFIED') htcConfirmatory on htcConfirmatory.obs_id = obs.obs_id
  LEFT JOIN
  (select htcInitialObs.obs_id
   from obs htcInitialObs
     INNER JOIN concept_name htcInitialCname ON htcInitialObs.concept_id = htcInitialCname.concept_id AND htcInitialObs.voided = 0 and htcInitialCname.name = 'HTC, Initial' and htcInitialCname.concept_name_type = 'FULLY_SPECIFIED'
     INNER JOIN concept_name htcInitialPositive on htcInitialObs.value_coded = htcInitialPositive.concept_id and htcInitialPositive.name ='Positive' and htcInitialPositive.concept_name_type = 'FULLY_SPECIFIED') htcInitial on htcInitial.obs_id = obs.obs_id
  LEFT JOIN
  (select htcTieBreakerObs.obs_id
   from obs htcTieBreakerObs
     INNER JOIN concept_name htcTieBreakerCname ON htcTieBreakerObs.concept_id = htcTieBreakerCname.concept_id AND htcTieBreakerObs.voided = 0 and htcTieBreakerCname.name = 'HTC, Tie Breaker' and htcTieBreakerCname.concept_name_type = 'FULLY_SPECIFIED'
     INNER JOIN concept_name htcTieBreakerPositive on htcTieBreakerObs.value_coded = htcTieBreakerPositive.concept_id and htcTieBreakerPositive.name ='Positive' and htcTieBreakerPositive.concept_name_type = 'FULLY_SPECIFIED') htcTieBreaker on htcTieBreaker.obs_id = obs.obs_id
where (resultIfTested.obs_id is not null) or (htcConfirmatory.obs_id is not null and htcInitial.obs_id is not null) or (htcTieBreaker.obs_id is not null)
UNION
SELECT 'Puerperium - Counseled' as result,count(distinct person.person_id)
FROM obs obs
  INNER JOIN person on person.person_id = obs.person_id and obs.voided = 0
  INNER JOIN obs deliveryMethodObs on deliveryMethodObs.person_id = person.person_id and deliveryMethodObs.voided = 0 and deliveryMethodObs.value_coded is not null
  INNER JOIN concept_name deliveryMethodConcept ON deliveryMethodObs.concept_id = deliveryMethodConcept.concept_id and deliveryMethodConcept.name = 'Delivery Note, Method of Delivery' and deliveryMethodConcept.concept_name_type = 'FULLY_SPECIFIED'
  LEFT JOIN
  (select pncVisitTimeObs.obs_id
   from obs pncVisitTimeObs
     INNER JOIN concept_name pncVisitTimeCname ON pncVisitTimeObs.concept_id = pncVisitTimeCname.concept_id AND pncVisitTimeObs.voided = 0 and pncVisitTimeCname.name = 'PNC, Visit Time' and pncVisitTimeCname.concept_name_type = 'FULLY_SPECIFIED' and pncVisitTimeObs.value_coded is not null) pncVisitTime on pncVisitTime.obs_id = obs.obs_id
  LEFT JOIN
  (select htcPretestCouncellingObs.obs_id
   from obs htcPretestCouncellingObs
     INNER JOIN concept_name htcPretestCouncellingCname ON htcPretestCouncellingObs.concept_id = htcPretestCouncellingCname.concept_id AND htcPretestCouncellingObs.voided = 0 and htcPretestCouncellingCname.name = 'HTC, Pre-test Counseling' and htcPretestCouncellingCname.concept_name_type = 'FULLY_SPECIFIED'
     INNER JOIN concept_name htcPretestCouncellingPositive on htcPretestCouncellingObs.value_coded = htcPretestCouncellingPositive.concept_id and htcPretestCouncellingPositive.name ='Positive' and htcPretestCouncellingPositive.concept_name_type = 'FULLY_SPECIFIED') htcPretestCouncelling on htcPretestCouncelling.obs_id = obs.obs_id
where (pncVisitTime.obs_id is not null) or (htcPretestCouncelling.obs_id is not null)
UNION
SELECT 'Puerperium - Tested' as result, count(distinct person.person_id)
FROM person person
  INNER JOIN obs obs on person.person_id = obs.person_id and obs.voided = 0
  INNER JOIN obs deliveryMethodObs on deliveryMethodObs.person_id = person.person_id and deliveryMethodObs.voided = 0 and deliveryMethodObs.value_coded is not null
  INNER JOIN concept_name deliveryMethodConcept ON deliveryMethodObs.concept_id = deliveryMethodConcept.concept_id and deliveryMethodConcept.name = 'Delivery Note, Method of Delivery' and deliveryMethodConcept.concept_name_type = 'FULLY_SPECIFIED'
  LEFT JOIN 
  (select pncVisitTimeObs.person_id, pncVisitTimeObs.obs_id
    from obs pncVisitTimeObs
    INNER JOIN concept_name pncVisitTimeCname ON pncVisitTimeObs.concept_id = pncVisitTimeCname.concept_id AND pncVisitTimeObs.voided = 0 and pncVisitTimeCname.name = 'PNC, Visit Time' and pncVisitTimeCname.concept_name_type = 'FULLY_SPECIFIED' and pncVisitTimeObs.value_coded is not null) pncVisitTime on pncVisitTime.person_id = obs.person_id
  LEFT JOIN
  (select testedBeforeObs.person_id,testedBeforeObs.obs_id
   from obs testedBeforeObs
     INNER JOIN concept_name testedBeforeCname ON testedBeforeObs.concept_id = testedBeforeCname.concept_id AND testedBeforeObs.voided = 0 and testedBeforeCname.name = 'HTC, Tested before' and testedBeforeCname.concept_name_type = 'FULLY_SPECIFIED'
     INNER JOIN concept_name testedBeforeYes on testedBeforeObs.value_coded = testedBeforeYes.concept_id and testedBeforeYes.name ='True' and testedBeforeYes.concept_name_type = 'FULLY_SPECIFIED') testedBefore on testedBefore.person_id = obs.person_id
  LEFT JOIN
  (select htcConfirmatoryObs.person_id,htcConfirmatoryObs.obs_id
   from obs htcConfirmatoryObs
     INNER JOIN concept_name htcConfirmatoryCname ON htcConfirmatoryObs.concept_id = htcConfirmatoryCname.concept_id AND htcConfirmatoryObs.voided = 0 and htcConfirmatoryCname.name = 'HTC, Confirmatory' and htcConfirmatoryCname.concept_name_type = 'FULLY_SPECIFIED' and htcConfirmatoryObs.value_coded is not null) htcConfirmatory on htcConfirmatory.person_id = obs.person_id
  LEFT JOIN
  (select htcInitialObs.person_id,htcInitialObs.obs_id
   from obs htcInitialObs
     INNER JOIN concept_name htcInitialCname ON htcInitialObs.concept_id = htcInitialCname.concept_id AND htcInitialObs.voided = 0 and htcInitialCname.name = 'HTC, Initial' and htcInitialCname.concept_name_type = 'FULLY_SPECIFIED' and htcInitialObs.value_coded is not null) htcInitial on htcInitial.person_id = obs.person_id
  LEFT JOIN
  (select htcTieBreakerObs.person_id,htcTieBreakerObs.obs_id
   from obs htcTieBreakerObs
     INNER JOIN concept_name htcTieBreakerCname ON htcTieBreakerObs.concept_id = htcTieBreakerCname.concept_id AND htcTieBreakerObs.voided = 0 and htcTieBreakerCname.name = 'HTC, Tie Breaker' and htcTieBreakerCname.concept_name_type = 'FULLY_SPECIFIED' and htcTieBreakerObs.value_coded is not null) htcTieBreaker on htcTieBreaker.person_id = obs.person_id
where (pncVisitTime.obs_id is not null) and (testedBefore.obs_id is not null or htcConfirmatory.obs_id is not null or htcInitial.obs_id is not null or htcTieBreaker.obs_id is not null)
