%! the original version which allowed basal overdose


%----------------------------------------------------------------------------------------------------------------------%
% used to deny an requested patient bolus
shortcut_total_drug_in_max_dose_window_if_the_patient_bolus_would_be_delivered_starting_at_T(T, VtbiLimitTimePeriod, ResTotalDuringVtbiPeriodWithCurrentBolus) :-
    % check how much drug was delivered in the VTBI window up till now
    shortcut_patient_bolus_duration(BolusDuration),
    VtbiLimitTimePeriodMinusBolus .=. VtbiLimitTimePeriod - BolusDuration,  % prediction of VTBI window contents will be added with the bolus
    holdsAt(total_drug_delivered(CurrentTotalDrug), T),                                                                 %! <<< diff
    shortcut_total_drug_in_vtbi_window(T, CurrentTotalDrug, VtbiLimitTimePeriodMinusBolus, TotalDuringVtbiPeriod),      %! <<< diff
    % add portion of VTBI window during the patient bolus
    initiallyP(vtbi(BolusToDeliver)),
    initiallyP(basal_flow_rate(BasalRate)),
    ResTotalDuringVtbiPeriodWithCurrentBolus .=. TotalDuringVtbiPeriod + BolusToDeliver + (BolusDuration * BasalRate).

or_happens(max_dose_warning, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
    happens(patient_bolus_denied_max_dose, T).


%----------------------------------------------------------------------------------------------------------------------%
% used to halt an in-progress clinician bolus
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus(T1, BolusDurationMinutes, T2) :-
    % split based on diference between T1 and T2 -- crucial to avoid non termination
    initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
    T2 .=<. T1 + VtbiLimitTimePeriod,
    % this is the trigger itself
    shortcut_total_drug_in_vtbi_window(T2, TotalBolus, VtbiLimitTimePeriod, TotalDuringVtbiPeriod),        %! <<< diff
    TotalDuringVtbiPeriod .=. VtbiLimit,
    holdsAt(total_drug_delivered(TotalBolus), T2, clinician_bolus_delivery_enabled(_)).                              %! <<< diff
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus(T1, BolusDurationMinutes, T2) :-
    % split based on diference between T1 and T2 -- crucial to avoid non termination
    initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
    T2 .>. T1 + VtbiLimitTimePeriod,
    % this is the trigger itself
    % needs a different implementation of "shortcut_total_drug_in_vtbi_window"
        % figure out total_drug_delivered at the start of the max dose window
        TstartVtbiPeriod .=. T2 - VtbiLimitTimePeriod,
        max(TstartVtbiPeriod, 0, TstartVtbiPeriodCropped),
        TotalDuringVtbiPeriod .=. Total - TotalDrugAtStartPeriod,
    TotalDuringVtbiPeriod .=. VtbiLimit,
    holdsAt(total_drug_delivered(TotalDrugAtStartPeriod), TstartVtbiPeriodCropped, clinician_bolus_delivery_enabled(_)), %! <<< diff
    holdsAt(total_drug_delivered(TotalBolus), T2, clinician_bolus_delivery_enabled(_)).                              %! <<< diff
