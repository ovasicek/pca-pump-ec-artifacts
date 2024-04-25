% EC7: Over-Flow Rate Alarm
%
%   preconditions:
%       1 - normal operation
%
%   steps:
%       1 - Measured drug flow rate
%//         a - basal flow rate exceeds prescribed basal flow rate by more than its allowed tolerance over a period of more than 5 minutes, issue basal over-infusion alarm
%//         b - basal flow rate goes into free flow, issue basal over-infusion alarm immediately
%           c - patient-requested bolus flow rate exceeds the prescribed patient-requested bolus rate setting by more than its allowed tolerance over a period of more than 10 seconds the pump shall issue a bolus over-infusion alarm
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
or_happens(start_button_pressed,                        60).                    % Pre 1
    ?- holdsIn(basal_delivery_enabled,              60, T),   T .=. 119 + 1/2.  % Pre 1

or_happens(patient_bolus_requested,                     T) :- T .=. 119 + 1/2.  % Pre 1
    ?- happens(patient_bolus_delivery_started,          T),   T .=. 119 + 1/2.  % Pre 1
    
or_happens(patient_bolus_rate_over_tolerance,           120).                   % Step 1c
    ?- happens(bolus_over_infusion_alarm,               T),   T .=. 120 + 1/6.  % Step 2 && Post 1  %! failure 1

    ?- happens(alarm_to_kvo,                            T),   T .=. 120 + 1/6.  % Step 3            %! failure 1
    ?- happens(patient_bolus_halted,                    T),   T .=. 120 + 1/6.  % Step 3            %! failure 1
    ?- happens(kvo_delivery_started,                    T),   T .=. 120 + 1/6.  % Step 3            %! failure 1
    ?- holdsAfter(kvo_delivery_enabled,                 T),   T .=. 120 + 1/6.  % Step 3            %! failure 1

    ?- holdsAfter(alarm_active,                         T),   T .=. 120 + 1/6.  % Post 1            %! failure 1

    ?- not_holdsAfter(pump_running,                     T),   T .=. 120 + 1/6.  % Post 2            %! failure 2
 %?%?- holdsAfter(kvo_delivery_enabled,                 T),   T .=. 120 + 1/6.  % Post 2            % TODO fix 2

% check all queries in one:
?-  holdsIn(basal_delivery_enabled,                 60, T1), T1 .=. 119 + 1/2,
    happens(patient_bolus_delivery_started,             T1),

    happens(bolus_over_infusion_alarm,                  T2), T2 .=. 120 + 1/6,
    happens(alarm_to_kvo,                               T2),
    happens(patient_bolus_halted,                       T2),
    happens(kvo_delivery_started,                       T2),
    holdsAfter(kvo_delivery_enabled,                    T2),
    holdsAfter(alarm_active,                            T2),

    not_holdsAfter(pump_running,                        T2).
 %?%holdsAfter(kvo_delivery_enabled,                    T2).

/* --------------------------------- END OF FILE -------------------------------------------------------------------- */