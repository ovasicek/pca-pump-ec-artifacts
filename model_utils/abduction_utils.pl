% ----------------------------------------------------------------------------------------------------------------------
% utils for abduction                        ---------------------------------------------------------------------------

user_input_event(start_button_pressed).
user_input_event(stop_button_pressed).
user_input_event(patient_bolus_requested).
user_input_event(clinician_bolus_requested(120)).

alarm_input_event(alarm_to_off).
alarm_input_event(alarm_to_kvo).


% abducible_happens_user_input_event
    happens(E, T) :- user_input_event(E), abducible_happens_user_input_event(E, T).

    %%helper_xor(ahu_a, E, T) :- user_input_event(E), abducible_happens_user_input_event(E, T), not helper_xor(ahu_b, E, T).
    %%helper_xor(ahu_b, E, T) :- user_input_event(E), abducible_happens_user_input_event(E, T), not helper_xor(ahu_a, E, T).
    %%happens(E, T) :- helper_xor(ahu_a, E, T).
    %%not_happens(E, T) :- helper_xor(ahu_b, E, T).


% abducible_happens_alarm_input_event
    happens(E, T) :- alarm_input_event(E), abducible_happens_alarm_input_event(E, T).
    
    %%helper_xor(aha_a, E, T) :- abducible_happens_alarm_input_event(E, T), not helper_xor(aha_b, E, T).
    %%helper_xor(aha_b, E, T) :- abducible_happens_alarm_input_event(E, T), not helper_xor(aha_a, E, T).
    %%happens(E, T) :- alarm_input_event(E), helper_xor(aha_a, E, T).
    %%not_happens(E, T) :- alarm_input_event(E), helper_xor(aha_b, E, T).


% abducible_happens_any_input_event
    abducible_happens_user_input_event(E, T) :- abducible_happens_any_input_event(E, T).
    abducible_happens_alarm_input_event(E, T) :- abducible_happens_any_input_event(E, T).




