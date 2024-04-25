% UC7: Resume Infusion After Stop -- stopped patient bolus
%
%   preconditions:
%       1 - Infusion Halted by Stop Button
%
%   steps:
%       1 - Clinician presses Start Button
%       2 - Previous normal operation resumes
%
%   postcondition:
%       1 - Resume previous normal operation

#include './init-default.pl'.

% narrative                     ----------------------------------------------------------------------------------------
or_happens(start_button_pressed,                    60).    % Pre 1
    ?- holdsIn(basal_delivery_enabled,          60, 239/2). % Pre 1   

or_happens(patient_bolus_requested,                 239/2). % Pre 1 (239/2 = 119.5)
    ?- happens(patient_bolus_delivery_started,      239/2). % Pre 1
    ?- holdsIn(patient_bolus_delivery_enabled, 239/2, 120). % Pre 1
or_happens(stop_button_pressed,                     120).   % Pre 1
    ?- happens(pump_stopped,                        120).   % Pre 1
    ?- happens(patient_bolus_delivery_stopped,      120).   % Pre 1

    ?- not_holdsIn(pump_running,               120, 240).   % Pre 1

or_happens(start_button_pressed,                    240).   % Step 1

    ?- happens(pump_started,                        240).   % Step 2
    ?- happens(basal_delivery_started,              240).   % Step 2

    ?- holdsAfter(pump_running,                     240).   % Post 1  
    ?- holdsAfter(basal_delivery_enabled,           240).   % Post 1 

% check all queries in one:

?-  holdsIn(basal_delivery_enabled,           60, 239/2),

    happens(patient_bolus_delivery_started,       239/2),
    holdsIn(patient_bolus_delivery_enabled,  239/2, 120),
    happens(pump_stopped,                           120),
    happens(patient_bolus_delivery_stopped,         120),

    not_holdsIn(pump_running,                  120, 240),
    happens(pump_started,                           240),
    happens(basal_delivery_started,                 240),
    holdsAfter(pump_running,                        240),
    holdsAfter(basal_delivery_enabled,              240).
    
/* --------------------------------- END OF FILE -------------------------------------------------------------------- */