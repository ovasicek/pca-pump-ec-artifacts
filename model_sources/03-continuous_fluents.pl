% ----------------------------------------------------------------------------------------------------------------------
% Its faster to treat continuous fluents as purely continuous (i.e. alway continuous and never discrete)

initiallyR(total_drug_delivered(X)).
initiallyR(total_bolus_drug_delivered(X)).
initiallyR(drug_reservoir_contents(X)).
initiallyR(drug_flow_rate(X)).