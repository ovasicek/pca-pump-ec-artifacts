% user inputs ----------------------------------------------------------------------------------------------------------
event(start_button_pressed_valid).
event(stop_button_pressed_valid).  
event(patient_bolus_requested_valid).
event(clinician_bolus_requested_valid(DurationMinutes)).


% start button can only be pressed when the pump is not running and there is no active alarm
or_happens(start_button_pressed_valid, T) :- happens(start_button_pressed, T),
    not_holdsAt(pump_running, T), not_holdsAt(alarm_active, T). %! TODO my own addition (not from the specification)


% stop button can only be pressed when the pump is running, or when it is not running but there is an active alarm to clear
or_happens(stop_button_pressed_valid, T) :- happens(stop_button_pressed, T),
    holdsAt(pump_running, T).                                               %! TODO my own addition (not from the specification)
or_happens(stop_button_pressed_valid, T) :- happens(stop_button_pressed, T),
    not_holdsAt(pump_running, T), holdsAt(alarm_active, T).                 %! TODO my own addition (not from the specification)


% patient bolus can only be requested during basal delivery or during clinician bolus delivery
or_happens(patient_bolus_requested_valid, T) :- happens(patient_bolus_requested, T),
    holdsAt(basal_delivery_enabled, T). %! TODO my own addition (not from the specification)
or_happens(patient_bolus_requested_valid, T) :- happens(patient_bolus_requested, T),
    holdsAt(clinician_bolus_delivery_enabled, T). %! TODO my own addition (not from the specification)


% clinician bolus can only be requested during basal delivery
or_happens(clinician_bolus_requested_valid(DurationMinutes), T) :- happens(clinician_bolus_requested(DurationMinutes), T),
    initiallyP(min_t_between_patient_bolus(Min)), DurationMinutes .>=. Min, % min min_t_between_patient_bolus  % R5.3.0(6)
    DurationMinutes .=<. 360,                                               % max 6 hours   R5.3.0(5)
    holdsAt(basal_delivery_enabled, T). %! TODO my own addition (not from the specification)





% alarm inputs ---------------------------------------------------------------------------------------------------------
event(pump_has_gone_into_free_flow_valid).
event(pump_flow_has_stopped_valid).
event(basal_rate_over_tolerance_valid).
event(basal_rate_within_tolerance_valid).
event(basal_rate_under_tolerance_valid).
event(patient_bolus_rate_over_tolerance_valid).
event(patient_bolus_rate_within_tolerance_valid).
event(patient_bolus_rate_under_tolerance_valid).
event(clinician_bolus_rate_over_tolerance_valid).
event(clinician_bolus_rate_within_tolerance_valid).
event(clinician_bolus_rate_under_tolerance_valid).
event(pump_temperature_over_55C_valid).
event(airinline_embolism_detected_valid).
event(upstream_occlusion_detected_valid).
event(downstream_occlusion_detected_valid).
event(door_has_been_opened_valid).


or_happens(pump_has_gone_into_free_flow_valid, T) :- happens(pump_has_gone_into_free_flow, T),
    holdsAt(pump_running, T).

or_happens(pump_flow_has_stopped_valid, T) :- happens(pump_flow_has_stopped, T),
    holdsAt(pump_running, T).

or_happens(basal_rate_over_tolerance_valid, T) :- happens(basal_rate_over_tolerance, T),
    holdsAt(basal_delivery_enabled, T).
or_happens(basal_rate_within_tolerance_valid, T) :- happens(basal_rate_within_tolerance, T),
    holdsAt(basal_delivery_enabled, T).
or_happens(basal_rate_under_tolerance_valid, T) :- happens(basal_rate_under_tolerance, T),
    holdsAt(basal_delivery_enabled, T).

or_happens(patient_bolus_rate_over_tolerance_valid, T) :- happens(patient_bolus_rate_over_tolerance, T),
    holdsAt(patient_bolus_delivery_enabled, T).
or_happens(patient_bolus_rate_within_tolerance_valid, T) :- happens(patient_bolus_rate_within_tolerance, T),
    holdsAt(patient_bolus_delivery_enabled, T).
or_happens(patient_bolus_rate_under_tolerance_valid, T) :- happens(patient_bolus_rate_under_tolerance, T),
    holdsAt(patient_bolus_delivery_enabled, T).

or_happens(clinician_bolus_rate_over_tolerance_valid, T) :- happens(clinician_bolus_rate_over_tolerance, T),
    holdsAt(clinician_bolus_delivery_enabled, T).
or_happens(clinician_bolus_rate_within_tolerance_valid, T) :- happens(clinician_bolus_rate_within_tolerance, T),
    holdsAt(clinician_bolus_delivery_enabled, T).
or_happens(clinician_bolus_rate_under_tolerance_valid, T) :- happens(clinician_bolus_rate_under_tolerance, T),
    holdsAt(clinician_bolus_delivery_enabled, T).

or_happens(pump_temperature_over_55C_valid, T) :- happens(pump_temperature_over_55C, T),
    holdsAt(pump_running, T).

or_happens(airinline_embolism_detected_valid, T) :- happens(airinline_embolism_detected, T),
    holdsAt(pump_running, T).
or_happens(upstream_occlusion_detected_valid, T) :- happens(upstream_occlusion_detected, T),
    holdsAt(pump_running, T).
or_happens(downstream_occlusion_detected_valid, T) :- happens(downstream_occlusion_detected, T),
    holdsAt(pump_running, T).

or_happens(door_has_been_opened_valid, T) :- happens(door_has_been_opened, T).