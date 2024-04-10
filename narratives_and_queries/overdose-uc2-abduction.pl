% Abductive reasoning of overdose on UC2

#include './init-partial-base.pl'.
#include './init-partial-reservoir.pl'.
#include '../../model_utils/analysis_utils.pl'.

% narrative                     ----------------------------------------------------------------------------------------
or_happens(start_button_pressed,                    60).    % UC2
or_happens(patient_bolus_requested,                 120).   % UC2

or_happens(stop_button_pressed,                     6000).  % added for completeness


% query using abduction         ----------------------------------------------------------------------------------------

    % define an abducible (commented out because it will be defined by the script)
    %#abducible abducible_initiallyP_vtbi_hard_limit_V_P(V, P).
    %#show abducible_initiallyP_vtbi_hard_limit_V_P/2.

    % define max dose parameter values using the abducible
    % - this is a way to restrict abduction values
    initiallyP(vtbi_hard_limit_over_time(V, P)) :-
        shortcut_patient_bolus_duration(BolusDuration), initiallyP(basal_flow_rate(BasalRate)), initiallyP(vtbi(VTBI)),
        abducible_initiallyP_vtbi_hard_limit_V_P(V, P),
        N .=. 0,                            % at least how many boluses to allow
        P .>. BolusDuration,                % time period must be longer than bolus duration
        V .>=. (P * BasalRate) + (N*VTBI),  % volume is at least a full period of basal plus N boluses
        sample(V,P).                        % used for automating abduction of less parameters
    sample(X1,X2) :- not conf_ENABLED_SAMPLING.

    ?-  T .>. 60, T .<. 6000,               % only consider times when the PCA pump was running
        X .>. 0, vtbi_hard_limit_exceeded_at_T_by_X(T,X). % look for times with non-zero overdose  

/* --------------------------------- END OF FILE -------------------------------------------------------------------- */