% EC9: Pump Overheating -- during basal
%
%   preconditions:
%       1 - normal operation
%
%   steps:
%       1 - Pump temperature exceeds 55 C, issue pump overheated alarm
%       2 - Alarm sounded ...
%       3 - Pumping halted
%//     4 - Failure recorded in Fault Log
%
%   postcondition:
%       1 - Alarm sounded and displayed
%       2 - Infusion halted

#include './init-default.pl'.

% narrative                     ----------------------------------------------------------------------------------------
or_happens(start_button_pressed,                    60).        % Pre 1
    ?- holdsIn(basal_delivery_enabled,              60, 120).   % Pre 1

or_happens(pump_temperature_over_55C,               120).   % Step 1
    ?- happens(pump_overheated_alarm,               120).   % Step 2 && Post 1

    ?- happens(alarm_to_off,                        120).   % Step 3
    ?- happens(pump_stopped,                        120).   % Step 3

    ?- holdsAfter(alarm_active,                     120).   % Post 1
    
    ?- not_holdsAfter(pump_running,                 120).   % Post 2    

% check all queries in one:
?-  holdsIn(basal_delivery_enabled,             60, 120),
    happens(pump_overheated_alarm,                  120),
    happens(alarm_to_off,                           120),
    happens(pump_stopped,                           120),
    holdsAfter(alarm_active,                        120),
    not_holdsAfter(pump_running,                    120).

/* --------------------------------- END OF FILE -------------------------------------------------------------------- */