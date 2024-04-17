query_check_narrative_fluents :- 
    initiallyP(pump_flow_rate_max_MlperHour(PumpFlowMax)), PumpFlowMax .>. 0,
    initiallyP(basal_flow_rate_min_MlperHour(BasalFlowMin)), BasalFlowMin .>. 0,
    initiallyP(basal_flow_rate_max_MlperHour(BasalFlowMax)), BasalFlowMax .>. 0,
    initiallyP(basal_flow_rate_MlperHour(BasalFlow)), BasalFlow .>=. BasalFlowMin, BasalFlow .=<. BasalFlowMax,
    initiallyP(kvo_flow_rate_MlperHour(KvoFlow)), KvoFlow .=. 1,
    initiallyP(patient_bolus_flow_rate_MlperHour(PatientBolusFlow)), PatientBolusFlow .>. 0,
    initiallyP(min_t_between_patient_bolus(PatientBolusMinT)), PatientBolusMinT .>. 0,
    initiallyP(vtbi_hard_max(VtbiMax)), VtbiMax .>. 0,
    initiallyP(vtbi(VTBI)), VTBI .>. 0, BasalFlowMax .=<. VtbiMax,
    initiallyP(vtbi_hard_limit_over_time(MaxDose, MaxDosePeriod)), MaxDose .>. 0, MaxDosePeriod .>. 0,
    initiallyP(initial_drug_reservoir_contents(DrugReservoir)), DrugReservoir .>. 0,
    initiallyP(basal_flow_rate(BasalRate)), MaxDose .>=. BasalRate * MaxDosePeriod,
    shortcut_patient_bolus_duration(BolusDuration), MaxDosePeriod .>. BolusDuration,
    initiallyP(initial_total_drug_delivered(X)), X .=. 0,
    initiallyP(initial_total_bolus_drug_delivered(X)), X .=. 0,
    initiallyP(initial_drug_flow_rate(X)), X .=. 0.

% OR alternative using "optional-check_inputs.pl"
query_check_narrative_fluents_via_restrictions :-
    initiallyP(pump_flow_rate_max_MlperHour(PumpFlowMax)),
    initiallyP(basal_flow_rate_min_MlperHour(BasalFlowMin)),
    initiallyP(basal_flow_rate_max_MlperHour(BasalFlowMax)),
    initiallyP(basal_flow_rate_MlperHour(BasalFlow)),
    initiallyP(kvo_flow_rate_MlperHour(KvoFlow)),
    initiallyP(patient_bolus_flow_rate_MlperHour(PatientBolusFlow)),
    initiallyP(min_t_between_patient_bolus(PatientBolusMinT)),
    initiallyP(vtbi(VtbiMax)),
    initiallyP(vtbi_hard_max(VTBI)),
    initiallyP(vtbi_hard_limit_over_time(MaxDose, MaxDosePeriod)),
    initiallyP(initial_drug_reservoir_contents(DrugReservoir)),
    initiallyP(initial_total_drug_delivered(X)),
    initiallyP(initial_total_bolus_drug_delivered(X)),
    initiallyP(initial_drug_flow_rate(X)).
