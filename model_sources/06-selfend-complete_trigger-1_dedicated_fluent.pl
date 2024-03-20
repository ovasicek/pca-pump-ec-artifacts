% Dedicated fluent approach -- loop free
or_happens(patient_bolus_completed, T2) :-
    initiallyP(vtbi(VTBI)),
    holdsAt(patient_bolus_drug_delivered(VTBI), T2).


or_happens(clinician_bolus_completed, T2) :-
    initiallyP(vtbi(VTBI)),
    holdsAt(clinician_bolus_drug_delivered(VTBI), T2).
