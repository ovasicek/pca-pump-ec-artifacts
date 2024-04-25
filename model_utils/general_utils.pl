% ----------------------------------------------------------------------------------------------------------------------
% utils                         ----------------------------------------------------------------------------------------

min(A,B,A) :- A .=<. B.
min(A,B,B) :- B .<. A.


max(A,B,A) :- A .>=. B.
max(A,B,B) :- B .>. A.


% prove that E did not happen in a time interval (excluding the edges)
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


% prove that E did not happen at T
or_not_happens(E, T) :- not_happensInInc(E, T, T).


% prove that E did not happen in a time interval (including the edges)
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


% prove not_holdsAt over a time interval, if F not_holds at T1
not_holdsIn(F, T1, T2) :-  
    not_holdsAt(F, T1),
    not_startedIn(T1, F, T2).

% prove not_holdsAt over a time interval, if F is terminated at T1
not_holdsIn(F, T1, T2) :-  
    can_terminates(Event, F),
    happens(Event, T1),
    terminates(Event, F, T1),
    not_startedIn(T1, F, T2).


% prove not_holdsAt starting at T1 and after, if F not_holds at T1
not_holdsAfter(F, T1) :-
    max_time(T2),
    not_holdsAt(F, T1),
    not_startedIn(T1, F, T2).

% prove not_holdsAt starting at T1 and after, if F is terminated at T1
not_holdsAfter(F, T1) :-  
    max_time(T2),
    can_terminates(Event, F),
    happens(Event, T1),
    terminates(Event, F, T1),
    not_startedIn(T1, F, T2).


% prove holdsAt over a time interval, if F holds at T1
holdsIn(F, T1, T2) :-  
    holdsAt(F, T1),
    not_stoppedIn(T1, F, T2).

% prove holdsAt over a time interval, if F is initiated at T1
holdsIn(F, T1, T2) :-  
    can_initiates(Event, F),
    happens(Event, T1),
    initiates(Event, F, T1),
    not_stoppedIn(T1, F, T2).


% prove holdsAt starting at T1 and after, if F not_holds at T1
holdsAfter(F, T1) :-  
    max_time(T2),
    holdsAt(F, T1),
    not_stoppedIn(T1, F, T2).

% prove holdsAt starting at T1 and after, if F is initiated at T1
holdsAfter(F, T1) :-  
    max_time(T2),
    can_initiates(Event, F),
    happens(Event, T1),
    initiates(Event, F, T1),
    not_stoppedIn(T1, F, T2).
