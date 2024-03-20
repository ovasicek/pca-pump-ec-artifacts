% uses new predicate+axiom holdsAt/3 and a dedicated fluent -- loop free
or_happens(clinician_bolus_halted_max_dose, T2) :-
    % need to tie to a start event to be able to split trigger into two situations based on T2-T1 compared to max dose time period size
    % TODO maybe remove this and impose a restriction on max bolus length instead (to reduce complexity)
    T1 .<. T2,
    happens(clinician_bolus_delivery_started(DurationMinutes), T1),
    not_happensIn(clinician_bolus_delivery_started, T1, T2),
    %//initiallyP(vtbi(VTBI)),
    %//trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, clinician_bolus_drug_delivered(VTBI), TEnd), % upper limit for T2  %//NO_PREPROCESS
    %//T2 .<. TEnd,
    % rest is in the rule below to be configurable for fixed and original version of the model
    shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__7_combine_1_4(T1, DurationMinutes, T2).
