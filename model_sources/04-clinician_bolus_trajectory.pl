% ----------------------------------------------------------------------------------------------------------------------
% clinician requested bolus       --------------------------------------------------------------------------------------
% X5.3.0(1), R5.3.0(5), R6.5.0(7)    

    % clinician bolus delivery trajectories
    fluent(clinician_bolus_delivery_enabled(DurationMinutes)).
        fluent(clinician_bolus_delivery_enabled).   % helper fluent for not_holdsAt queries    
    or_initiates(clinician_bolus_delivery_started(DurationMinutes), clinician_bolus_delivery_enabled(DurationMinutes), T).
    or_initiates(clinician_bolus_delivery_started(DurationMinutes), clinician_bolus_delivery_enabled, T).
    or_terminates(clinician_bolus_delivery_stopped, clinician_bolus_delivery_enabled(_), T).
    or_terminates(clinician_bolus_delivery_stopped, clinician_bolus_delivery_enabled, T).

    or_trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, total_drug_delivered(TotalDelivered), T2) :- % determining the total amount of drug delivered so far throughout the whole narrative
        shortcut_clinician_bolus_duration(DurationMinutes, CroppedDuration),    % TODO what if its after suspend (max duration will be shorter)
        T2 .=<. T1 + CroppedDuration,
        holdsAt(total_drug_delivered(StartTotal), T1),
        shortcut_clinician_bolus_total_flow_rate(DurationMinutes, FlowRate),
        TotalDelivered .=. StartTotal + ((T2-T1) * FlowRate).

    or_trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, total_bolus_drug_delivered(TotalBolusDelivered), T2) :- % determining the volume of "bolus only" delivered so far during the entire narrative (bolus only, no basal)
        shortcut_clinician_bolus_duration(DurationMinutes, CroppedDuration),     % TODO what if its after suspend (max duration will be shorter)
        T2 .=<. T1 + CroppedDuration,
        holdsAt(total_bolus_drug_delivered(StartTotal), T1),
        shortcut_clinician_bolus_flow_rate(DurationMinutes, FlowRate),
        TotalBolusDelivered .=. StartTotal + ((T2-T1) * FlowRate).
        %//initiallyP(vtbi(VTBI)),
        %//TotalBolusDelivered .=<. StartTotal + VTBI.


% ----------------------------------------------------------------------------------------------------------------------
% starting the trajectory
% X5.3.0(1) -- starting a clinician requested bolus

    % if requested, then start bolus with a given duration
    or_happens(clinician_bolus_delivery_started(DurationMinutes), T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(clinician_bolus_requested_valid(DurationMinutes), T).

    % helper event for not_happens
    event(clinician_bolus_delivery_started).
    or_happens(clinician_bolus_delivery_started, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(clinician_bolus_delivery_started(DurationMinutes), T).


% ----------------------------------------------------------------------------------------------------------------------
% events on start of trajectory

    or_happens(basal_delivery_stopped, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(clinician_bolus_delivery_started(DurationMinutes), T),
        holdsAt(basal_delivery_enabled, T).

    % clean clinician_bolus_suspended related fluents after it is resumed
    or_terminates(clinician_bolus_delivery_started(OriginalDuration), clinician_bolus_is_suspended(OriginalDuration), T) :- happens(clinician_bolus_resumed(OriginalDuration), T).
    or_terminates(clinician_bolus_delivery_started(OriginalDuration), clinician_bolus_is_suspended, T) :- happens(clinician_bolus_resumed(OriginalDuration), T).
    or_terminates(clinician_bolus_delivery_started(_), clinician_bolus_suspended_drug_delivered(_), T) :- happens(clinician_bolus_resumed(OriginalDuration), T).


% ----------------------------------------------------------------------------------------------------------------------
% ending the trajectory

%! self-ending trajectory
% clinician requested bolus delivery ends automatically after delivering the specified ammount of the drug (vtbi(X))

    % dedicated fluent for tracking trajectory progress
    fluent(clinician_bolus_drug_delivered(X)).
    initiallyR(clinician_bolus_drug_delivered(X)).

    or_trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, clinician_bolus_drug_delivered(VtbiDrugRes), T2) :- % determining the volume of "bolus only" delivered so far during the current clinician bolus (bolus only, no basal)
        shortcut_clinician_bolus_duration(DurationMinutes, CroppedDuration),
        T2 .=<. T1 + CroppedDuration,
        shortcut_clinician_bolus_flow_rate(DurationMinutes, FlowRate),
        not_holdsAt(clinician_bolus_is_suspended, T1),
        VtbiDrugRes .=. (T2-T1) * FlowRate.
        %//initiallyP(vtbi(VTBI)),
        %//VtbiDrugRes .=<. VTBI.
    or_trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, clinician_bolus_drug_delivered(VtbiDrugRes), T2) :-
        holdsAt(clinician_bolus_suspended_drug_delivered(DeliveredBeforeSuspend), T1),   % R5.3.0(3)
        shortcut_clinician_bolus_duration_after_resume(DeliveredBeforeSuspend, DurationMinutes, CroppedDuration),
        T2 .=<. T1 + CroppedDuration,
        shortcut_clinician_bolus_flow_rate(DurationMinutes, FlowRate),
        VtbiDrugRes .=. ((T2-T1) * FlowRate) + DeliveredBeforeSuspend.
        %//initiallyP(vtbi(VTBI)),
        %//VtbiDrugRes .=<. VTBI.

    % trigger self-terminating event when VTBI is delivered -- using a dedicated fluent combined with holdsAt/3
    or_happens(clinician_bolus_completed, T2) :-
        initiallyP(vtbi(VTBI)),
        holdsAt(clinician_bolus_drug_delivered(VTBI), T2, clinician_bolus_delivery_enabled(_)).
    
    or_happens(clinician_bolus_delivery_stopped, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(clinician_bolus_completed, T).

    fluent(clinician_bolus_total_drug_delivered(X)).
    initiallyR(clinician_bolus_total_drug_delivered(X)).
    can_trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, clinician_bolus_total_drug_delivered(TotalBolusDelivered), T2) . %:- /*tr*/ incremental_start_time(INCREMENT_T), T1 .>=. INCREMENT_T, T2 .>=. INCREMENT_T.
    or_trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, clinician_bolus_total_drug_delivered(TotalBolusDelivered), T2) :-
        trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, total_drug_delivered(TotalBolusDelivered), T2).

    fluent(clinician_bolus_total_bolus_drug_delivered(X)).
    initiallyR(clinician_bolus_total_bolus_drug_delivered(X)).
    can_trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, clinician_bolus_total_bolus_drug_delivered(TotalBolusDelivered), T2) . %:- /*tr*/ incremental_start_time(INCREMENT_T), T1 .>=. INCREMENT_T, T2 .>=. INCREMENT_T.
    or_trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, clinician_bolus_total_bolus_drug_delivered(TotalBolusDelivered), T2) :-
        trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, total_bolus_drug_delivered(TotalBolusDelivered), T2).


% premature halt of the trajectory
    or_happens(clinician_bolus_delivery_stopped, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(clinician_bolus_halted, T).

    % R5.3.0(4) -- any alarm stops the bolus
    or_happens(clinician_bolus_halted, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(any_alarm, T), holdsAt(clinician_bolus_delivery_enabled, T).

    % R6.5.0(6) -- stop button stops everything
    or_happens(clinician_bolus_halted, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(stop_button_pressed_valid, T),
        holdsAt(clinician_bolus_delivery_enabled, T).

    % halt due to max dose caused by a denied patient bolus request
    or_happens(clinician_bolus_halted, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(patient_bolus_denied_max_dose, T), holdsAt(clinician_bolus_delivery_enabled, T).

    % more in drug reservoir reasoning
    % ...

    %! self-ending premature halt
    % R5.3.0(7) -- if the total drug delivered exceeds the maximum vtbi over a period of time; then halt the clinician bolus, and issue a warning, and switch to KVO
    or_happens(clinician_bolus_halted, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(clinician_bolus_halted_max_dose, T).
        
    or_happens(clinician_bolus_halted_max_dose, T2) :-
        % need to tie to a start event to be able to split trigger into two situations based on T2-T1 compared to max dose time period size
        T1 .<. T2,
        happens(clinician_bolus_delivery_started(DurationMinutes), T1),
        not_happensIn(clinician_bolus_delivery_started, T1, T2),
        % rest is in the rule below to be configurable for fixed and original version of the model
        shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus(T1, DurationMinutes, T2).

    % in a separate file 06-max_dose-*
    % or_happens(max_dose_warning, T) :- 


% ----------------------------------------------------------------------------------------------------------------------
% events on end of trajectory
   
    % go back to basal rate delivery after completing the clinician bolus successfuly, unless a patient bolus is just starting
    or_happens(basal_delivery_started, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(clinician_bolus_completed, T),
        not_happens(patient_bolus_delivery_started, T). % treating events happening at the same time


% ----------------------------------------------------------------------------------------------------------------------
% to avoid copy pasting these bits of code into multiple places

    shortcut_clinician_bolus_total_flow_rate(DurationMinutes, CroppedTotalFlowRate) :-   % bolus flow rate combined with basal flow rate, potentially cropped due to max pump flow
        initiallyP(basal_flow_rate(BasalRate)),
        initiallyP(vtbi(VTBI)),
        BolusRate .=. VTBI / DurationMinutes,               % R5.3.0(2)
        CombinedRate .=. BolusRate + BasalRate,             % R5.3.0(2)
        initiallyP(pump_flow_rate_max(MaxRate)),
        min(CombinedRate, MaxRate, CroppedTotalFlowRate).   % R5.3.0(2)
    shortcut_clinician_bolus_flow_rate(DurationMinutes, CroppedBolusFlowRate) :-         % bolus flow rate only (no basal), potentially cropped due to max pump flow
        shortcut_clinician_bolus_total_flow_rate(DurationMinutes, CroppedTotalFlowRate),
        initiallyP(basal_flow_rate(BasalRate)),
        CroppedBolusFlowRate .=. CroppedTotalFlowRate - BasalRate.
    shortcut_clinician_bolus_duration(DurationMinutes, CroppedDuration) :-               % bolus duration can be longer than requested due to flow rate getting cropped due to max pump flow
        shortcut_clinician_bolus_flow_rate(DurationMinutes, CroppedBolusFlowRate),
        initiallyP(vtbi(VTBI)),
        CroppedDuration .=. VTBI / CroppedBolusFlowRate.
    shortcut_clinician_bolus_duration_after_resume(DeliveredBeforeSuspended, DurationMinutes, CroppedDuration) :-   % remaining bolus duration after resume, also can be cropped due to max pump flow
        shortcut_clinician_bolus_flow_rate(DurationMinutes, CroppedBolusFlowRate),
        initiallyP(vtbi(VTBI)),
        CroppedDuration .=. (VTBI - DeliveredBeforeSuspended) / CroppedBolusFlowRate.


% ----------------------------------------------------------------------------------------------------------------------
% helper predicates

% TODO should be automated preprocessing
    can_trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, total_drug_delivered(TotalDelivered), T2) . %:- /*tr*/ incremental_start_time(INCREMENT_T), T1 .>=. INCREMENT_T, T2 .>=. INCREMENT_T.
    can_trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, total_bolus_drug_delivered(TotalBolusDelivered), T2) . %:- /*tr*/ incremental_start_time(INCREMENT_T), T1 .>=. INCREMENT_T, T2 .>=. INCREMENT_T.
    can_trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, clinician_bolus_drug_delivered(VtbiDrugRes), T2) . %:- /*tr*/ incremental_start_time(INCREMENT_T), T1 .>=. INCREMENT_T, T2 .>=. INCREMENT_T.


% TODO just to make this model compatible with tests for the state based models
    fluent(resumed_clinician_bolus_drug_delivered(X)). 
    or_holdsAt(resumed_clinician_bolus_drug_delivered(X), T) :- /*holdsAt(resumed_clinician_bolus_delivery_enabled(_), T),*/ holdsAt(clinician_bolus_drug_delivered(X), T).
    event(resumed_clinician_bolus_completed).
    or_happens(resumed_clinician_bolus_completed, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        /*holdsAt(resumed_clinician_bolus_delivery_enabled(_), T),*/ happens(clinician_bolus_completed, T).
    event(resumed_clinician_bolus_delivery_started(OriginalDuration)).
    or_happens(resumed_clinician_bolus_delivery_started(OriginalDuration), T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(clinician_bolus_resumed(OriginalDuration), T).