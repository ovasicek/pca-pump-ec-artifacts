% EC12: Air-in-line Embolism -- during patient bolus
%
%   preconditions:
%       1 - normal operation
%
%   steps:
%       1 - Air-in-line embolism detected, issue air-in-line embolism alarm
%       2 - Alarm sounded ...
%       3 - Pumping halted
%//     4 - Failure recorded in Fault Log
%
%   postcondition:
%       1 - Alarm sounded and displayed
%       2 - Infusion halted

#include './init-default.pl'.

% narrative                     ----------------------------------------------------------------------------------------
or_happens(start_button_pressed,                    60).                        % Pre 1
    ?- holdsIn(basal_delivery_enabled,              60, T),   T .=. 119 + 1/2.  % Pre 1

or_happens(patient_bolus_requested,                 T) :- T .=. 119 + 1/2.  % Pre 1
    ?- happens(patient_bolus_delivery_started,      T),   T .=. 119 + 1/2.  % Pre 1

or_happens(airinline_embolism_detected,             120).   % Step 1
    ?- happens(airinline_alarm,                     120).   % Step 2 && Post 1

    ?- happens(alarm_to_off,                        120).   % Step 3
    ?- happens(pump_stopped,                        120).   % Step 3

    ?- holdsAfter(alarm_active,                     120).   % Post 1

    ?- not_holdsAfter(pump_running,                 120).   % Post 2

% check all queries in one:
?-  holdsIn(basal_delivery_enabled,             60, T1), T1 .=. 119 + 1/2,
    happens(patient_bolus_delivery_started,         T1),
    happens(airinline_alarm,                        120),
    happens(alarm_to_off,                           120),
    happens(pump_stopped,                           120),
    holdsAfter(alarm_active,                        120),
    not_holdsAfter(pump_running,                    120).

/* --------------------------------- END OF FILE -------------------------------------------------------------------- */