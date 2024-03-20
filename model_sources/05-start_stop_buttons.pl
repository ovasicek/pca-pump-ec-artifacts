% ----------------------------------------------------------------------------------------------------------------------
% start / stop the system                -------------------------------------------------------------------------------

% R6.5.0(2), R6.5.0(3), R6.8.0(2), R6.5.0(22)
    % start button starts basal flow
    or_happens(basal_delivery_started, T) :- happens(start_button_pressed_valid, T).
        %not_happens(low_reservoir_warning_FACT, T), not_happens(empty_reservoir_alarm_FACT, T).

    % and starts the pump
    or_happens(pump_started, T) :- happens(start_button_pressed_valid, T).


% R6.5.0(5), R6.5.0(6)
    % stop button stops everything
    or_happens(basal_delivery_stopped, T) :- happens(stop_button_pressed_valid, T),
        holdsAt(basal_delivery_enabled, T).
    or_happens(kvo_delivery_stopped, T) :- happens(stop_button_pressed_valid, T),
        holdsAt(kvo_delivery_enabled, T).
    or_happens(patient_bolus_halted_stop_button, T) :- happens(stop_button_pressed_valid, T),
        holdsAt(patient_bolus_delivery_enabled, T).
    or_happens(clinician_bolus_halted_stop_button, T) :- happens(stop_button_pressed_valid, T),
        holdsAt(clinician_bolus_delivery_enabled, T).

    % and stops the pump R6.2.0(2), R6.8.0(2)
    or_happens(pump_stopped, T) :- happens(stop_button_pressed_valid, T),
        holdsAt(pump_running, T).