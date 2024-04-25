% UC3: Clinician-Requested Bolus
%
%   preconditions:
%       1 - Steps 1 to 14 of Normal Operation Use Case completed
%       2 - Basal rate being infused
%
%   steps:
%//     1 - 
%//     2 - 
%       3 - Clinician (optionally) sets duration of bolus infusion on Control Panel or ICE supervisor user interface
%       4 - Clinician requests bolus infusion on Control Panel, by pressing the Start Button (Exception Case: Inactivity Timeout)
%       5 - Begin infusing bolus at rate so that prescribed VTBI is infused over the duration selected by the clinician, interrupted by a patient-requested bolus, and resumed afterward. (Exception Case: Maximum Safe Dose)
%       6 - When the duration ends, resume basal rate infusion
%
%   postcondition:
%       1 - Resume basal rate infusion

#include './init-default.pl'.

% narrative                     ----------------------------------------------------------------------------------------
or_happens(start_button_pressed,                                60).    % Pre 1

    ?- holdsIn(basal_delivery_enabled,                      60, 120).   % Pre 2

or_happens(clinician_bolus_requested(30),                       120).   % Step 3 && 4
    
    ?- happens(clinician_bolus_delivery_started(30),            120).   % Step 5
    ?- happens(clinician_bolus_completed,                       T2),    % Step 5
       initiallyP(vtbi(VTBI)),                                            
       holdsAt(clinician_bolus_drug_delivered(VTBI),            T2),
       30 .=. T2 - 120.

    ?- happens(clinician_bolus_completed,                       T2),   % Step 5, no EC
       not_happensInInc(clinician_bolus_halted_max_dose,   120, T2).

    ?- happens(clinician_bolus_completed,                       T2),   % Step 6 && Post 1
       happens(basal_delivery_started,                          T2).
    ?- happens(clinician_bolus_completed,                       T2),   % Step 6 && Post 1
       holdsAfter(basal_delivery_enabled,                       T2).

% check all queries in one:
?-  holdsIn(basal_delivery_enabled,                         60, 120),
    happens(clinician_bolus_delivery_started(30),               120),

    happens(clinician_bolus_completed,                          T2),
    initiallyP(vtbi(VTBI)),                                            
    holdsAt(clinician_bolus_drug_delivered(VTBI),               T2),
    30 .=. T2 - 120,

    not_happensInInc(clinician_bolus_halted_max_dose,      120, T2),
    happens(basal_delivery_started,                             T2),
    holdsAfter(basal_delivery_enabled,                          T2).

/* --------------------------------- END OF FILE -------------------------------------------------------------------- */