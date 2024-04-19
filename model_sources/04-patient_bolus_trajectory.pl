% ----------------------------------------------------------------------------------------------------------------------
% patient requested bolus       ----------------------------------------------------------------------------------------
% X5.2.0(1), R5.2.0(2)

    % patient bolus delivery trajectories
    fluent(patient_bolus_delivery_enabled).
    or_initiates(patient_bolus_delivery_started, patient_bolus_delivery_enabled, T).
    or_terminates(patient_bolus_delivery_stopped, patient_bolus_delivery_enabled, T).

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


% ----------------------------------------------------------------------------------------------------------------------
% starting the trajectory
% X5.2.0(1) -- starting or denying a patient requested bolus

    % if requested, will not exceed limit, and is not too soon; then start bolus 
    or_happens(patient_bolus_delivery_started, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(patient_bolus_requested_valid, T),
        not_happens(patient_bolus_denied_too_soon, T),
        not__happens(patient_bolus_denied_max_dose, T). %! TODO needed instead of not_happens when using abduction (bc findall look in all worlds)

    % helper event, two reasons for denying a patient bolus
    or_happens(patient_bolus_denied, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(patient_bolus_denied_too_soon, T).
    or_happens(patient_bolus_denied, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(patient_bolus_denied_max_dose, T).

    % R5.2.0(3) -- if its too soon since last bolus; then deny bolus
    or_happens(patient_bolus_denied_too_soon, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(patient_bolus_requested_valid, T),
        initiallyP(min_t_between_patient_bolus(MinTimeBetween)),
        TLastBolus .>. 0,
        TLastBolus .<. T,
        TLastBolus .>. T - MinTimeBetween,
        holdsAt(patient_bolus_delivery_enabled, TLastBolus).

    % R5.2.0(5) -- if hard limit would be exceeded; then deny bolus, and issue a warning, and switch to KVO
    or_happens(patient_bolus_denied_max_dose, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(patient_bolus_requested_valid, T),
        initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
        shortcut_total_drug_in_max_dose_window_if_the_patient_bolus_would_be_delivered_starting_at_T(T, VtbiLimitTimePeriod, TotalDuringVtbiPeriodWithCurrentBolus),
        % trigger this rule if the VTBI limit was exceeded
        TotalDuringVtbiPeriodWithCurrentBolus .>. VtbiLimit.
    or_not__happens(patient_bolus_denied_max_dose, T) :- happens(patient_bolus_requested_valid, T),
        initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
        shortcut_total_drug_in_max_dose_window_if_the_patient_bolus_would_be_delivered_starting_at_T(T, VtbiLimitTimePeriod, TotalDuringVtbiPeriodWithCurrentBolus),
        % trigger this rule if the VTBI limit was NOT exceeded
        TotalDuringVtbiPeriodWithCurrentBolus .=<. VtbiLimit.

    % in a separate file 06-max_dose-*
    % or_happens(max_dose_warning, T) :- 


% ----------------------------------------------------------------------------------------------------------------------
% events on start of trajectory

    % stop basal on bolus start
    or_happens(basal_delivery_stopped, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(patient_bolus_delivery_started, T),
        holdsAt(basal_delivery_enabled, T).


% ----------------------------------------------------------------------------------------------------------------------
% ending the trajectory

%! self-ending trajectory
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
    

    % trigger self-terminating event when VTBI is delivered -- using a dedicated fluent combined with holdsAt/3
    or_happens(patient_bolus_completed, T2) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        initiallyP(vtbi(VTBI)),
        holdsAt(patient_bolus_drug_delivered(VTBI), T2, patient_bolus_delivery_enabled).
       
    or_happens(patient_bolus_delivery_stopped, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(patient_bolus_completed, T).


% premature halt of the trajectory
    or_happens(patient_bolus_delivery_stopped, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(patient_bolus_halted, T).

    % R5.2.0(6) -- any alarm stops the bolus
    or_happens(patient_bolus_halted, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(any_alarm, T), holdsAt(patient_bolus_delivery_enabled, T).

    % R6.5.0(6) -- stop button stops everything
    or_happens(patient_bolus_halted, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(stop_button_pressed_valid, T),
        holdsAt(patient_bolus_delivery_enabled, T).

    % more in drug reservoir reasoning
    % ...


% ----------------------------------------------------------------------------------------------------------------------
% events on end of trajectory

    % restart basal on bolus complete (unless a clinician bolus is suspended)
    or_happens(basal_delivery_started, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(patient_bolus_completed, T),
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
% helper predicates

% TODO should be automated preprocessing
    can_trajectory(patient_bolus_delivery_enabled, T1, total_drug_delivered(TotalDelivered), T2) . %:- /*tr*/ incremental_start_time(INCREMENT_T), T1 .>=. INCREMENT_T, T2 .>=. INCREMENT_T.
    can_trajectory(patient_bolus_delivery_enabled, T1, total_bolus_drug_delivered(TotalBolusDelivered), T2) . %:- /*tr*/ incremental_start_time(INCREMENT_T), T1 .>=. INCREMENT_T, T2 .>=. INCREMENT_T.
    can_trajectory(patient_bolus_delivery_enabled, T1, patient_bolus_drug_delivered(VtbiDrugRes), T2) . %:- /*tr*/ incremental_start_time(INCREMENT_T), T1 .>=. INCREMENT_T, T2 .>=. INCREMENT_T.