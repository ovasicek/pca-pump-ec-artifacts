% EC7: Over-Flow Rate Alarm
%
%   preconditions:
%       1 - normal operation
%
%   steps:
%       1 - Measured drug flow rate
%           a - basal flow rate exceeds prescribed basal flow rate by more than its allowed tolerance over a period of more than 5 minutes, issue basal over-infusion alarm
%//         b - basal flow rate goes into free flow, issue basal over-infusion alarm immediately
%//         c - patient-requested bolus flow rate exceeds the prescribed patient-requested bolus rate setting by more than its allowed tolerance over a period of more than 10 seconds the pump shall issue a bolus over-infusion alarm
%//         d - patient-requested bolus flow rate goes into free flow, issue a bolus over-infusion alarm immediately
%//         e - clinician-requested bolus flow rate exceeds the prescribed patient-requested bolus rate setting by more than its allowed tolerance over a period of more than 1 minutes the pump shall issue a square bolus over-infusion alarm
%//         f - clinician-requested bolus flow rate goes into free flow, issue a square bolus overinfusion alarm immediately
%       2 - Alarm sounded ...
%       3 - Pump at KVO rate
%//     4 -
%
%   postcondition:
%       1 - Alarm sounded and displayed
%       2 - Infusion halted

#include './init-default.pl'.

% narrative                     ----------------------------------------------------------------------------------------
or_happens(start_button_pressed,                        60).    % Pre 1
    ?- holdsAt(basal_delivery_enabled,                  70).    % Pre 1

or_happens(basal_rate_over_tolerance,                   120).   % Step 1a
    ?- happens(basal_over_infusion_alarm,               420).   % Step 2 && Post 1

    ?- happens(alarm_to_kvo,                            420).   % Step 3
    ?- happens(kvo_delivery_started,                    420).   % Step 3

    ?- holdsAt(alarm_active,                            121).   % Post 1
    
    ?- holdsAt(pump_not_running,                        421).   % Post 2    %! failure
 %?%?- holdsAt(kvo_delivery_enabled,                    421).   % Post 2    % TODO fix

% check all queries in one:
?-  holdsAt(basal_delivery_enabled,                      70),
    happens(basal_over_infusion_alarm,                  420),
    happens(alarm_to_kvo,                               420),
    happens(kvo_delivery_started,                       420),
    holdsAt(kvo_delivery_enabled,                       421),
    holdsAt(alarm_active,                               421),

    holdsAt(pump_not_running,                           421).
 %?%holdsAt(kvo_delivery_enabled,                       421).

/* --------------------------------- END OF FILE -------------------------------------------------------------------- */