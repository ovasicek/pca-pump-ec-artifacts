% ----------------------------------------------------------------------------------------------------------------------
% basal delivery                ----------------------------------------------------------------------------------------
% R??? % TODO trace to which requirement?

    % basal delivery trajectories
    fluent(basal_delivery_enabled).
    or_initiates(basal_delivery_started, basal_delivery_enabled, T).
    or_terminates(basal_delivery_stopped, basal_delivery_enabled, T).

    or_trajectory(basal_delivery_enabled, T1, total_drug_delivered(TotalDelivered), T2) :-
        initiallyP(basal_flow_rate(FlowRate)),
        holdsAt(total_drug_delivered(StartTotal), T1),
        TotalDelivered .=. StartTotal + ((T2-T1) * FlowRate).

    or_trajectory(basal_delivery_enabled, T1, total_bolus_drug_delivered(TotalBolusDelivered), T2) :-
        holdsAt(total_bolus_drug_delivered(TotalBolusDelivered), T1).  % constant


% ----------------------------------------------------------------------------------------------------------------------
% starting the trajectory

    % R6.5.0(2), R6.5.0(3), R6.5.0(22) -- start button starts basal flow
    or_happens(basal_delivery_started, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(start_button_pressed_valid, T).
        %not_happens(low_reservoir_warning_FACT, T), not_happens(empty_reservoir_alarm_FACT, T).


% ----------------------------------------------------------------------------------------------------------------------
% events on start of trajectory

    % n/a


% ----------------------------------------------------------------------------------------------------------------------
% ending the trajectory

    % R5.1.0(4) -- any alarm stops delivery
    or_happens(basal_delivery_stopped, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(any_alarm, T), holdsAt(basal_delivery_enabled, T).

    % R6.5.0(6) -- stop button stops everything
    or_happens(basal_delivery_stopped, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(stop_button_pressed_valid, T),
        holdsAt(basal_delivery_enabled, T).

    % stop due to max dose caused by a denied patient bolus request
    or_happens(basal_delivery_stopped, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(patient_bolus_denied_max_dose, T),
        holdsAt(basal_delivery_enabled, T).

    % more in drug reservoir reasoning
    % ...


% ----------------------------------------------------------------------------------------------------------------------
% events on end of trajectory

    % n/a


% ----------------------------------------------------------------------------------------------------------------------
% helper predicates

% TODO should be automated preprocessing
    can_trajectory(basal_delivery_enabled, T1, total_drug_delivered(TotalDelivered), T2) . %:- /*tr*/ incremental_start_time(INCREMENT_T), T1 .>=. INCREMENT_T, T2 .>=. INCREMENT_T.
    can_trajectory(basal_delivery_enabled, T1, total_bolus_drug_delivered(TotalBolusDelivered), T2) . %:- /*tr*/ incremental_start_time(INCREMENT_T), T1 .>=. INCREMENT_T, T2 .>=. INCREMENT_T.
