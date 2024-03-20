% ----------------------------------------------------------------------------------------------------------------------
% kvo delivery                  ----------------------------------------------------------------------------------------
% R5.1.0(5), R5.2.0(6), R5.3.0(4), R5.3.0(7)

    % kvo delivery trajectories
    fluent(kvo_delivery_enabled).
    or_trajectory(kvo_delivery_enabled, T1, total_drug_delivered(TotalDelivered), T2) :-
        initiallyP(kvo_flow_rate(FlowRate)),
        holdsAt(total_drug_delivered(StartTotal), T1),
        TotalDelivered .=. StartTotal + ((T2-T1) * FlowRate).

    or_trajectory(kvo_delivery_enabled, T1, total_bolus_drug_delivered(TotalBolusDelivered), T2) :-
        holdsAt(total_bolus_drug_delivered(TotalBolusDelivered), T1). % constant

    % starting kvo delivery
    or_initiates(kvo_delivery_started, kvo_delivery_enabled, T).

    % stopping kvo delivery
    or_terminates(kvo_delivery_stopped, kvo_delivery_enabled, T).


% ----------------------------------------------------------------------------------------------------------------------
% events on start of trajectory

    % n/a


% ----------------------------------------------------------------------------------------------------------------------
% events on end of trajectory

    % n/a


% ----------------------------------------------------------------------------------------------------------------------
% helper predicates % TODO should be automated preprocessing
    can_trajectory(kvo_delivery_enabled, T1, total_drug_delivered(TotalDelivered), T2).
    can_trajectory(kvo_delivery_enabled, T1, total_bolus_drug_delivered(TotalBolusDelivered), T2).
