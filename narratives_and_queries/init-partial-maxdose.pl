initiallyP(vtbi_hard_limit_over_time(V, P)) :-      % drug library
    initiallyP(basal_flow_rate(BasalRate)), initiallyP(vtbi(VTBI)),
    NB .=. 2 + (1/2),   % how many boluses to allow
    P .=. 4*60,         % time period of 4 hours
    V .=. (P*BasalRate) + (NB*VTBI).    % max dose is full period of basal + allowed boluses
% --> a maximum of 2.5 boluses allowed per 4hours