%! a fixed version which uses the information about total_bolus_drug_delivered and assumes a full window of basal delivery
%  other source files needed to be extended with the logic for the total_bolus_drug_delivered(X) fluent

% used to deny an requested patient bolus
shortcut_total_drug_in_max_dose_window_if_the_patient_bolus_would_be_delivered_starting_at_T(T, VtbiLimitTimePeriod, ResTotalDuringVtbiPeriodWithCurrentBolus) :-
    % check how much drug was delivered in the VTBI window up till now
    shortcut_patient_bolus_duration(BolusDuration),
    VtbiLimitTimePeriodMinusBolus .=. VtbiLimitTimePeriod - BolusDuration,  % prediction of VTBI window contents will be added with the bolus
    holdsAt(total_bolus_drug_delivered(CurrentTotalBolusDrug), T),                                                                      %! <<< diff
    shortcut_total_drug_in_vtbi_window_assume_basal(T, CurrentTotalBolusDrug, VtbiLimitTimePeriodMinusBolus, TotalDuringVtbiPeriod),    %! <<< diff
    % add portion of VTBI window during the patient bolus
    initiallyP(vtbi(BolusToDeliver)),
    initiallyP(basal_flow_rate(BasalRate)),
    ResTotalDuringVtbiPeriodWithCurrentBolus .=. TotalDuringVtbiPeriod + BolusToDeliver + (BolusDuration * BasalRate).


%----------------------------------------------------------------------------------------------------------------------%
% used to halt an in-progress clinician bolus
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus(T1, BolusDurationMinutes, T2) :-
    % split based on diference between T1 and T2 -- crucial to avoid non termination
    initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
    T2 .=<. T1 + VtbiLimitTimePeriod,
    % this is the trigger itself
    shortcut_total_drug_in_vtbi_window_assume_basal(T2, TotalBolus, VtbiLimitTimePeriod, TotalDuringVtbiPeriod),        %! <<< diff
    TotalDuringVtbiPeriod .=. VtbiLimit,
    holdsAt(total_bolus_drug_delivered(TotalBolus), T2, clinician_bolus_delivery_enabled(_)).                              %! <<< diff
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus(T1, BolusDurationMinutes, T2) :-
    % split based on diference between T1 and T2 -- crucial to avoid non termination
    initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
    T2 .>. T1 + VtbiLimitTimePeriod,
    % this is the trigger itself
    % needs a different implementation of "shortcut_total_drug_in_vtbi_window_assume_basal"
        initiallyP(basal_flow_rate(BasalRate)),                                                                         %! <<< diff
        % figure out total_bolus_drug_delivered at the start of the max dose window
        TstartVtbiPeriod .=. T2 - VtbiLimitTimePeriod,
        max(TstartVtbiPeriod, 0, TstartVtbiPeriodCropped),
        TotalBolusDuringVtbiPeriod .=. TotalBolus - TotalBolusDrugAtStartPeriod,
        % assume a full window of basal delivery
        AssumedBasalDeliveredInVtbiPeriod .=. VtbiLimitTimePeriod * BasalRate,                                          %! <<< diff
        % put numbers together
        TotalDuringVtbiPeriod .=. TotalBolusDuringVtbiPeriod + AssumedBasalDeliveredInVtbiPeriod,                       %! <<< diff
    TotalDuringVtbiPeriod .=. VtbiLimit,
    holdsAt(total_bolus_drug_delivered(TotalBolusDrugAtStartPeriod), TstartVtbiPeriodCropped, clinician_bolus_delivery_enabled(_)), %! <<< diff
    holdsAt(total_bolus_drug_delivered(TotalBolus), T2, clinician_bolus_delivery_enabled(_)).                              %! <<< diff
