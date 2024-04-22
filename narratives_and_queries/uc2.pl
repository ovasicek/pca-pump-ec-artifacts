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

    ?- T1 .>. 60, T1 .=<. 120,
       holdsAt(basal_delivery_enabled,              T1).    % Pre 2

    ?- initiallyP(min_t_between_patient_bolus(MinT)),       % Pre 3
       X1 .>. 120 - MinT, X1 .<. 120,
       not_holdsAt(patient_bolus_delivery_enabled,  X1).

or_happens(patient_bolus_requested,                 120).   % Step 1
    
    ?- not_happens(patient_bolus_denied_too_soon,   120).   % Step 2, no EC1
    
    ?- not_happens(patient_bolus_denied_max_dose,   120).   % Step 3, no EC13
    ?- happens(patient_bolus_delivery_started,      120).   % Step 3
    
    ?- happens(patient_bolus_completed,             T2),    % Step 4
       initiallyP(vtbi(X2)),
       holdsAt(patient_bolus_drug_delivered(X2),    T2).

    ?- happens(patient_bolus_completed,             T2),    % Step 4 && Post 1
       happens(basal_delivery_started,              T2).   
    ?- happens(patient_bolus_completed,             T2),    % Step 4 && Post 1
       T3 .>. T2,
       holdsAt(basal_delivery_enabled,              T3).   

% check all queries in one:
?-  T1 .>. 60, T1 .=<. 120,
    holdsAt(basal_delivery_enabled,                 T1),

    initiallyP(min_t_between_patient_bolus(MinT)),
    X1 .>. 120 - MinT, X1 .<. 120,
    not_holdsAt(patient_bolus_delivery_enabled,     X1),

    not_happens(patient_bolus_denied_too_soon,      120),
    not_happens(patient_bolus_denied_max_dose,      120),
    happens(patient_bolus_delivery_started,         120),

    happens(patient_bolus_completed,                T2),
    initiallyP(vtbi(X2)),
    holdsAt(patient_bolus_drug_delivered(X2),       T2),

    happens(basal_delivery_started,                 T2),
    
    T3 .>. T2,
    holdsAt(basal_delivery_enabled,                 T3).

/* --------------------------------- END OF FILE -------------------------------------------------------------------- */