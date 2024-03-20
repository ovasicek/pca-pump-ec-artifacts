
% query overdose (maximum total drug delivered over a period of time exceeded)
total_drug_delivered_over_period(TotalDuringVtbiPeriod, VtbiLimitTimePeriod, T) :- 
    TstartVtbiPeriod .=. T - VtbiLimitTimePeriod,
    max(TstartVtbiPeriod, 0, TstartVtbiPeriodCropped),
    holdsAt(total_drug_delivered(TotalDrugStartPeriod), TstartVtbiPeriodCropped),
    holdsAt(total_drug_delivered(TotalDrugNow), T),
    TotalDuringVtbiPeriod .=. TotalDrugNow - TotalDrugStartPeriod.
vtbi_hard_limit_exceeded(T) :- 
    initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
    total_drug_delivered_over_period(TotalDuringVtbiPeriod, VtbiLimitTimePeriod, T),
    TotalDuringVtbiPeriod .>. VtbiLimit.

vtbi_hard_limit_exceeded_at_T_by_X(T, X) :- 
    initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
    total_drug_delivered_over_period(TotalDuringVtbiPeriod, VtbiLimitTimePeriod, T),
    TotalDuringVtbiPeriod .>. VtbiLimit,
    X .=. TotalDuringVtbiPeriod - VtbiLimit.
