% EC7: Over-Flow Rate Alarm
%
%   preconditions:
%       1 - normal operation
%
%   steps:
%       1 - Measured drug flow rate
%//         a - basal flow rate exceeds prescribed basal flow rate by more than its allowed tolerance over a period of more than 30 minutes, issue basal over-infusion alarm
%//         b - basal flow rate goes into free flow, issue basal over-infusion alarm immediately
%//         c - patient-requested bolus flow rate exceeds the prescribed patient-requested bolus rate setting by more than its allowed tolerance over a period of more than 10 seconds the pump shall issue a bolus over-infusion alarm
%//         d - patient-requested bolus flow rate goes into free flow, issue a bolus over-infusion alarm immediately
%           e - clinician-requested bolus flow rate exceeds the prescribed patient-requested bolus rate setting by more than its allowed tolerance over a period of more than 1 minutes the pump shall issue a square bolus over-infusion alarm
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

or_happens(clinician_bolus_requested(30),               118).   % Pre 1
    ?- happens(clinician_bolus_delivery_started(30),    118).   % Pre 1

or_happens(clinician_bolus_rate_over_tolerance,         120).   % Step 1e
    ?- happens(clinician_bolus_over_infusion_alarm,     121).   % Step 2 && Post 1  %! failure 1

    ?- happens(clinician_bolus_halted_alarm,            121).   % Step 3            %! failure 1
    ?- happens(alarm_to_kvo,                            121).   % Step 3            %! failure 1
    ?- happens(kvo_delivery_started,                    121).   % Step 3            %! failure 1
    ?- holdsAt(kvo_delivery_enabled,                    122).   % Step 3            %! failure 1

    ?- holdsAt(alarm_active,                            121).   % Post 1            %! failure 1
    
    ?- holdsAt(pump_not_running,                        122).   % Post 2            %! failure 2
 %?%?- holdsAt(kvo_delivery_enabled,                    121).   % Post 2            % TODO fix 2

% check all queries in one:
?-  holdsAt(basal_delivery_enabled,                     70),
    happens(clinician_bolus_delivery_started(30),       118),
    happens(clinician_bolus_over_infusion_alarm,        121),
    happens(clinician_bolus_halted_alarm,               121),
    happens(alarm_to_kvo,                               121),
    happens(kvo_delivery_started,                       121),
    holdsAt(kvo_delivery_enabled,                       122),
    holdsAt(alarm_active,                               121),
    
    holdsAt(pump_not_running,                           121).
 %?%holdsAt(kvo_delivery_enabled,                       121).

/* --------------------------------- END OF FILE -------------------------------------------------------------------- */