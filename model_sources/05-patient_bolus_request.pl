% ----------------------------------------------------------------------------------------------------------------------
% X5.2.0(1) -- starting or denying a patient requested bolus

    % if requested, will not exceed limit, and is not too soon; then start bolus 
    or_happens(patient_bolus_delivery_started, T) :- happens(patient_bolus_requested_valid, T),
        not_happens(patient_bolus_denied_too_soon, T),
        not__happens(patient_bolus_denied_max_dose, T). %! TODO needed instead of not_happens when using abduction (bc findall look in all worlds)

    % helper event, two reasons for denying a patient bolus
    or_happens(patient_bolus_denied, T) :- happens(patient_bolus_denied_too_soon, T).
    or_happens(patient_bolus_denied, T) :- happens(patient_bolus_denied_max_dose, T).

    % R5.2.0(3) -- if its too soon since last bolus; then deny bolus
    or_happens(patient_bolus_denied_too_soon, T) :-
        happens(patient_bolus_requested_valid, T),
        initiallyP(min_t_between_patient_bolus(MinTimeBetween)),
        TLastBolus .>. 0,
        TLastBolus .<. T,
        TLastBolus .>. T - MinTimeBetween,
        holdsAt(patient_bolus_delivery_enabled, TLastBolus).

    % R5.2.0(5) -- if hard limit would be exceeded; then deny bolus, and issue a warning, and switch to KVO
    or_happens(patient_bolus_denied_max_dose, T) :- happens(patient_bolus_requested_valid, T),
        initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
        shortcut_total_drug_in_max_dose_window_if_the_patient_bolus_would_be_delivered_starting_at_T(T, VtbiLimitTimePeriod, TotalDuringVtbiPeriodWithCurrentBolus),
        % trigger this rule if the VTBI limit was exceeded
        TotalDuringVtbiPeriodWithCurrentBolus .>. VtbiLimit.
    or_not__happens(patient_bolus_denied_max_dose, T) :- happens(patient_bolus_requested_valid, T),
        initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
        shortcut_total_drug_in_max_dose_window_if_the_patient_bolus_would_be_delivered_starting_at_T(T, VtbiLimitTimePeriod, TotalDuringVtbiPeriodWithCurrentBolus),
        % trigger this rule if the VTBI limit was NOT exceeded
        TotalDuringVtbiPeriodWithCurrentBolus .=<. VtbiLimit.

    or_happens(max_dose_warning, T) :- happens(patient_bolus_denied_max_dose, T).
    or_happens(basal_delivery_stopped, T) :- happens(patient_bolus_denied_max_dose, T),
        holdsAt(basal_delivery_enabled, T).

