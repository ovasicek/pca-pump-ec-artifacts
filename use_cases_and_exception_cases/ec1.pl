% EC1: Bolus Request Too Soon
%
%   preconditions:
%       1 - Patient received recent bolus
%
%   steps:
%       1 - Check of minimum time between boluses fails (Use Cases: PatientRequested Bolus or ClinicianRequested Bolus)
%//     2
%//     3
%
%   postcondition:
%       1 - No bolus infused

#include './init-default.pl'.

% narrative                     ----------------------------------------------------------------------------------------
or_happens(start_button_pressed,                    60).    % Pre 1
    ?- holdsAt(basal_delivery_enabled,              70).    % Pre 1

or_happens(patient_bolus_requested,                 120).   % Pre 1
    ?- happens(patient_bolus_delivery_started,      120).   % Pre 1
    ?- happens(patient_bolus_completed,             121).   % Pre 1

or_happens(patient_bolus_requested,                 123).   % Step 1   
    ?- happens(patient_bolus_denied_too_soon,       123).   % Step 1
    ?- initiallyP(min_t_between_patient_bolus(X)),          % Step 1
       X .>. 123 - 121.   
    ?- not_happens(patient_bolus_delivery_started,  123).   % Post 1

% check all queries in one:
?-  holdsAt(basal_delivery_enabled,                 70),
    happens(patient_bolus_delivery_started,         120),
    happens(patient_bolus_completed,                121),
    happens(patient_bolus_denied_too_soon,          123),
    initiallyP(min_t_between_patient_bolus(X)), X .>. 123 - 121,   
    not_happens(patient_bolus_delivery_started,     123).

/* --------------------------------- END OF FILE -------------------------------------------------------------------- */