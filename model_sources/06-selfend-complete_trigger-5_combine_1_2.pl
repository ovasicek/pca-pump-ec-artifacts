% combination of both the dedicated fluent and the manual trajectory into the future -- loop free
or_happens(patient_bolus_completed, T2) :-
    initiallyP(vtbi(VTBI)),
    % approach 2 -- pairing with a start event and using a trajectory definition to look into the future
    T1 .<. T2,
    happens(patient_bolus_delivery_started, T1),
    not_happensIn(patient_bolus_delivery_started, T1, T2),
    trajectory(patient_bolus_delivery_enabled, T1, patient_bolus_drug_delivered(VTBI), T2),  %//NO_PREPROCESS
    % approach 1 -- using a dedicated fluent
    holdsAt(patient_bolus_drug_delivered(VTBI), T2).


or_happens(clinician_bolus_completed, T2) :-
    initiallyP(vtbi(VTBI)),
    % approach 2 -- pairing with a start event and using a trajectory definition to look into the future
    T1 .<. T2,
    happens(clinician_bolus_delivery_started(DurationMinutes), T1),
    not_happensIn(clinician_bolus_delivery_started, T1, T2),
    trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, clinician_bolus_drug_delivered(VTBI), T2),  %//NO_PREPROCESS
    % approach 1 -- using a dedicated fluent
    holdsAt(clinician_bolus_drug_delivered(VTBI), T2).
