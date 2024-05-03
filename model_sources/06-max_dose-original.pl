%! the original version which allowed basal overdose


%----------------------------------------------------------------------------------------------------------------------%
% used to deny an requested patient bolus
total_drug_in_max_dose_window_if_the_patient_bolus_would_be_delivered_starting_at_T(T, VtbiLimitTimePeriod, ResTotalDuringVtbiPeriodWithCurrentBolus) :-
    % check how much drug was delivered in the VTBI window up till now
    patient_bolus_duration(BolusDuration),
    VtbiLimitTimePeriodMinusBolus .=. VtbiLimitTimePeriod - BolusDuration,  % prediction of VTBI window contents will be added with the bolus
    holdsAt(total_drug_delivered(CurrentTotalDrug), T),                                                                 %! <<< diff
    % below rules is located in (06-total_drug_in_time_window.pl)
    total_drug_in_vtbi_window(T, CurrentTotalDrug, VtbiLimitTimePeriodMinusBolus, TotalDuringVtbiPeriod),               %! <<< diff
    % add portion of VTBI window during the patient bolus
    initiallyP(vtbi(BolusToDeliver)),
    initiallyP(basal_flow_rate(BasalRate)),
    ResTotalDuringVtbiPeriodWithCurrentBolus .=. TotalDuringVtbiPeriod + BolusToDeliver + (BolusDuration * BasalRate).

or_happens(max_dose_warning, T) :-
    happens(patient_bolus_denied_max_dose, T).


%----------------------------------------------------------------------------------------------------------------------%
% used to halt an in-progress clinician bolus

or_happens(max_dose_warning, T) :-
    happens(clinician_bolus_halted_max_dose, T).

total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__windowStartsBeforeT1(T1, T2, VtbiLimit, VtbiLimitTimePeriod) :-
    % below rules is located in (06-total_drug_in_time_window.pl)
    total_drug_in_vtbi_window(T2, Total, VtbiLimitTimePeriod, TotalDuringVtbiPeriod),                              %! <<< diff
    TotalDuringVtbiPeriod .=. VtbiLimit,
    holdsAt(total_drug_delivered(Total), T2, clinician_bolus_delivery_enabled(_)).                                 %! <<< diff
    %%%!spy, holdsAt(total_drug_delivered(Total), T2).                     % this would cause non-termination
total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__windowStartsAfterT1(T1, T2, VtbiLimit, VtbiLimitTimePeriod) :-
    % needs a different implementation of "total_drug_in_vtbi_window"
        % figure out total_drug_delivered at the start of the max dose window
        TstartVtbiPeriod .=. T2 - VtbiLimitTimePeriod,
        max(TstartVtbiPeriod, 0, TstartVtbiPeriodCropped),
        TotalDuringVtbiPeriod .=. Total - TotalDrugAtStartPeriod,
    TotalDuringVtbiPeriod .=. VtbiLimit,
    holdsAt(total_drug_delivered(TotalDrugAtStartPeriod), TstartVtbiPeriodCropped, clinician_bolus_delivery_enabled(_)),%! <<< diff
    holdsAt(total_drug_delivered(Total), T2, clinician_bolus_delivery_enabled(_)).                                 %! <<< diff
    %%%holdsAt(total_drug_delivered(Total), T2).                           % this would cause non-termination
