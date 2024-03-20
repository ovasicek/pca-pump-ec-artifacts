% ----------------------------------------------------------------------------------------------------------------------
% user input events
event(start_button_pressed).
event(stop_button_pressed).
event(patient_bolus_requested).
event(clinician_bolus_requested(DurationMinutes)).


% ----------------------------------------------------------------------------------------------------------------------
% alarm input events (failures outside of the logic of the system)
event(pump_has_gone_into_free_flow).
event(pump_flow_has_stopped).
event(basal_rate_over_tolerance).
event(basal_rate_within_tolerance).
event(basal_rate_under_tolerance).
event(patient_bolus_rate_over_tolerance).
event(patient_bolus_rate_within_tolerance).
event(patient_bolus_rate_under_tolerance).
event(clinician_bolus_rate_over_tolerance).
event(clinician_bolus_rate_within_tolerance).
event(clinician_bolus_rate_under_tolerance).
event(pump_temperature_over_55C).
event(airinline_embolism_detected).
event(upstream_occlusion_detected).
event(downstream_occlusion_detected).
event(door_has_been_opened).


% ----------------------------------------------------------------------------------------------------------------------
% system output events

% state of the pump
event(pump_started).
event(pump_stopped).

% basal delivery
event(basal_delivery_started).
event(basal_delivery_stopped).

% KVO delivery
event(kvo_delivery_started).
event(kvo_delivery_stopped).

% patient bolus delivery
event(patient_bolus_delivery_started).
event(patient_bolus_delivery_stopped).
event(patient_bolus_denied).
    event(patient_bolus_denied_max_dose).
    event(patient_bolus_denied_too_soon).
event(patient_bolus_completed).                 % automatic end of bolus after delivering the prescribed VTBI
event(patient_bolus_halted).                    % premature end of bolus 

% clinician bolus delivery
event(clinician_bolus_delivery_started(DurationMinutes)).
event(clinician_bolus_delivery_stopped).
event(clinician_bolus_completed).               % automatic end of bolus after delivering the prescribed VTBI
event(clinician_bolus_halted).                  % premature end of bolus 
    event(clinician_bolus_halted_max_dose).     %   - due to reaching max dose
event(clinician_bolus_suspended(OriginalDuration)).

% alarms caused by the logic of the system (deducible by the model)
event(max_dose_warning).
event(low_reservoir_warning).
    event(basal_halted_low_reservoir).
    event(kvo_low_reservoir).
    event(patient_bolus_halted_low_reservoir).
    event(clinician_bolus_halted_low_reservoir).
event(empty_reservoir_alarm).
    event(kvo_halted_empty_reservoir).

% alarms caused by external events
event(any_alarm).
    event(alarm_to_off).
        event(pump_overheated_alarm).
        event(airinline_alarm). 
        event(upstream_occlusion_alarm).
        event(downstream_occlusion_alarm).
    event(alarm_to_kvo).
        event(basal_over_infusion_alarm).
        event(bolus_over_infusion_alarm).
        event(clinician_bolus_over_infusion_alarm).

% alarms caused by external events, but with no system reponse
    event(basal_under_infusion_warning).
    event(bolus_under_infusion_warning).
    event(open_door_alarm).