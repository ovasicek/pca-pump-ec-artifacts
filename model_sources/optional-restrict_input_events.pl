% this is an optional extension which tells scasp that input events can happen at the same time (only one event at a time)
%   - important for abduction of input events (otherwise multiple will happen at the same time)
%   - otherwise only usefull as a validation of user narrative

% user inputs can never happen at the same time    
:- happens(start_button_pressed, T), happens(stop_button_pressed, T).
:- happens(start_button_pressed, T), happens(patient_bolus_requested, T).
:- happens(start_button_pressed, T), happens(clinician_bolus_requested(_), T).
:- happens(stop_button_pressed, T), happens(patient_bolus_requested, T).
:- happens(stop_button_pressed, T), happens(clinician_bolus_requested(_), T).
:- happens(patient_bolus_requested, T), happens(clinician_bolus_requested(_), T).