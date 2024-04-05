%! a version which does not have any overdose protection measures (or rather they do not do anything usefull, to pretend that they dont exist)

%----------------------------------------------------------------------------------------------------------------------%
% used to deny an requested patient bolus
shortcut_total_drug_in_max_dose_window_if_the_patient_bolus_would_be_delivered_starting_at_T(T, VtbiLimitTimePeriod, ResTotalDuringVtbiPeriodWithCurrentBolus) :-
    initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
    % deny will not happen when ResTotalDuringVtbiPeriodWithCurrentBolus .=<. VtbiLimit
    % --> return exactly equal so that deny never happens
    ResTotalDuringVtbiPeriodWithCurrentBolus .=. VtbiLimit.


%----------------------------------------------------------------------------------------------------------------------%
% used to halt an in-progress clinician bolus
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus(T1, BolusDurationMinutes, T2) :-
    0 = 1. % will always fail
