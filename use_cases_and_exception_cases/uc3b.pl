% UC3: Clinician-Requested Bolus -- with a suspending bolus
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
    ?- holdsAt(basal_delivery_enabled,                          70).    % Pre 2

or_happens(clinician_bolus_requested(30),                       120).   % Step 3 && 4

    ?- happens(clinician_bolus_delivery_started(30),            120).   % Step 5

or_happens(patient_bolus_requested,                             123).   % Step 5
    ?- happens(patient_bolus_delivery_started,                  123).   % Step 5
    ?- happens(clinician_bolus_suspended(30),                   123).   % Step 5 -- interrupted
    ?- happens(patient_bolus_completed,                         124).   % Step 5
    ?- happens(resumed_clinician_bolus_delivery_started(30),    124).   % Step 5 -- resumed

    ?- not_happensInInc(clinician_bolus_halted_max_dose,   120, 151).   % Step 5, no EC
    ?- initiallyP(vtbi(X1)),                                            % Step 5
       holdsAt(clinician_bolus_drug_delivered(X2),              151),
       30 .=. 151 - 120 + 1,
       X1 = X2.

    ?- happens(clinician_bolus_completed,                       151).   % Step 5 && 6
    
    ?- happens(basal_delivery_started,                          151).   % Step 6 && Post 1
    ?- holdsAt(basal_delivery_enabled,                          152).   % Step 6 && Post 1

% check all queries in one:
?-  holdsAt(basal_delivery_enabled,                             70),
    happens(clinician_bolus_delivery_started(30),               120),
    happens(patient_bolus_delivery_started,                     123),
    happens(clinician_bolus_suspended(30),                      123),
    happens(patient_bolus_completed,                            124),
    happens(resumed_clinician_bolus_delivery_started(30),       124),
    not_happensInInc(clinician_bolus_halted_max_dose,      120, 151),     
    initiallyP(vtbi(X1)),
    holdsAt(clinician_bolus_drug_delivered(X2),                 151),
    30 .=. 151 - 120 + 1,
    X1 = X2,
    happens(clinician_bolus_completed,                          151),
    happens(basal_delivery_started,                             151),
    holdsAt(basal_delivery_enabled,                             152).

/* --------------------------------- END OF FILE -------------------------------------------------------------------- */