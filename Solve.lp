% Written by z5402963 & z5257335 for COMP4418 22T3 Project B.
%
% Flight & Itinerary Planner.


% INPUT ===========================================================================================================

% == CLEANSE INPUT ================================================================================================
:- X = #count { home(A) : home(A) }, X != 1.
:- X = #count { dates(A,B) : dates(A,B) }, X != 1.
:- X = #count { budget(A) : budget(A) }, X != 1.
% ===== Handle ignore_attractions/1. ==============================================================================
ignore_attractions(default).
ignr_atts(yes) :- ignore_attractions(yes).
ignr_atts(no) :- not ignore_attractions(yes).
% ===== If both of {hard, soft} are given, show output for each possibility. ======================================
{ selected_date_preference(T) } = 1 :- date_preference(T).
{ selected_budget_preference(T) } = 1 :- budget_preference(T).
% ===== Select flight_buffer. =====================================================================================
flight_buffer(1). % default value.
selected_flight_buffer(F) :- F = #max { X : flight_buffer(X) }.

% == CITIES =======================================================================================================
city(C,hard) :- home(C).
selected_city(C) :- city(C,hard).
{ selected_city(C) } :- city(C,soft).
:- N = #count { selected_city(C) : selected_city(C) }, N <= 1.
:- city(C,hard), city(C,soft).

% == DATES ========================================================================================================
date_range(START,END) :- selected_date_preference(hard), dates(START,END).
#const window = 5.
date_range(START-window,END+window):- selected_date_preference(soft), dates(START,END).
day(START..END) :- date_range(START,END).


% PROGRAM =========================================================================================================

% == FLIGHTS ======================================================================================================
{ fly(DAY,DEP,ARR) : flight(DEP,ARR,DAY,COST),
                     date_range(START,END), START <= DAY, DAY <= END,
                     selected_city(DEP), selected_city(ARR), DEP != ARR
} = N :- N = #count { selected_city(X) : selected_city(X) }.
% ===== No more than 1 flight per day. ============================================================================
:- day(X), { fly(X,Y,Z) } > 1.
% ===== Cannot fly within X days of each other (flight_buffer). ===================================================
:- fly(A,X,Y), fly(B,Y,Z), home(H), Y != H, selected_flight_buffer(F), (B-A) < F.
% ===== Each 'arrival' marks the city as visited. =================================================================
visited_city(ARR) :- fly(DAY, DEP, ARR).
% ===== Every 'hard' city must be visited. ========================================================================
:- city(X,hard), not visited_city(X).
% ===== Define 'home' for fly, and enforce that the route forms a cycle. ==========================================
:- fly(N,DEP,ARR), N = #min { X : fly(X,Y,Z) }, not home(DEP).
:- fly(N,DEP,ARR), N = #max { X : fly(X,Y,Z) }, not home(ARR).
:- visited_city(Y), { fly(X,Y,Z) } != 1.
:- visited_city(Z), { fly(X,Y,Z) } != 1.
% ===== Enforce increasing order of days along the flight path. ===================================================
:- fly(D1,C1,C2), fly(D2,C2,C3), fly(X,Y,Z), D1 < X, X < D2.
% ===== If dates are hard, first and last date of flight_taken must be on the given dates. ========================
:- N = #min { A : fly(A,B,C) }, selected_date_preference(hard), dates(X,_), N != X.
:- N = #max { A : fly(A,B,C) }, selected_date_preference(hard), dates(_,X), N != X.
% ===== If dates are soft, first and last date of flight_taken must be within the date window. ====================
:- N = #min { A : fly(A,B,C) }, selected_date_preference(soft), dates(X,_), |N-X| > window, fly(N,_,_).
:- N = #max { A : fly(A,B,C) }, selected_date_preference(soft), dates(_,X), |N-X| > window, fly(N,_,_).

% == VISITS / ATTRACTIONS =========================================================================================
{ visit(CITY,ATT) : attraction(CITY,ATT,COST) } :- visited_city(CITY), home(HOME), CITY != HOME, ignr_atts(no).

% == MONETARY COSTS ===============================================================================================
cost(flights,F) :- F = #sum { F_COST : flight(DEP,ARR,DAY,F_COST), fly(DAY,DEP,ARR) }.
cost(attractions,A) :- A = #sum { A_COST : attraction(CITY,ATT,A_COST), visit(CITY,ATT) }, ignr_atts(no).
cost(total,F+A) :- cost(flights,F), cost(attractions,A), ignr_atts(no).
cost(total,F) :- cost(flights,F), ignr_atts(yes).
% ===== Enforce total cost to be less than or equal to hard budget. ===============================================
:- budget(B), selected_budget_preference(hard), cost(total,T), T > B.


% OPTIMIZATIONS ===================================================================================================

% == MINIMISE PENALTIES ===========================================================================================
% ===== Minimise total cost if it is over a soft budget. ==========================================================
penalty(cost, (T-B)/100) :- selected_budget_preference(soft), cost(total,T), budget(B), T > B.
% ===== Minimise date inaccuracies if under budget. ===============================================================
penalty(date, (|X-N|+|Y-M|)) :- selected_date_preference(soft),
                                dates(X,Y),
                                N = #min { A : fly(A,B,C) },
                                M = #max { D : fly(D,E,F) },
                                fly(N,_,_), fly(M,_,_),
                                cost(total,T), budget(L), T <= L.

% == MAXIMISE REWARDS =============================================================================================
% ===== Maximise soft cities. =====================================================================================
penalty(city, -C) :- C = #count { X : selected_city(X), city(X,soft) }.
% ===== Maximise visits if under budget. ==========================================================================
penalty(attraction, -C) :- C = #count { visit(X,Y) : visit(X,Y) }, budget(B), cost(total,T), T <= B, ignr_atts(no).

% == OPTIMISE =====================================================================================================
total_penalty(S) :- S = #sum { T : penalty(_,T) }.
#minimize { X : total_penalty(X) }.


% OUTPUT ==========================================================================================================
#show cost/2.
#show fly/3.
#show visit/2.
#show selected_date_preference/1.
#show selected_budget_preference/1.
