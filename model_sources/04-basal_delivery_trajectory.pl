% ----------------------------------------------------------------------------------------------------------------------
% basal delivery                ----------------------------------------------------------------------------------------
% R??? % TODO trace to which requirement?

    % basal delivery trajectories
    fluent(basal_delivery_enabled).
    or_trajectory(basal_delivery_enabled, T1, total_drug_delivered(TotalDelivered), T2) :-
        initiallyP(basal_flow_rate(FlowRate)),
        holdsAt(total_drug_delivered(StartTotal), T1),
        TotalDelivered .=. StartTotal + ((T2-T1) * FlowRate).

    or_trajectory(basal_delivery_enabled, T1, total_bolus_drug_delivered(TotalBolusDelivered), T2) :-
        holdsAt(total_bolus_drug_delivered(TotalBolusDelivered), T1).  % constant

    % starting basal delivery
    or_initiates(basal_delivery_started, basal_delivery_enabled, T).

    % stopping basal delivery
    or_terminates(basal_delivery_stopped, basal_delivery_enabled, T).


% ----------------------------------------------------------------------------------------------------------------------
% events on start of trajectory

    % n/a


% ----------------------------------------------------------------------------------------------------------------------
% events on end of trajectory

    % n/a


% ----------------------------------------------------------------------------------------------------------------------
% helper predicates % TODO should be automated preprocessing
    can_trajectory(basal_delivery_enabled, T1, total_drug_delivered(TotalDelivered), T2).
    can_trajectory(basal_delivery_enabled, T1, total_bolus_drug_delivered(TotalBolusDelivered), T2).
