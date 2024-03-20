% ----------------------------------------------------------------------------------------------------------------------
% patient requested bolus       ----------------------------------------------------------------------------------------
% X5.2.0(1), R5.2.0(2)

    % patient bolus delivery trajectories
    fluent(patient_bolus_delivery_enabled).
    or_trajectory(patient_bolus_delivery_enabled, T1, total_drug_delivered(TotalDelivered), T2) :- % determining the total amount of drug delivered so far throughout the whole narrative
        shortcut_patient_bolus_duration(CroppedDuration),
        T2 .=<. T1 + CroppedDuration,
        shortcut_patient_bolus_total_flow_rate(FlowRate),
        holdsAt(total_drug_delivered(StartTotal), T1),
        TotalDelivered .=. StartTotal + ((T2-T1) * FlowRate).

    or_trajectory(patient_bolus_delivery_enabled, T1, total_bolus_drug_delivered(TotalBolusDelivered), T2) :- % determining the volume of "bolus only" delivered so far during the entire narrative (bolus only, no basal)
        shortcut_patient_bolus_duration(CroppedDuration),
        T2 .=<. T1 + CroppedDuration,
        shortcut_patient_bolus_flow_rate(FlowRate),
        holdsAt(total_bolus_drug_delivered(StartTotal), T1),
        TotalBolusDelivered .=. StartTotal + ((T2-T1) * FlowRate).
        %//initiallyP(vtbi(VTBI)),
        %//TotalBolusDelivered .=<. StartTotal + VTBI.

    % starting patient requested bolus delivery
    or_initiates(patient_bolus_delivery_started, patient_bolus_delivery_enabled, T).

    % ending patient requested bolus delivery
    or_terminates(patient_bolus_delivery_stopped, patient_bolus_delivery_enabled, T).


% ----------------------------------------------------------------------------------------------------------------------
% self-ending trajectory
% patient requested bolus delivery ends automatically after delivering the specified ammount of the drug (vtbi(X))

    % dedicated fluent for tracking trajectory progress
    fluent(patient_bolus_drug_delivered(X)).
    initiallyR(patient_bolus_drug_delivered(X)).

    or_trajectory(patient_bolus_delivery_enabled, T1, patient_bolus_drug_delivered(VtbiDrugRes), T2) :- % determining the volume of "bolus only" delivered so far during the current patient bolus (bolus only, no basal)
        shortcut_patient_bolus_duration(CroppedDuration),
        T2 .=<. T1 + CroppedDuration,
        shortcut_patient_bolus_flow_rate(FlowRate),
        VtbiDrugRes .=. ((T2-T1) * FlowRate).
        %//initiallyP(vtbi(VTBI)),
        %//VtbiDrugRes .=<. VTBI.
    

    % trigger self-terminating event when VTBI is delivered
    % TODO multiple versions in separate files 06-selfend-complete_trigger-*
    % or_happens(patient_bolus_completed, T2) :- ...
       
    or_happens(patient_bolus_delivery_stopped, T) :- happens(patient_bolus_completed, T).


% ----------------------------------------------------------------------------------------------------------------------
% premature halt of the trajectory

    % helper event, two types of premature halt
    or_happens(patient_bolus_halted, T) :- happens(patient_bolus_halted_alarm, T).
    or_happens(patient_bolus_halted, T) :- happens(patient_bolus_halted_stop_button, T).

    % stops the trajectory
    or_happens(patient_bolus_delivery_stopped, T) :- happens(patient_bolus_halted, T).


% ----------------------------------------------------------------------------------------------------------------------
% events on start of trajectory

    % stop basal on bolus start
    or_happens(basal_delivery_stopped, T) :- happens(patient_bolus_delivery_started, T),
        holdsAt(basal_delivery_enabled, T).


% ----------------------------------------------------------------------------------------------------------------------
% events on end of trajectory

    % restart basal on bolus complete (unless a clinician bolus is suspended)
    or_happens(basal_delivery_started, T) :- happens(patient_bolus_completed, T),
        not_holdsAt(clinician_bolus_is_suspended, T).


% ----------------------------------------------------------------------------------------------------------------------
% to avoid copy pasting these bits of code into multiple places
    shortcut_patient_bolus_total_flow_rate(CroppedTotalFlowRate) :-          % bolus flow rate combined with basal flow rate, potentially cropped due to max pump flow
        initiallyP(patient_bolus_flow_rate(BolusRate)),
        initiallyP(basal_flow_rate(BasalRate)),
        CombinedRate .=. BolusRate + BasalRate,             % R5.2.0(2)
        initiallyP(pump_flow_rate_max(MaxRate)),
        min(CombinedRate, MaxRate, CroppedTotalFlowRate).   % R5.2.0(2)
    shortcut_patient_bolus_flow_rate(CroppedBolusFlowRate) :-                % bolus flow rate only (no basal), potentially cropped due to max pump flow
        shortcut_patient_bolus_total_flow_rate(CroppedTotalFlowRate),
        initiallyP(basal_flow_rate(BasalRate)),
        CroppedBolusFlowRate .=. CroppedTotalFlowRate - BasalRate.
    shortcut_patient_bolus_duration(CroppedDuration) :-                      % bolus duration, also can be cropped due to max pump flow
        shortcut_patient_bolus_flow_rate(CroppedBolusFlowRate),
        initiallyP(vtbi(VTBI)),
        CroppedDuration .=. VTBI / CroppedBolusFlowRate.


% ----------------------------------------------------------------------------------------------------------------------
% helper predicates % TODO should be automated preprocessing
    can_trajectory(patient_bolus_delivery_enabled, T1, total_drug_delivered(TotalDelivered), T2).
    can_trajectory(patient_bolus_delivery_enabled, T1, total_bolus_drug_delivered(TotalBolusDelivered), T2).
    can_trajectory(patient_bolus_delivery_enabled, T1, patient_bolus_drug_delivered(VtbiDrugRes), T2).