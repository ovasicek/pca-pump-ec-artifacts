% EC7: Over-Flow Rate Alarm
%
%   preconditions:
%       1 - normal operation
%
%   steps:
%       1 - Measured drug flow rate
%//         a - basal flow rate exceeds prescribed basal flow rate by more than its allowed tolerance over a period of more than 5 minutes, issue basal over-infusion alarm
%//         b - basal flow rate goes into free flow, issue basal over-infusion alarm immediately
%//         c - patient-requested bolus flow rate exceeds the prescribed patient-requested bolus rate setting by more than its allowed tolerance over a period of more than 10 seconds the pump shall issue a bolus over-infusion alarm
%//         d - patient-requested bolus flow rate goes into free flow, issue a bolus over-infusion alarm immediately
%//         e - clinician-requested bolus flow rate exceeds the prescribed patient-requested bolus rate setting by more than its allowed tolerance over a period of more than 1 minutes the pump shall issue a square bolus over-infusion alarm
%           f - clinician-requested bolus flow rate goes into free flow, issue a square bolus overinfusion alarm immediately
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
    ?- holdsIn(basal_delivery_enabled,              60, 118).   % Pre 1

or_happens(clinician_bolus_requested(30),               118).   % Pre 1
    ?- happens(clinician_bolus_delivery_started(30),    118).   % Pre 1

or_happens(pump_has_gone_into_free_flow,                120).   % Step 1f
    ?- happens(clinician_bolus_over_infusion_alarm,     120).   % Step 2 && Post 1

    ?- happens(alarm_to_kvo,                            120).   % Step 3
    ?- happens(clinician_bolus_halted,                  120).   % Step 3
    ?- happens(kvo_delivery_started,                    120).   % Step 3
    ?- holdsAfter(kvo_delivery_enabled,                 120).   % Step 3

    ?- holdsAfter(alarm_active,                         120).   % Post 1

    ?- not_holdsAfter(pump_running,                     120).   % Post 2    %! failure
 %?%?- holdsAfter(kvo_delivery_enabled,                 120).   % Post 2    % TODO fix

% check all queries in one:
?-  holdsIn(basal_delivery_enabled,                 60, 118),
    happens(clinician_bolus_delivery_started(30),       118),
    happens(clinician_bolus_over_infusion_alarm,        120),
    happens(alarm_to_kvo,                               120),
    happens(clinician_bolus_halted,                     120),
    happens(kvo_delivery_started,                       120),
    holdsAfter(kvo_delivery_enabled,                    120),
    holdsAfter(alarm_active,                            120),
    
    not_holdsAfter(pump_running,                        120).
 %?%holdsAfter(kvo_delivery_enabled,                    120).

/* --------------------------------- END OF FILE -------------------------------------------------------------------- */