% ----------------------------------------------------------------------------------------------------------------------
% drug reservoir                ----------------------------------------------------------------------------------------

% NOTE
% - avoiding infinite loops by using the self-ending trajectory approach (similar to triggering bolus completed)
% - unfortunately, reasoning about reservoir warning/alarm was causing a masive slowdown --> decided to make it optional and usable in a two run approach
%   - the two run approach splits the trigger and the effect of the warning/alarm and achieves a huge speedup


% R6.8.0(2) -- measure the amout of drug in drug reservoir
    or_holdsAt(drug_reservoir_contents(DrugLeft), T) :-
        initiallyP(initial_drug_reservoir_contents(StartingDrug)), holdsAt(total_drug_delivered(UsedDrug), T),
        DrugLeft .=. StartingDrug - UsedDrug.

% R6.8.0(10), R7.2.0(7)
    event(empty_reservoir_alarm_EFFECT).
    or_happens(empty_reservoir_alarm_EFFECT, T) :- empty_reservoir_reasoning_enabled, happens(empty_reservoir_alarm, T).

    %or_happens(alarm_to_off, T) :- happens(empty_reservoir_alarm, T). % this is not in the model on purpose -- would cause loops in a single run query

    % empty reservoir at start
    or_happens(empty_reservoir_alarm, T) :- % TODO
        happens(start_button_pressed_valid, T), initiallyP(empty_reservoir_treshold(Threshold)), DrugLeft .=<. Threshold, holdsAt(drug_reservoir_contents(DrugLeft), T).

    %! avoiding infinite loops by using the self-ending trajectory approach (similar to triggering bolus completed)
    % empty reservoir during kvo delivery (there always has to be a switch to KVO due to a low reservoir warning)
    fluent(kvo_drug_reservoir_2(X)).
    initiallyR(kvo_drug_reservoir_2(X)).
    or_trajectory(kvo_delivery_enabled, T1, kvo_drug_reservoir_2(DrugLeft), T2) :- % determining the volume of "bolus only" delivered so far during the current clinician bolus (bolus only, no basal)
        initiallyP(kvo_flow_rate(FlowRate)),
        holdsAt(drug_reservoir_contents(StartDrug), T1),
        DrugLeft .=. StartDrug - ((T2-T1) * FlowRate).

    or_happens(kvo_halted_empty_reservoir, T2) :-
        initiallyP(empty_reservoir_treshold(Threshold)),
        % pairing with the start event to speedup
        T1 .<. T2, %max_time(Tmax), T2 .<. Tmax,
        happens(low_reservoir_warning_EFFECT, T1),
        %//happens(low_reservoir_warning, T1),
        trajectory(kvo_delivery_enabled, T1, kvo_drug_reservoir_2(Threshold), T2),  %//NO_PREPROCESS
        %//% actual trigger
        holdsAt(kvo_drug_reservoir_2(Threshold), T2).
    %// ALTERNATIVES
        %//%    - was causing an infinite loop (empty_reservoir_alarm depends on total_drug_delivered, and empty_reservoir_alarm can stop the delivery of total_drug_delivered --> depends on X but also stops X ==> loop)
        %//%    - should be loop free when using the two run approach
        %//or_happens(empty_reservoir_alarm_TRIGGERED, T) :- initiallyP(empty_reservoir_treshold(Threshold)), holdsAt(drug_reservoir_contents(Threshold), T), holdsAt(pump_running, T).
        %//
        %//% slower
        %//or_happens(kvo_halted_empty_reservoir, T) :- initiallyP(empty_reservoir_treshold(Threshold)), holdsAt(kvo_drug_reservoir_2(Threshold), T).
        %//
        %//% slower
        %//or_happens(kvo_halted_empty_reservoir, T2) :-
        %//    T1 .>. 0, T1 .<. T2,                                                
        %//    max_time(T3), T2 .<. T3,                                            
        %//    can_selfend_trajectory(Fluent1, T1, kvo_halted_empty_reservoir, T2),                  
        %//    can_initiates(Event, Fluent1),                                      
        %//    happens(Event, T1),                                                 
        %//    initiates(Event, Fluent1, T1),
        %//    selfend_trajectory(Fluent1, T1, kvo_halted_empty_reservoir, T2),
        %//    not_stoppedIn(T1, Fluent1, T2).
        %//can_selfend_trajectory(kvo_delivery_enabled, T1, kvo_halted_empty_reservoir, T2).
        %//or_selfend_trajectory(kvo_delivery_enabled, T1, kvo_halted_empty_reservoir, T2) :-
        %//    initiallyP(empty_reservoir_treshold(Threshold)),
        %//    initiallyP(initial_drug_reservoir_contents(StartingDrug)),
        %//    trajectory(kvo_delivery_enabled, T1, total_drug_delivered(UsedDrug), T2),  %//NO_PREPROCESS
        %//    Threshold .=. StartingDrug - UsedDrug.
    %//
    or_happens(empty_reservoir_alarm, T) :- happens(kvo_halted_empty_reservoir, T).
    or_happens(kvo_delivery_stopped, T) :- happens(empty_reservoir_alarm_EFFECT, T).
    or_happens(pump_stopped, T) :- happens(empty_reservoir_alarm_EFFECT, T).


% R6.8.0(9)
    event(low_reservoir_warning_EFFECT).
    event(basal_halted_low_reservoir_EFFECT).
    event(patient_bolus_halted_low_reservoir_EFFECT).
    event(clinician_bolus_halted_low_reservoir_EFFECT).
    event(kvo_low_reservoir_EFFECT).
    or_happens(basal_halted_low_reservoir_EFFECT, T) :- low_reservoir_reasoning_enabled, happens(basal_halted_low_reservoir, T).
    or_happens(patient_bolus_halted_low_reservoir_EFFECT, T) :- low_reservoir_reasoning_enabled, happens(patient_bolus_halted_low_reservoir, T).
    or_happens(clinician_bolus_halted_low_reservoir_EFFECT, T) :- low_reservoir_reasoning_enabled, happens(clinician_bolus_halted_low_reservoir, T).
    or_happens(kvo_low_reservoir_EFFECT, T) :- low_reservoir_reasoning_enabled, happens(kvo_low_reservoir, T).

    %or_happens(alarm_to_kvo, T) :- happens(low_reservoir_warning, T). % this is not in the model on purpose -- would cause loops in a single run query

    % low reservoir at start
    or_happens(low_reservoir_warning, T) :-   % TODO
        happens(start_button_pressed_valid, T), initiallyP(empty_reservoir_treshold(EmptyThreshold)), initiallyP(low_reservoir_treshold(LowThreshold)),
        DrugLeft .=<. LowThreshold, DrugLeft .>. EmptyThreshold, holdsAt(drug_reservoir_contents(DrugLeft), T).  % TODO ".>." to not have low and empty at the same time --> is this correct?


    %! avoiding infinite loops by using the self-ending trajectory approach (similar to triggering bolus completed)
    % low reservoir during basal delivery
    fluent(basal_drug_reservoir(X)).
    initiallyR(basal_drug_reservoir(X)).
    or_trajectory(basal_delivery_enabled, T1, basal_drug_reservoir(DrugLeft), T2) :- % determining the volume of "bolus only" delivered so far during the current clinician bolus (bolus only, no basal)
        initiallyP(basal_flow_rate(FlowRate)),
        holdsAt(drug_reservoir_contents(StartDrug), T1),
        DrugLeft .=. StartDrug - ((T2-T1) * FlowRate).

    or_happens(basal_halted_low_reservoir, T2) :-
        initiallyP(low_reservoir_treshold(Threshold)),
        % pairing with the start event to speedup
        T1 .<. T2, %max_time(Tmax), T2 .<. Tmax,
        happens(basal_delivery_started, T1),
        not_happensIn(basal_delivery_started, T1, T2),
        trajectory(basal_delivery_enabled, T1, basal_drug_reservoir(Threshold), T2),  %//NO_PREPROCESS
        % actual trigger
        holdsAt(basal_drug_reservoir(Threshold), T2).
    %// ALTERNATIVES
        %//%alternative solution -- should be slower for two run approach, and loop for one run approach
        %//or_happens(low_reservoir_warning_TRIGGERED, T) :- initiallyP(low_reservoir_treshold(Threshold)), holdsAt(drug_reservoir_contents(Threshold), T), holdsAt(pump_running, T).
        %//
        %//% slower
        %//or_happens(basal_halted_low_reservoir, T) :- initiallyP(low_reservoir_treshold(Threshold)), holdsAt(basal_drug_reservoir(Threshold), T).
        %//
        %//% slower
        %//or_happens(basal_halted_low_reservoir, T2) :-
        %//    T1 .>. 0, T1 .<. T2,                                                
        %//    max_time(T3), T2 .<. T3,                                            
        %//    can_selfend_trajectory(Fluent1, T1, basal_halted_low_reservoir, T2),                  
        %//    can_initiates(Event, Fluent1),                                      
        %//    happens(Event, T1),                                                 
        %//    initiates(Event, Fluent1, T1),
        %//    selfend_trajectory(Fluent1, T1, basal_halted_low_reservoir, T2),
        %//    not_stoppedIn(T1, Fluent1, T2).
        %//can_selfend_trajectory(basal_delivery_enabled, T1, basal_halted_low_reservoir, T2).
        %//or_selfend_trajectory(basal_delivery_enabled, T1, basal_halted_low_reservoir, T2) :-
        %//    initiallyP(low_reservoir_treshold(Threshold)),
        %//    initiallyP(initial_drug_reservoir_contents(StartingDrug)),
        %//    trajectory(basal_delivery_enabled, T1, total_drug_delivered(UsedDrug), T2),  %//NO_PREPROCESS
        %//    Threshold .=. StartingDrug - UsedDrug.
    %//
    or_happens(low_reservoir_warning, T) :- happens(basal_halted_low_reservoir, T).
    or_happens(low_reservoir_warning_EFFECT, T) :- happens(basal_halted_low_reservoir_EFFECT, T).
    or_happens(basal_delivery_stopped, T) :- happens(basal_halted_low_reservoir_EFFECT, T).
    or_happens(kvo_delivery_started, T) :- happens(basal_halted_low_reservoir_EFFECT, T).
    

    % low reservoir during patient bolus delivery
    fluent(patient_bolus_drug_reservoir(X)).
    initiallyR(patient_bolus_drug_reservoir(X)).
    or_trajectory(patient_bolus_delivery_enabled, T1, patient_bolus_drug_reservoir(DrugLeft), T2) :-
        shortcut_patient_bolus_duration(CroppedDuration),
        T2 .=<. T1 + CroppedDuration,
        shortcut_patient_bolus_total_flow_rate(FlowRate),
        holdsAt(drug_reservoir_contents(StartDrug), T1),
        DrugLeft .=. StartDrug - ((T2-T1) * FlowRate).

    or_happens(patient_bolus_halted_low_reservoir, T2) :-
        initiallyP(low_reservoir_treshold(Threshold)),
        % pairing with the start event to speedup
        T1 .<. T2, %max_time(Tmax), T2 .<. Tmax,
        happens(patient_bolus_delivery_started, T1),
        not_happensIn(patient_bolus_delivery_started, T1, T2),
        trajectory(patient_bolus_delivery_enabled, T1, patient_bolus_drug_reservoir(Threshold), T2),  %//NO_PREPROCESS
        % actual trigger
        holdsAt(patient_bolus_drug_reservoir(Threshold), T2).
    %// ALTERNATIVES
        %//% slower
        %//or_happens(patient_bolus_halted_low_reservoir, T) :- initiallyP(low_reservoir_treshold(Threshold)), holdsAt(patient_bolus_drug_reservoir(Threshold), T).
        %//
        %//% slower
        %//or_happens(patient_bolus_halted_low_reservoir, T2) :-
        %//    T1 .>. 0, T1 .<. T2,                                                
        %//    max_time(T3), T2 .<. T3,                                            
        %//    can_selfend_trajectory(Fluent1, T1, patient_bolus_halted_low_reservoir, T2),                  
        %//    can_initiates(Event, Fluent1),                                      
        %//    happens(Event, T1),                                                 
        %//    initiates(Event, Fluent1, T1),
        %//    selfend_trajectory(Fluent1, T1, patient_bolus_halted_low_reservoir, T2),
        %//    not_stoppedIn(T1, Fluent1, T2).
        %//can_selfend_trajectory(patient_bolus_delivery_enabled, T1, patient_bolus_halted_low_reservoir, T2).
        %//or_selfend_trajectory(patient_bolus_delivery_enabled, T1, patient_bolus_halted_low_reservoir, T2) :-
        %//    initiallyP(low_reservoir_treshold(Threshold)),
        %//    initiallyP(initial_drug_reservoir_contents(StartingDrug)),
        %//    trajectory(patient_bolus_delivery_enabled, T1, total_drug_delivered(UsedDrug), T2),  %//NO_PREPROCESS
        %//    Threshold .=. StartingDrug - UsedDrug.
    %//
    or_happens(low_reservoir_warning, T) :- happens(patient_bolus_halted_low_reservoir, T).
    or_happens(low_reservoir_warning_EFFECT, T) :- happens(patient_bolus_halted_low_reservoir_EFFECT, T).
    or_happens(patient_bolus_delivery_stopped, T) :- happens(patient_bolus_halted_low_reservoir_EFFECT, T).
    or_happens(kvo_delivery_started, T) :- happens(patient_bolus_halted_low_reservoir_EFFECT, T).
    

    % low reservoir during clinician bolus delivery
    fluent(clinician_bolus_drug_reservoir(X)).
    initiallyR(clinician_bolus_drug_reservoir(X)).
    or_trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, clinician_bolus_drug_reservoir(DrugLeft), T2) :-
        shortcut_clinician_bolus_duration(DurationMinutes, CroppedDuration),
        T2 .=<. T1 + CroppedDuration,
        shortcut_clinician_bolus_total_flow_rate(DurationMinutes, FlowRate),
        holdsAt(drug_reservoir_contents(StartDrug), T1),
        DrugLeft .=. StartDrug - ((T2-T1) * FlowRate).
        
    or_happens(clinician_bolus_halted_low_reservoir, T2) :-
        initiallyP(low_reservoir_treshold(Threshold)),
        % pairing with the start event to speedup
        T1 .<. T2, %max_time(Tmax), T2 .<. Tmax,
        happens(clinician_bolus_delivery_started(DurationMinutes), T1),
        not_happensIn(clinician_bolus_delivery_started, T1, T2),
        trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, clinician_bolus_drug_reservoir(Threshold), T2),  %//NO_PREPROCESS
        % actual trigger
        holdsAt(clinician_bolus_drug_reservoir(Threshold), T2).
    %// ALTERNATIVES
        %//% slower
        %//or_happens(clinician_bolus_halted_low_reservoir, T) :- initiallyP(low_reservoir_treshold(Threshold)), holdsAt(clinician_bolus_drug_reservoir(Threshold), T).
        %//
        %//% slower
        %//or_happens(clinician_bolus_halted_low_reservoir, T2) :-
        %//    T1 .>. 0, T1 .<. T2,                                                
        %//    max_time(T3), T2 .<. T3,                                            
        %//    can_selfend_trajectory(Fluent1, T1, clinician_bolus_halted_low_reservoir, T2),                  
        %//    can_initiates(Event, Fluent1),                                      
        %//    happens(Event, T1),                                                 
        %//    initiates(Event, Fluent1, T1),
        %//    selfend_trajectory(Fluent1, T1, clinician_bolus_halted_low_reservoir, T2),
        %//    not_stoppedIn(T1, Fluent1, T2).
        %//can_selfend_trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, clinician_bolus_halted_low_reservoir, T2).
        %//or_selfend_trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, clinician_bolus_halted_low_reservoir, T2) :-
        %//    initiallyP(low_reservoir_treshold(Threshold)),
        %//    initiallyP(initial_drug_reservoir_contents(StartingDrug)),
        %//    trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, total_drug_delivered(UsedDrug), T2),  %//NO_PREPROCESS
        %//    Threshold .=. StartingDrug - UsedDrug.
    %//
    or_happens(low_reservoir_warning, T) :- happens(clinician_bolus_halted_low_reservoir, T).
    or_happens(low_reservoir_warning_EFFECT, T) :- happens(clinician_bolus_halted_low_reservoir_EFFECT, T).
    or_happens(clinician_bolus_delivery_stopped, T) :- happens(clinician_bolus_halted_low_reservoir_EFFECT, T).
    or_happens(kvo_delivery_started, T) :- happens(clinician_bolus_halted_low_reservoir_EFFECT, T).
    

    % low reservoir during kvo delivery
    fluent(kvo_drug_reservoir(X)).
    initiallyR(kvo_drug_reservoir(X)).
    or_trajectory(kvo_delivery_enabled, T1, kvo_drug_reservoir(DrugLeft), T2) :- % determining the volume of "bolus only" delivered so far during the current clinician bolus (bolus only, no basal)
        initiallyP(kvo_flow_rate(FlowRate)),
        holdsAt(drug_reservoir_contents(StartDrug), T1),
        DrugLeft .=. StartDrug - ((T2-T1) * FlowRate).

    or_happens(kvo_low_reservoir, T2) :-
        initiallyP(low_reservoir_treshold(Threshold)),
        % pairing with the start event to speedup
        T1 .<. T2, %max_time(Tmax), T2 .<. Tmax,
        happens(kvo_delivery_started, T1),
        not_happensIn(kvo_delivery_started, T1, T2),
        trajectory(kvo_delivery_enabled, T1, kvo_drug_reservoir(Threshold), T2),  %//NO_PREPROCESS
        % actual trigger
        holdsAt(kvo_drug_reservoir(Threshold), T2).
    %// ALTERNATIVES
        %//% slower
        %//or_happens(kvo_low_reservoir, T) :- initiallyP(low_reservoir_treshold(Threshold)), holdsAt(kvo_drug_reservoir(Threshold), T).
        %//
        %//% slower
        %//or_happens(kvo_low_reservoir, T2) :-
        %//    T1 .>. 0, T1 .<. T2,                                                
        %//    max_time(T3), T2 .<. T3,                                            
        %//    can_selfend_trajectory(Fluent1, T1, kvo_low_reservoir, T2),                  
        %//    can_initiates(Event, Fluent1),                                      
        %//    happens(Event, T1),                                                 
        %//    initiates(Event, Fluent1, T1),
        %//    selfend_trajectory(Fluent1, T1, kvo_low_reservoir, T2),
        %//    not_stoppedIn(T1, Fluent1, T2).
        %//can_selfend_trajectory(kvo_delivery_enabled, T1, kvo_low_reservoir, T2).
        %//or_selfend_trajectory(kvo_delivery_enabled, T1, kvo_low_reservoir, T2) :-
        %//    initiallyP(low_reservoir_treshold(Threshold)),
        %//    initiallyP(initial_drug_reservoir_contents(StartingDrug)),
        %//    trajectory(kvo_delivery_enabled, T1, total_drug_delivered(UsedDrug), T2),  %//NO_PREPROCESS
        %//    Threshold .=. StartingDrug - UsedDrug.
    %//
    or_happens(low_reservoir_warning, T) :- happens(kvo_low_reservoir, T).
    or_happens(low_reservoir_warning_EFFECT, T) :- happens(kvo_low_reservoir_EFFECT, T).


% ----------------------------------------------------------------------------------------------------------------------
% helper predicates % TODO should be automated preprocessing
    can_trajectory(basal_delivery_enabled, T1, basal_drug_reservoir(DrugLeft), T2).
    can_trajectory(patient_bolus_delivery_enabled, T1, patient_bolus_drug_reservoir(TotalBolusDelivered), T2).
    can_trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, clinician_bolus_drug_reservoir(TotalBolusDelivered), T2).
    can_trajectory(kvo_delivery_enabled, T1, kvo_drug_reservoir(DrugLeft), T2).
    can_trajectory(kvo_delivery_enabled, T1, kvo_drug_reservoir_2(DrugLeft), T2).
