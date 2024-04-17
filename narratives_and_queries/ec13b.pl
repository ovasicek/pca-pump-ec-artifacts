% EC13: Maximum Safe Dose -- caused by a patient bolus
%
%   preconditions:
%       1 - normal operation
%
%   steps:
%       1 - Total drug dose for period of time in Drug Library exceeded, issue max dose warning
%       2 - Warning sounded and displayed by Control Panel and ...
%       3 - Infusion switched to KVO rate
%//     4 - ...
%
%   postcondition:
%       1 - Alarm sounded and displayed
%       2 - Infusion switched to KVO rate

#include '../model_utils/analysis_utils.pl'.
#include './init-default.pl'.
% --> max dose allows 2.5 boluses per 4 hours

% narrative                     ----------------------------------------------------------------------------------------
or_happens(start_button_pressed,                            60).    % Pre 1

    % wait 4 hours to be in steady state (full maxdose window of basal)

or_happens(patient_bolus_requested,                         300).   % Pre 1
or_happens(patient_bolus_requested,                         340).   % Pre 1

or_happens(patient_bolus_requested,                         380).   % Step 1 -- will cause overdose if not prevented
    % Step 1 -- delivering a bolus at time 380 would exceed the max dose
    ?- initiallyP(vtbi_hard_limit_over_time(MaxDoseVolume, MaxDosePeriod)), 
       total_drug_delivered_over_period(TotalInPeriod, MaxDosePeriod, 380),
       initiallyP(vtbi(BolusVolume)),
       MaxDoseVolume .<. TotalInPeriod + BolusVolume.
    ?- happens(patient_bolus_denied_max_dose,               380).   % Step 1
    ?- happens(max_dose_warning,                            380).   % Step 1 % Step 2 & Post 1

    ?- happens(kvo_delivery_started,                        380).   % Step 3 & Post 2


% check all queries in one:
?-  initiallyP(vtbi_hard_limit_over_time(MaxDoseVolume, MaxDosePeriod)),
    total_drug_delivered_over_period(TotalInPeriod, MaxDosePeriod, 380),
    initiallyP(vtbi(BolusVolume)),
    MaxDoseVolume .<. TotalInPeriod + BolusVolume,
    happens(patient_bolus_denied_max_dose,                  380),
    happens(max_dose_warning,                               380),

    happens(kvo_delivery_started,                           380).

/* --------------------------------- END OF FILE -------------------------------------------------------------------- */