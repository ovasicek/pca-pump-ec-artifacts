% instance of a the new selfend axiom -- loop free
or_happens(patient_bolus_completed, T2) :-
    T1 .>. 0, T1 .<. T2,                                                
    max_time(T3), T2 .<. T3,                                            
    can_selfend_trajectory(Fluent1, T1, patient_bolus_completed, T2),                  
    can_initiates(Event, Fluent1),                                      
    happens(Event, T1),                                                 
    initiates(Event, Fluent1, T1),
    selfend_trajectory(Fluent1, T1, patient_bolus_completed, T2),
    not_stoppedIn(T1, Fluent1, T2).

can_selfend_trajectory(patient_bolus_completed).
can_selfend_trajectory(patient_bolus_delivery_enabled, T1, patient_bolus_completed, T2).  
or_selfend_trajectory(patient_bolus_delivery_enabled, T1, patient_bolus_completed, T2) :-
    initiallyP(vtbi(VTBI)),
    holdsAt(total_bolus_drug_delivered(TotalT1),T1),
    trajectory(patient_bolus_delivery_enabled, T1, total_bolus_drug_delivered(TotalT2), T2),
    VTBI .=. TotalT2 - TotalT1.


or_happens(clinician_bolus_completed, T2) :-
    T1 .>. 0, T1 .<. T2,                                                
    max_time(T3), T2 .<. T3,                                            
    can_selfend_trajectory(Fluent1, T1, clinician_bolus_completed, T2),                  
    can_initiates(Event, Fluent1),                                      
    happens(Event, T1),                                                 
    initiates(Event, Fluent1, T1),
    selfend_trajectory(Fluent1, T1, clinician_bolus_completed, T2),
    not_stoppedIn(T1, Fluent1, T2).

can_selfend_trajectory(clinician_bolus_completed).
can_selfend_trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, clinician_bolus_completed, T2).
or_selfend_trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, clinician_bolus_completed, T2) :-
    initiallyP(vtbi(VTBI)),
    not_holdsAt(clinician_bolus_is_suspended, T1),
    holdsAt(total_bolus_drug_delivered(TotalT1),T1),
    trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, total_bolus_drug_delivered(TotalT2), T2),
    VTBI .=. TotalT2 - TotalT1.
    
or_selfend_trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, clinician_bolus_completed, T2) :-
    initiallyP(vtbi(VTBI)),
    holdsAt(clinician_bolus_suspended_drug_delivered(DeliveredBeforeSuspend), T1),
    holdsAt(total_bolus_drug_delivered(TotalT1),T1),
    trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, total_bolus_drug_delivered(TotalT2), T2),
    VTBI .=. (TotalT2 - TotalT1) + DeliveredBeforeSuspend.
