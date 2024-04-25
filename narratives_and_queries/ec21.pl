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

#include './init-partial-base.pl'.
#include './init-partial-maxdose.pl'.

initiallyP(initial_drug_reservoir_contents(7)).     % set contents so that it runs out at the right time
low_reservoir_reasoning_enabled.                    % enable low drug reservoir reasoning
empty_reservoir_reasoning_enabled.                  % enable empty drug reservoir reasoning

% narrative                     ----------------------------------------------------------------------------------------
or_happens(start_button_pressed,                        60).    % Pre 1
    ?- holdsIn(basal_delivery_enabled,              60, 120).   % Pre 1
    ?- initiallyP(low_reservoir_treshold(Low)),
       holdsAt(drug_reservoir_contents(Low),            120).   % Pre 1
    ?- happens(low_reservoir_warning,                   120).   % Pre 1

    ?- initiallyP(empty_reservoir_treshold(Empty)),
       holdsAt(drug_reservoir_contents(Empty),          150).   % Step 1

    ?- happens(empty_reservoir_alarm,                   150).   % Step 2 && Post 1

    ?- happens(pump_stopped,                            150).   % Step 3

    ?- holdsAfter(alarm_active,                         150).   % Post 1
    
    ?- not_holdsAfter(pump_running,                     150).   % Post 2
    ?- holdsAt(drug_flow_rate(0),                       151).   % Post 2


% check all queries in one:
?-  holdsIn(basal_delivery_enabled,                 60, 120),
    initiallyP(low_reservoir_treshold(Low)),
    holdsAt(drug_reservoir_contents(Low),               120),
    happens(low_reservoir_warning,                      120),

    initiallyP(empty_reservoir_treshold(Empty)),
    holdsAt(drug_reservoir_contents(Empty),             150),
    happens(empty_reservoir_alarm,                      150),
    holdsAfter(alarm_active,                            150),
    not_holdsAfter(pump_running,                        150),
    holdsAt(drug_flow_rate(0),                          151).

/* --------------------------------- END OF FILE -------------------------------------------------------------------- */