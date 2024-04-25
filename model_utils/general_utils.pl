% ----------------------------------------------------------------------------------------------------------------------
% utils                         ----------------------------------------------------------------------------------------

min(A,B,A) :- A .=<. B.
min(A,B,B) :- B .<. A.


max(A,B,A) :- A .>=. B.
max(A,B,B) :- B .>. A.


or_not_happensIn(E, T1, T2) :-  
    %T1 .>. 0,
    %T1 .<. T2,
    findall(T, not_happensInFindall(E, T, T1, T2), List),
    outside(List, T1, T2).

    not_happensInFindall(E, T, T1, T2) :- 
        T .>. T1, T .<. T2,
        happens(E, T).

    outside([H|T], T1, T2) :- 
        H .=<. T1,  
        outside(T, T1, T2).
    outside([H|T], T1, T2) :-
        H .>=. T2, 
        outside(T, T1, T2).
    outside([], _, _).


or_not_happens(E, T) :- not_happensInInc(E, T, T).


or_not_happensInInc(E, T1, T2) :-
    findall(T, not_happensInIncFindall(E, T, T1, T2), List),
    outsideInc(List, T1, T2).

    not_happensInIncFindall(E, T, T1, T2) :- 
        T .>=. T1, T .=<. T2,
        happens(E, T).

    outsideInc([H|T], T1, T2) :- 
        H .<. T1,  
        outsideInc(T, T1, T2).
    outsideInc([H|T], T1, T2) :-
        H .>. T2, 
        outsideInc(T, T1, T2).
    outsideInc([], _, _).


not_holdsIn(F, T1, T2) :-  
    not_holdsAt(F, T1),
    not_startedIn(T1, F, T2).

not_holdsIn(F, T1, T2) :-  
    can_terminates(Event, F),
    happens(Event, T1),
    terminates(Event, F, T1),
    not_startedIn(T1, F, T2).

not_holdsAfter(F, T1) :-
    max_time(T2),
    not_holdsAt(F, T1),
    not_startedIn(T1, F, T2).

not_holdsAfter(F, T1) :-  
    max_time(T2),
    can_terminates(Event, F),
    happens(Event, T1),
    terminates(Event, F, T1),
    not_startedIn(T1, F, T2).

holdsIn(F, T1, T2) :-  
    holdsAt(F, T1),
    not_stoppedIn(T1, F, T2).

holdsIn(F, T1, T2) :-  
    can_initiates(Event, F),
    happens(Event, T1),
    initiates(Event, F, T1),
    not_stoppedIn(T1, F, T2).

holdsAfter(F, T1) :-  
    max_time(T2),
    holdsAt(F, T1),
    not_stoppedIn(T1, F, T2).

holdsAfter(F, T1) :-  
    max_time(T2),
    can_initiates(Event, F),
    happens(Event, T1),
    initiates(Event, F, T1),
    not_stoppedIn(T1, F, T2).
