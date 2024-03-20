% ----------------------------------------------------------------------------------------------------------------------
% alarms and warnings           ----------------------------------------------------------------------------------------

% R5.2.0(5), R5.3.0(7)
    or_happens(kvo_delivery_started, T) :-
        happens(max_dose_warning, T).
    % happens(any_alarm, T) :- happens(max_dose_warning, T).                    % this is not in the model on purpose -- could cause loops (maybe)

% R5.1.0(4), R5.2.0(6), R5.3.0(4)
    or_happens(basal_delivery_stopped, T) :-
        happens(any_alarm, T), holdsAt(basal_delivery_enabled, T).
    or_happens(patient_bolus_halted_alarm, T) :-
        happens(any_alarm, T), holdsAt(patient_bolus_delivery_enabled, T).
    or_happens(clinician_bolus_halted_alarm, T) :-
        happens(any_alarm, T), holdsAt(clinician_bolus_delivery_enabled, T).
    or_happens(kvo_delivery_stopped, T) :-
        happens(alarm_to_off, T), holdsAt(kvo_delivery_enabled, T).

    fluent(alarm_active).
    or_initiates(any_alarm, alarm_active, T).
    or_initiates(max_dose_warning, alarm_active, T).
    or_initiates(empty_reservoir_alarm_EFFECT, alarm_active, T).

% R6.5.0(13)
    or_terminates(stop_button_pressed_valid, alarm_active, T) :- holdsAt(alarm_active, T).   % TODO risk of inf loop, probably fine due to stop_button_pressed being an external event

    % Table 4 -- aggregated based on response
    or_happens(any_alarm, T) :-
        happens(alarm_to_kvo, T).
    or_happens(kvo_delivery_started, T) :-
        happens(alarm_to_kvo, T), not_holdsAt(kvo_delivery_enabled, T).  % TODO risk of loop?

    or_happens(any_alarm, T) :-
        happens(alarm_to_off, T).
    or_happens(pump_stopped, T) :-
        happens(alarm_to_off, T), holdsAt(pump_running, T).

    % TODO special alarms
    % TODO warnings

% R6.4.0(2)
    or_happens(basal_over_infusion_alarm, T2) :-
        %happens(basal_rate_over_tolerance_for_over_5mins, T).
        T2 .=. T1 + 5,
        happens(basal_rate_over_tolerance_valid, T1),
        holdsAt(basal_delivery_enabled, T1),
        not_happensInInc(basal_rate_within_tolerance_valid, T1, T2),
        not_happensInInc(basal_delivery_stopped, T1, T2).
    or_happens(basal_over_infusion_alarm, T) :-
        happens(pump_has_gone_into_free_flow_valid, T), holdsAt(basal_delivery_enabled, T).
    or_happens(alarm_to_kvo, T) :-
        happens(basal_over_infusion_alarm, T).
% R6.4.0(3)
    or_happens(basal_under_infusion_warning, T2) :-
        %happens(basal_rate_under_tolerance_for_over_5mins, T).
        T2 .=. T1 + 5,
        happens(basal_rate_under_tolerance_valid, T1),
        holdsAt(basal_delivery_enabled, T1),
        not_happensInInc(basal_rate_within_tolerance_valid, T1, T2),
        not_happensInInc(basal_delivery_stopped, T1, T2).
    or_happens(basal_under_infusion_warning, T) :-
        happens(pump_flow_has_stopped_valid, T), holdsAt(basal_delivery_enabled, T).

% R6.4.0(4)
    or_happens(bolus_over_infusion_alarm, T2) :-
        %happens(patient_bolus_rate_over_tolerance_for_over_1min, T).
        T2 .=. T1 + 1,                                                          % TODO fix "+ 1/6"
        happens(patient_bolus_rate_over_tolerance_valid, T1),
        holdsAt(patient_bolus_delivery_enabled, T1),
        not_happensInInc(patient_bolus_rate_within_tolerance_valid, T1, T2),
        not_happensInInc(patient_bolus_delivery_stopped, T1, T2).
    or_happens(bolus_over_infusion_alarm, T) :-
        happens(pump_has_gone_into_free_flow_valid, T), holdsAt(patient_bolus_delivery_enabled, T).
    or_happens(alarm_to_kvo, T) :-
        happens(bolus_over_infusion_alarm, T).
% R6.4.0(5)
    or_happens(bolus_under_infusion_warning, T2) :-
        %happens(patient_bolus_rate_under_tolerance_for_over_1min, T).
        T2 .=. T1 + 1,                                                          % TODO fix "+ 1/6"
        happens(patient_bolus_rate_under_tolerance_valid, T1),
        holdsAt(patient_bolus_delivery_enabled, T1),
        not_happensInInc(patient_bolus_rate_within_tolerance_valid, T1, T2),
        not_happensInInc(patient_bolus_delivery_stopped, T1, T2).
    or_happens(bolus_under_infusion_warning, T) :-
        happens(pump_flow_has_stopped_valid, T), holdsAt(patient_bolus_delivery_enabled, T).

% R6.4.0(6)
    or_happens(clinician_bolus_over_infusion_alarm, T2) :-
        %happens(clinician_bolus_rate_over_tolerance_for_over_5min, T).
        T2 .=. T1 + 5,                                                          % TODO fix "+ 1"
        happens(clinician_bolus_rate_over_tolerance_valid, T1),
        holdsAt(clinician_bolus_delivery_enabled, T1),
        not_happensInInc(clinician_bolus_rate_within_tolerance_valid, T1, T2),
        not_happensInInc(clinician_bolus_delivery_stopped, T1, T2).
    or_happens(clinician_bolus_over_infusion_alarm, T) :-
        happens(pump_has_gone_into_free_flow_valid, T), holdsAt(clinician_bolus_delivery_enabled, T).
    or_happens(alarm_to_kvo, T) :-
        happens(clinician_bolus_over_infusion_alarm, T).
% R6.4.0(7)
    or_happens(clinician_bolus_under_infusion_warning, T2) :-
        T2 .=. T1 + 5,                                                          % TODO fix "+ 1"
        happens(clinician_bolus_rate_under_tolerance_valid, T1),
        holdsAt(clinician_bolus_delivery_enabled, T1),
        not_happensInInc(clinician_bolus_rate_within_tolerance_valid, T1, T2),
        not_happensInInc(clinician_bolus_delivery_stopped, T1, T2).
    or_happens(clinician_bolus_under_infusion_warning, T) :-
        happens(pump_flow_has_stopped_valid, T), holdsAt(clinician_bolus_delivery_enabled, T).

% R6.4.0(8)
    or_happens(pump_overheated_alarm, T) :-
        happens(pump_temperature_over_55C_valid, T).
    or_happens(alarm_to_off, T) :-
        happens(pump_overheated_alarm, T).

% R6.1.0(4), R7.2.0(3)
    or_happens(airinline_alarm, T) :-
        happens(airinline_embolism_detected_valid, T).
    or_happens(alarm_to_off, T) :-
        happens(airinline_alarm, T).
% R6.1.0(3), R7.2.0(4), R7.2.0(6)
    or_happens(upstream_occlusion_alarm, T) :-
        happens(upstream_occlusion_detected_valid, T).
    or_happens(alarm_to_off, T) :-
        happens(upstream_occlusion_alarm, T).
% R6.1.0(2), R7.2.0(5), R7.2.0(6)
    or_happens(downstream_occlusion_alarm, T) :-
        happens(downstream_occlusion_detected_valid, T).
    or_happens(alarm_to_off, T) :-
        happens(downstream_occlusion_alarm, T).

% R7.2.0(8)
    or_happens(open_door_alarm, T) :-
        happens(door_has_been_opened_valid, T), holdsAt(pump_running, T).
