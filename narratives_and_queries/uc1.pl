% UC1: Normal Operation of PCA Pump
%
%   preconditions:
%//      1
%//      2
%//      3
%//      4
%//      5
%        6 - Pre: PCA pump is off
%
%   steps:
%//      1
%//      2
%//      3
%//      4
%//      5
%//      6
%//      7
%//      8
%//      9
%//     10
%//     11
%//     12
%//     13
%       14 - Clinician presses Start button to begin basal-rate infusion
%?      15 - Bolus dose infused upon request; see Use Case: Bolus Infusion -- tested in UC2 and UC3
%       16 - Clinician presses Stop button to halt infusion
%//     17
%//     18
%//     19
%
%   postcondition:
%       01 - PCA pump is turned off

#include './init-default.pl'.

% narrative                     ----------------------------------------------------------------------------------------
    ?- not_holdsAt(pump_running,                    50).    % Pre 6
or_happens(start_button_pressed,                    60).    % Step 14
    ?- happens(pump_started,                        60).    % Step 14
    ?- happens(basal_delivery_started,              60).    % Step 14

    ?- holdsAt(pump_running,                        70).
    ?- holdsAt(basal_delivery_enabled,              70).

or_happens(stop_button_pressed,                     6000).  % Step 16
    ?- happens(pump_stopped,                        6000).  % Step 16
    ?- happens(basal_delivery_stopped,              6000).  % Step 16
                                                
    ?- not_holdsAt(pump_running,                    6010).  % Post 1

% check all queries in one:
?-  not_holdsAt(pump_running,                       50),
    happens(pump_started,                           60),
    happens(basal_delivery_started,                 60),
    holdsAt(pump_running,                           70),
    holdsAt(basal_delivery_enabled,                 70),
    happens(pump_stopped,                           6000),
    happens(basal_delivery_stopped,                 6000),
    not_holdsAt(pump_running,                       6010).

/* --------------------------------- END OF FILE -------------------------------------------------------------------- */