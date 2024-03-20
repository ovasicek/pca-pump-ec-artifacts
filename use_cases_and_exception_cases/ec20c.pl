% EC20: Reservoir Low -- during clinician bolus
%
%   preconditions:
%       1 - normal operation
%
%   steps:
%       1 - Remaining volume of drug falls below a reservoir low limit, either measured or determined
%       2 - Warning sounded ...
%       3 - Pump rate limited to basal rate         %?% TODO fix "to kvo rate"
%//     4 -
%
%   postcondition:
%       1 - Warning sounded and displayed
%       2 - pump rate limited to basal rate         %?% TODO fix "to kvo rate"

#include './init-base.pl'.
initiallyP(initial_drug_reservoir_contents(7.5)).   % set contents so that it runs out at the right time
low_reservoir_reasoning_enabled.                    % enable drug reservoir reasoning

% narrative                     ----------------------------------------------------------------------------------------
or_happens(start_button_pressed,                        60).    % Pre 1
    ?- holdsAt(basal_delivery_enabled,                  70).    % Pre 1
or_happens(clinician_bolus_requested(30),               105).   % Pre 1
    ?- happens(clinician_bolus_delivery_started(30),    105).   % Pre 1

    ?- initiallyP(low_reservoir_treshold(Low)),
       holdsAt(drug_reservoir_contents(Low),            120).   % Step 1

    ?- happens(low_reservoir_warning,                   120).   % Step 2 && Post 1

    ?- happens(clinician_bolus_delivery_stopped,        120).   % Step 3

    ?- happens(basal_delivery_started,                  120).   % Step 3            %! failure
    ?- holdsAt(basal_delivery_enabled,                  121).   % Step 3 && Post 2  %! failure
    ?- initiallyP(basal_flow_rate(F)),
       holdsAt(drug_flow_rate(F),                       121).   % Step 3 && Post 2  %! failure
 %?%?- happens(kvo_delivery_started,                    120).   % Step 3            % TODO fix
 %?%?- holdsAt(kvo_delivery_enabled,                    121).   % Step 3 && Post 2  % TODO fix
 %?%?- initiallyP(kvo_flow_rate(F)),                            
 %?%   holdsAt(drug_flow_rate(F),                       121).   % Step 3 && Post 2  % TODO fix


% check all queries in one:
?-  holdsAt(basal_delivery_enabled,                      70),
    happens(clinician_bolus_delivery_started(30),       105),
    initiallyP(low_reservoir_treshold(Low)),
    holdsAt(drug_reservoir_contents(Low),               120),
    happens(low_reservoir_warning,                      120),
    happens(clinician_bolus_delivery_stopped,           120),

    happens(basal_delivery_started,                     121),
    holdsAt(basal_delivery_enabled,                     121),
    initiallyP(basal_flow_rate(F)),
    holdsAt(drug_flow_rate(F),                          121).
 %?%happens(kvo_delivery_started,                       120),
 %?%holdsAt(kvo_delivery_enabled,                       121),
 %?%initiallyP(kvo_flow_rate(F)),                            
 %?%holdsAt(drug_flow_rate(F),                          121).

/* --------------------------------- END OF FILE -------------------------------------------------------------------- */