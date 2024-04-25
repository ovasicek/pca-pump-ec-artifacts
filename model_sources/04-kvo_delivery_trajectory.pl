% ----------------------------------------------------------------------------------------------------------------------
% kvo delivery                  ----------------------------------------------------------------------------------------
% R5.1.0(5), R5.2.0(6), R5.3.0(4), R5.3.0(7)

    % kvo delivery trajectories
    fluent(kvo_delivery_enabled).
    or_initiates(kvo_delivery_started, kvo_delivery_enabled, T).
    or_terminates(kvo_delivery_stopped, kvo_delivery_enabled, T).

    or_trajectory(kvo_delivery_enabled, T1, total_drug_delivered(TotalDelivered), T2) :-
        initiallyP(kvo_flow_rate(FlowRate)),
        holdsAt(total_drug_delivered(StartTotal), T1),
        TotalDelivered .=. StartTotal + ((T2-T1) * FlowRate).

    or_trajectory(kvo_delivery_enabled, T1, total_bolus_drug_delivered(TotalBolusDelivered), T2) :-
        holdsAt(total_bolus_drug_delivered(TotalBolusDelivered), T1). % constant


% ----------------------------------------------------------------------------------------------------------------------
% starting the trajectory

    % more in drug reservoir reasoning
    % ...


% ----------------------------------------------------------------------------------------------------------------------
% events on start of trajectory

    % n/a


% ----------------------------------------------------------------------------------------------------------------------
% ending the trajectory

    % alarms to off stop the delivery
    or_happens(kvo_delivery_stopped, T) :-
        happens(alarm_to_off, T), holdsAt(kvo_delivery_enabled, T).

    % R6.5.0(6) -- stop button stops everything
    or_happens(kvo_delivery_stopped, T) :-
        happens(stop_button_pressed_valid, T),
        holdsAt(kvo_delivery_enabled, T).

    % more in drug reservoir reasoning
    % ...
        
        
% ----------------------------------------------------------------------------------------------------------------------
% events on end of trajectory

    % n/a

