#include './empty_reserv-uc2-base.pl'.

% third run queries  ------------------------------------------------------

?- happens(low_reservoir_warning,                   125).                   
?- happens(empty_reservoir_alarm,                   155).

% query:
?-  holdsAt(total_drug_delivered(X),               1000).
