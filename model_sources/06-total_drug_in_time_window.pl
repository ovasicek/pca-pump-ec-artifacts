total_drug_in_vtbi_window(TEndWindow, TotalAtTEndWindow, VtbiLimitTimePeriod, ResTotalDuringVtbiPeriod) :-
    % figure out total_drug_delivered at the start of the max dose window
    TstartVtbiPeriod .=. TEndWindow - VtbiLimitTimePeriod,
    max(TstartVtbiPeriod, 0, TstartVtbiPeriodCropped),
    holdsAt(total_drug_delivered(TotalDrugAtStartPeriod), TstartVtbiPeriodCropped),
    ResTotalDuringVtbiPeriod .=. TotalAtTEndWindow - TotalDrugAtStartPeriod.

total_drug_in_vtbi_window_assume_basal(TEndWindow, TotalBolusAtTEndWindow, VtbiLimitTimePeriod, ResTotalDuringVtbiPeriod) :-
    initiallyP(basal_flow_rate(BasalRate)),
    % figure out total_bolus_drug_delivered at the start of the max dose window
    TstartVtbiPeriod .=. TEndWindow - VtbiLimitTimePeriod,
    max(TstartVtbiPeriod, 0, TstartVtbiPeriodCropped),
    holdsAt(total_bolus_drug_delivered(TotalBolusDrugAtStartPeriod), TstartVtbiPeriodCropped),
    TotalBolusDuringVtbiPeriod .=. TotalBolusAtTEndWindow - TotalBolusDrugAtStartPeriod,
    % assume a full window of basal delivery
    AssumedBasalDeliveredInVtbiPeriod .=. VtbiLimitTimePeriod * BasalRate,
    % put numbers together
    ResTotalDuringVtbiPeriod .=. TotalBolusDuringVtbiPeriod + AssumedBasalDeliveredInVtbiPeriod.