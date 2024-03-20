% Manual trajectory into the future (without the dedicated fluent) -- loop free
or_happens(patient_bolus_completed, T2) :-
    initiallyP(vtbi(VTBI)),
    T1 .<. T2,
    happens(patient_bolus_delivery_started, T1),
    not_happensIn(patient_bolus_delivery_started, T1, T2),
    trajectory(patient_bolus_delivery_enabled, T1, total_bolus_drug_delivered(TotalT2), T2),  %//NO_PREPROCESS
    holdsAt(total_bolus_drug_delivered(TotalT1),T1),
    VTBI .=. TotalT2 - TotalT1,
    holdsAt(total_bolus_drug_delivered(TotalT2),T2).


or_happens(clinician_bolus_completed, T2) :-
    initiallyP(vtbi(VTBI)),
    T1 .<. T2,
    happens(clinician_bolus_delivery_started(DurationMinutes), T1),
    not_happensIn(clinician_bolus_delivery_started, T1, T2),
    not_holdsAt(clinician_bolus_is_suspended, T1),
    trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, total_bolus_drug_delivered(TotalT2), T2),  %//NO_PREPROCESS
    holdsAt(total_bolus_drug_delivered(TotalT1),T1),
    VTBI .=. TotalT2 - TotalT1,
    holdsAt(total_bolus_drug_delivered(TotalT2),T2).

or_happens(clinician_bolus_completed, T2) :-
    initiallyP(vtbi(VTBI)),
    T1 .<. T2,
    happens(clinician_bolus_delivery_started(DurationMinutes), T1),
    not_happensIn(clinician_bolus_delivery_started, T1, T2),
    holdsAt(clinician_bolus_suspended_drug_delivered(DeliveredBeforeSuspend), T1),
    trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, total_bolus_drug_delivered(TotalT2), T2),  %//NO_PREPROCESS
    holdsAt(total_bolus_drug_delivered(TotalT1),T1),
    VTBI .=. (TotalT2 - TotalT1) + DeliveredBeforeSuspend,
    holdsAt(total_bolus_drug_delivered(TotalT2),T2).
