% UC7: Resume Infusion After Stop -- stopped clinician bolus
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
or_happens(start_button_pressed,                        60).    % Pre 1
    ?- holdsAt(basal_delivery_enabled,                  70).    % Pre 1
or_happens(clinician_bolus_requested(30),               118).   % Pre 1
    ?- happens(clinician_bolus_delivery_started(30),    118).   % Pre 1
or_happens(stop_button_pressed,                         120).   % Pre 1
    ?- happens(pump_stopped,                            120).   % Pre 1
    ?- happens(clinician_bolus_delivery_stopped,        120).   % Pre 1
    ?- not_holdsAt(clinician_bolus_delivery_enabled,    121).   % Pre 1

or_happens(start_button_pressed,                        240).   % Step 1

    ?- happens(pump_started,                            240).   % Step 2
    ?- happens(basal_delivery_started,                  240).   % Step 2

    ?- holdsAt(pump_running,                            241).   % Post 1 
    ?- holdsAt(basal_delivery_enabled,                  241).   % Post 1 

% check all queries in one:
?-  holdsAt(basal_delivery_enabled,                     70),
    happens(clinician_bolus_delivery_started(30),       118),
    happens(pump_stopped,                               120),
    happens(clinician_bolus_delivery_stopped,           120),
    not_holdsAt(clinician_bolus_delivery_enabled,       121),
    happens(pump_started,                               240),
    happens(basal_delivery_started,                     240),
    holdsAt(pump_running,                               241),
    holdsAt(basal_delivery_enabled,                     241).
    
/* --------------------------------- END OF FILE -------------------------------------------------------------------- */