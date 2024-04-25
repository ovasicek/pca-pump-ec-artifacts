% EC8: Under-Flow Rate Warning -- during basal
%
%   preconditions:
%       1 - normal operation
%
%   steps:
%       1 - Measured drug flow rate
%           a - basal flow rate is less than prescribed basal flow rate by more than its allowed tolerance over a period of more than 5 minutes, issue basal under-infusion warning
%//         b - patient-requested bolus flow rate is less than the prescribed patient-requested bolus rate by more than its allowed tolerance over a period of more than 10 seconds the pump shall issue a bolus under-infusion warning
%//         c - clinician-requested bolus flow rate is less than the prescribed patient-requested bolus rate setting by more than its allowed tolerance over a period of more than 1 minutes the pump issues a square bolus under-infusion warning
%       2 - Warning sounded ...
%//     3 -
%
%   postcondition:
%       1 - Alarm sounded and displayed

#include './init-default.pl'.

% narrative                     ----------------------------------------------------------------------------------------
or_happens(start_button_pressed,                        60).    % Pre 1
    ?- holdsIn(basal_delivery_enabled,              60, 120).   % Pre 1

or_happens(basal_rate_under_tolerance,                  120).   % Step 1a
    ?- happens(basal_under_infusion_warning,            125).   % Step 2 && Post 1

% check all queries in one:
?-  holdsIn(basal_delivery_enabled,                 60, 120),
    happens(basal_under_infusion_warning,               125).

/* --------------------------------- END OF FILE -------------------------------------------------------------------- */