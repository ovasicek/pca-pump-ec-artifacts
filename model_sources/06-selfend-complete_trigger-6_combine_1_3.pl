% instance of a the new selfend axiom combined with the dedicated fluent -- loop free
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
    trajectory(patient_bolus_delivery_enabled, T1, patient_bolus_drug_delivered(VTBI), T2).


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
    trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, clinician_bolus_drug_delivered(VTBI), T2).
