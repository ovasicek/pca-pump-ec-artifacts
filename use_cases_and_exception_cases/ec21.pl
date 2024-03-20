% EC21: Reservoir Empty
%
%   preconditions:
%       1 - low drug (EC20)
%
%   steps:
%       1 - Remaining volume of drug falls below a reservoir empty limit, either measured or determined
%       2 - Alarm sounded ...
%       3 - Pumping halted
%//     4 -
%
%   postcondition:
%       1 - Alarm sounded and displayed
%       2 - pumping halted

#include './init-base.pl'.
initiallyP(initial_drug_reservoir_contents(7)).     % set contents so that it runs out at the right time
low_reservoir_reasoning_enabled.                    % enable drug reservoir reasoning
empty_reservoir_reasoning_enabled.

% narrative                     ----------------------------------------------------------------------------------------
or_happens(start_button_pressed,                        60).    % Pre 1
    ?- holdsAt(basal_delivery_enabled,                  70).    % Pre 1
    ?- initiallyP(low_reservoir_treshold(Low)),
       holdsAt(drug_reservoir_contents(Low),            120).   % Pre 1
    ?- happens(low_reservoir_warning,                   120).   % Pre 1

    ?- initiallyP(empty_reservoir_treshold(Empty)),
       holdsAt(drug_reservoir_contents(Empty),          150).   % Step 1

    ?- happens(empty_reservoir_alarm,                   150).   % Step 2 && Post 1

    ?- happens(pump_stopped,                            150).   % Step 3

    ?- holdsAt(alarm_active,                            151).   % Post 1
    
    ?- holdsAt(pump_not_running,                        151).   % Post 2
    ?- holdsAt(drug_flow_rate(0),                       151).   % Post 2


% check all queries in one:
?-  holdsAt(basal_delivery_enabled,                      70),
    initiallyP(low_reservoir_treshold(Low)),
    holdsAt(drug_reservoir_contents(Low),               120),
    happens(low_reservoir_warning,                      120),

    initiallyP(empty_reservoir_treshold(Empty)),
    holdsAt(drug_reservoir_contents(Empty),             150),
    happens(empty_reservoir_alarm,                      150),
    holdsAt(alarm_active,                               151),
    holdsAt(pump_not_running,                           151),
    holdsAt(drug_flow_rate(0),                          151).

/* --------------------------------- END OF FILE -------------------------------------------------------------------- */