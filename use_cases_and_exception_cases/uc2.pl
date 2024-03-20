% UC2: Patient-Requested Bolus
%
%   preconditions:
%       1 - Steps 1 to 14 of Normal Operation Use Case completed
%       2 - Basal rate being infused
%       3 - Prescribed minimum time between boluses has elapsed
%
%   steps:
%       1 - Patient presses bolus request button
%       2 - Time since last bolus compared with prescribed minimum time between boluses (Exception Case: Bolus Request Too Soon)
%       3 - If not too soon, begin infusing VTBI (Exception Case: Maximum Safe Dose)
%       4 - After prescribed volume-to-be-infused (VTBI) has been infused, resume basal rate infusion
%
%   postcondition:
%       1 - Resume basal rate infusion

#include './init-default.pl'.

% narrative                     ----------------------------------------------------------------------------------------
or_happens(start_button_pressed,                    60).    % Pre 1
    ?- holdsAt(basal_delivery_enabled,              70).    % Pre 2
                                                            % Pre 3 %TODO no prior bolus

or_happens(patient_bolus_requested,                 120).   % Step 1
    
    ?- not_happens(patient_bolus_denied_too_soon,   120).   % Step 2
    
    ?- not_happens(patient_bolus_denied_max_dose,   120).   % Step 3, no EC
    ?- happens(patient_bolus_delivery_started,      120).   % Step 3
    
    ?- initiallyP(vtbi(X1)),                                % Step 4
       holdsAt(patient_bolus_drug_delivered(X2),    121),
       X1 = X2.
    ?- happens(patient_bolus_completed,             121).   % Step 4
    ?- happens(basal_delivery_started,              121).   % Step 4 && Post 1
    ?- holdsAt(basal_delivery_enabled,              122).   % Step 4 && Post 1

% check all queries in one:
?-  holdsAt(basal_delivery_enabled,                 70),
    not_happens(patient_bolus_denied_too_soon,      120),
    not_happens(patient_bolus_denied_max_dose,      120),
    happens(patient_bolus_delivery_started,         120),
    initiallyP(vtbi(X1)),
    holdsAt(patient_bolus_drug_delivered(X2),       121),
    X1 = X2,
    happens(patient_bolus_completed,                121),
    happens(basal_delivery_started,                 121),
    holdsAt(basal_delivery_enabled,                 122).

/* --------------------------------- END OF FILE -------------------------------------------------------------------- */