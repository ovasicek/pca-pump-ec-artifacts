%! a version which does not have any overdose protection measures (or rather they do not do anything usefull, to pretend that they dont exist)


%----------------------------------------------------------------------------------------------------------------------%
% used to deny an requested patient bolus
total_drug_in_max_dose_window_if_the_patient_bolus_would_be_delivered_starting_at_T(T, VtbiLimitTimePeriod, ResTotalDuringVtbiPeriodWithCurrentBolus) :-
    initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
    % deny will not happen when ResTotalDuringVtbiPeriodWithCurrentBolus .=<. VtbiLimit
    % --> return exactly equal so that deny never happens
    ResTotalDuringVtbiPeriodWithCurrentBolus .=. VtbiLimit.

or_happens(max_dose_warning, T) :-
    happens(patient_bolus_denied_max_dose, T).


%----------------------------------------------------------------------------------------------------------------------%
% used to halt an in-progress clinician bolus

or_happens(max_dose_warning, T) :-
    happens(clinician_bolus_halted_max_dose, T).

total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus(_, _, _, _) :-
    0 = 1. % will always fail
