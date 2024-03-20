% uses new predicate+axiom holdsAt/3 -- loop free
or_happens(patient_bolus_completed, T2) :-
    initiallyP(vtbi(VTBI)),
    holdsAt(patient_bolus_drug_delivered(VTBI), T2, patient_bolus_delivery_enabled).


or_happens(clinician_bolus_completed, T2) :-
    initiallyP(vtbi(VTBI)),
    holdsAt(clinician_bolus_drug_delivered(VTBI), T2, clinician_bolus_delivery_enabled(_)).
