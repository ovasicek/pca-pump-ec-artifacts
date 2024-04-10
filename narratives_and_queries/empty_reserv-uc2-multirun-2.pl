#include './empty_reserv-uc2-base.pl'.

% second run query  ---------------------------------------------------------

%#TO FACT HAPPENS# empty_reservoir_alarm
    query :- happens(empty_reservoir_alarm, T).

    ?- query. % runtime: 
