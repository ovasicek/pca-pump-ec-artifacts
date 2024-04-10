% EC13: Maximum Safe Dose -- during basal
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

#include '../../model_utils/analysis_utils.pl'.
#include './init-default.pl'.
% --> max dose allows 2.5 boluses per 4 hours

% narrative                     ----------------------------------------------------------------------------------------
or_happens(start_button_pressed,                            60).    % Pre 1

    % do NOT wait the 4 hours (maxdose window will not be full of basal, yet) --> max dose will be reached in basal

or_happens(patient_bolus_requested,                         100).   % Pre 1
or_happens(patient_bolus_requested,                         140).   % Pre 1

or_happens(patient_bolus_requested,                         180).   % Step 1 -- will cause overdose if not prevented
    % Step 1 -- max dose will be reached at 295 during basal delivery
    ?- initiallyP(vtbi_hard_limit_over_time(MaxDoseVolume, MaxDosePeriod)), 
       total_drug_delivered_over_period(TotalInPeriod, MaxDosePeriod, 295),
       TotalInPeriod .=. MaxDoseVolume.


    ?- happens(max_dose_warning,                            T).     % Step 1 % Step 2 & Post 1

    ?- happens(kvo_delivery_started,                        T).     % Step 3 & Post 2


% check all queries in one:
?-  happens(max_dose_warning,                               T),
    happens(kvo_delivery_started,                           T).

/* --------------------------------- END OF FILE -------------------------------------------------------------------- */


%//    ?- initiallyP(vtbi_hard_limit_over_time(MaxDoseVolume, MaxDosePeriod)), 
%//       total_drug_delivered_over_period(TotalInPeriod, MaxDosePeriod, 295),
%//       TotalInPeriod .>. MaxDoseVolume.
%//
%//    ?- vtbi_hard_limit_exceeded(T).
%//
%//    ?- initiallyP(vtbi(VTBI)), X .=. VTBI / 2, vtbi_hard_limit_exceeded_at_T_by_X(T, X).