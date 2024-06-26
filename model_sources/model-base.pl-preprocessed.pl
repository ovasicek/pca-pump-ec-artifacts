
    can_initiates(any_alarm, alarm_active).
    can_initiates(basal_delivery_started, basal_delivery_enabled).
    can_initiates(clinician_bolus_delivery_started(DurationMinutes), clinician_bolus_delivery_enabled(DurationMinutes)).
    can_initiates(clinician_bolus_delivery_started(DurationMinutes), clinician_bolus_delivery_enabled).
    can_initiates(clinician_bolus_suspended(OriginalDuration), clinician_bolus_is_suspended(OriginalDuration)).
    can_initiates(clinician_bolus_suspended(OriginalDuration), clinician_bolus_is_suspended).
    can_initiates(clinician_bolus_suspended(OriginalDuration), clinician_bolus_suspended_drug_delivered(DeliveredSoFar)).
    can_initiates(empty_reservoir_alarm_EFFECT, alarm_active).
    can_initiates(kvo_delivery_started, kvo_delivery_enabled).
    can_initiates(max_dose_warning, alarm_active).
    can_initiates(patient_bolus_delivery_started, patient_bolus_delivery_enabled).
    can_initiates(pump_started, pump_running).
    can_initiates(pump_stopped, pump_not_running).
    can_terminates(basal_delivery_stopped, basal_delivery_enabled).
    can_terminates(clinician_bolus_delivery_started(OriginalDuration), clinician_bolus_is_suspended(OriginalDuration)).
    can_terminates(clinician_bolus_delivery_started(OriginalDuration), clinician_bolus_is_suspended).
    can_terminates(clinician_bolus_delivery_started(_), clinician_bolus_suspended_drug_delivered(_)).
    can_terminates(clinician_bolus_delivery_stopped, clinician_bolus_delivery_enabled(_)).
    can_terminates(clinician_bolus_delivery_stopped, clinician_bolus_delivery_enabled).
    can_terminates(kvo_delivery_stopped, kvo_delivery_enabled).
    can_terminates(patient_bolus_delivery_stopped, patient_bolus_delivery_enabled).
    can_terminates(patient_bolus_halted, clinician_bolus_is_suspended(OriginalDuration)).
    can_terminates(patient_bolus_halted, clinician_bolus_is_suspended).
    can_terminates(patient_bolus_halted, clinician_bolus_suspended_drug_delivered(_)).
    can_terminates(pump_started, pump_not_running).
    can_terminates(pump_stopped, pump_running).
    can_terminates(stop_button_pressed_valid, alarm_active).
    can_trajectory(basal_delivery_enabled, T1, total_bolus_drug_delivered(TotalBolusDelivered), T2).
    can_trajectory(basal_delivery_enabled, T1, total_drug_delivered(TotalDelivered), T2).
    can_trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, clinician_bolus_drug_delivered(VtbiDrugRes), T2).
    can_trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, clinician_bolus_total_bolus_drug_delivered(TotalBolusDelivered), T2).
    can_trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, clinician_bolus_total_drug_delivered(TotalBolusDelivered), T2).
    can_trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, total_bolus_drug_delivered(TotalBolusDelivered), T2).
    can_trajectory(clinician_bolus_delivery_enabled(DurationMinutes), T1, total_drug_delivered(TotalDelivered), T2).
    can_trajectory(kvo_delivery_enabled, T1, total_bolus_drug_delivered(TotalBolusDelivered), T2).
    can_trajectory(kvo_delivery_enabled, T1, total_drug_delivered(TotalDelivered), T2).
    can_trajectory(patient_bolus_delivery_enabled, T1, patient_bolus_drug_delivered(VtbiDrugRes), T2).
    can_trajectory(patient_bolus_delivery_enabled, T1, total_bolus_drug_delivered(TotalBolusDelivered), T2).
    can_trajectory(patient_bolus_delivery_enabled, T1, total_drug_delivered(TotalDelivered), T2).
    can_trajectory(pump_not_running, T1, total_bolus_drug_delivered(TotalBolusDelivered), T2).
    can_trajectory(pump_not_running, T1, total_drug_delivered(TotalDelivered), T2).
