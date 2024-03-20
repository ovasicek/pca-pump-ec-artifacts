% instance of a the new selfend axiom with a dedicated fluent -- loop free
or_happens(clinician_bolus_halted_max_dose, T2) :-
    T1 .>. 0, T1 .<. T2,                                                
    max_time(T3), T2 .<. T3,                                            
    can_selfend_trajectory(Fluent1, T1, clinician_bolus_halted_max_dose, T2),                  
    can_initiates(Event, Fluent1),                                      
    happens(Event, T1),                                                 
    initiates(Event, Fluent1, T1),
    selfend_trajectory(Fluent1, T1, clinician_bolus_halted_max_dose, T2),
    not_stoppedIn(T1, Fluent1, T2).
can_selfend_trajectory(clinician_bolus_halted_max_dose).
can_selfend_trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, clinician_bolus_halted_max_dose, T2).
or_selfend_trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, clinician_bolus_halted_max_dose, T2) :-
    %//initiallyP(vtbi(VTBI)),
    %//trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, clinician_bolus_drug_delivered(VTBI), TEnd), % upper limit for T2  %//NO_PREPROCESS
    %//T2 .<. TEnd,
    %//initiallyP(vtbi_hard_limit_over_time(_, VtbiLimitTimePeriod)),
    %//T2 .=<. T1 + VtbiLimitTimePeriod,
    % rest is in the rule below to be configurable for fixed and original version of the model
    shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__6_combine_1_3(T1, DurationMinutes, T2).