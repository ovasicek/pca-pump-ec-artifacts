% ----------------------------------------------------------------------------------------------------------------------
% state of the pump             ----------------------------------------------------------------------------------------

    or_initiates(pump_started, pump_running, T).
    or_terminates(pump_stopped, pump_running, T).

    or_terminates(pump_started, pump_not_running, T).
    or_initiates(pump_stopped, pump_not_running, T).

    % start button starts the pump
    or_happens(pump_started, T) :- happens(start_button_pressed_valid, T).

    % stop button stops the pump R6.2.0(2)
    or_happens(pump_stopped, T) :- happens(stop_button_pressed_valid, T),
        holdsAt(pump_running, T).


% constant trajectories for pump_not_running
    or_trajectory(pump_not_running, 0, total_drug_delivered(TotalDelivered), T2) :-
        initiallyP(initial_total_drug_delivered(TotalDelivered)).  % constant
    or_trajectory(pump_not_running, T1, total_drug_delivered(TotalDelivered), T2) :-
        T1 .>. 0,
        holdsAt(total_drug_delivered(TotalDelivered), T1).  % constant

    or_trajectory(pump_not_running, 0, total_bolus_drug_delivered(TotalBolusDelivered), T2) :-
        initiallyP(initial_total_bolus_drug_delivered(TotalBolusDelivered)).
    or_trajectory(pump_not_running, T1, total_bolus_drug_delivered(TotalBolusDelivered), T2) :-
        T1 .>. 0,
        holdsAt(total_bolus_drug_delivered(TotalBolusDelivered), T1).  % constant


% R6.1.0(1) -- measure drug flow
    % R5.1.0(1) -- during basal
    or_holdsAt(drug_flow_rate(Rate), T) :- holdsAt(basal_delivery_enabled, T), initiallyP(basal_flow_rate(Rate)).
    % R5.2.0(2) -- during patient bolus
    or_holdsAt(drug_flow_rate(Rate), T) :- holdsAt(patient_bolus_delivery_enabled, T), shortcut_patient_bolus_total_flow_rate(Rate).
    % R5.3.0(2) -- during clinician bolus
    or_holdsAt(drug_flow_rate(Rate), T) :- holdsAt(clinician_bolus_delivery_enabled(DurationMinutes), T), shortcut_clinician_bolus_total_flow_rate(DurationMinutes, Rate).
    % R5.1.0(5) -- during kvo
    or_holdsAt(drug_flow_rate(Rate), T) :- holdsAt(kvo_delivery_enabled, T), initiallyP(kvo_flow_rate(Rate)).

    % while the pump is not running
    or_holdsAt(drug_flow_rate(Rate), T) :- holdsAt(pump_not_running, T), initiallyP(initial_drug_flow_rate(Rate)).


% ----------------------------------------------------------------------------------------------------------------------
% helper predicates

% TODO should be automated preprocessing
    can_trajectory(pump_not_running, T1, total_drug_delivered(X), T2).
    can_trajectory(pump_not_running, T1, total_bolus_drug_delivered(X), T2).
