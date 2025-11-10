/**
  Chess "mate in three" domain.

  - Domain: small 4x4 chessboard, specific pieces
  - Goal: achieve checkmate(black) with white_moves =< 3
*/

:- dynamic controller/1.
:- discontiguous
    fun_fluent/1,
    rel_fluent/1,
    ask_execute/2,
    proc/2.

% There is nothing to do caching on (required becase cache/1 is static)
cache(_) :- fail.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Interface to the outside world via read and write
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

execute(A, SR) :- ask_execute(A, SR).
exog_occurs(_) :- fail.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TYPES, PIECES, SQUARES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

color(white).
color(black).

piece(wK).  % white king
piece(wN).  % white knight
piece(wR).  % white rook
piece(wQ).  % white rook
piece(bK).  % black king
piece(bR).  % black rook
piece(bP1). % black pawns
piece(bP2). % -----------
piece(bP3). % -----------

square(a1). square(a2). square(a3). square(a4).
square(b1). square(b2). square(b3). square(b4).
square(c1). square(c2). square(c3). square(c4).
square(d1). square(d2). square(d3). square(d4).

% Static piece identity & ownership (do NOT change over time)
is_king(wK).
is_king(bK).

is_knight(wN).
is_queen(wQ).

is_rook(wR).
is_rook(bR).

is_pawn(bP1).
is_pawn(bP2).
is_pawn(bP2).

belongs_to(wN, white).
belongs_to(wK, white).
belongs_to(bK, black).
belongs_to(bR, black).
belongs_to(bP1, black).
belongs_to(bP2, black).
belongs_to(bP3, black).
belongs_to(wQ, white).
belongs_to(wR, white).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATIC BOARD RELATIONS (same_file, same_rank, same_diagonal,
% between, adjacent, knight_move)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% same_file relations
same_file(a1,a2). same_file(a1,a3). same_file(a1,a4).
same_file(a2,a1). same_file(a2,a3). same_file(a2,a4).
same_file(a3,a1). same_file(a3,a2). same_file(a3,a4).
same_file(a4,a1). same_file(a4,a2). same_file(a4,a3).

same_file(b1,b2). same_file(b1,b3). same_file(b1,b4).
same_file(b2,b1). same_file(b2,b3). same_file(b2,b4).
same_file(b3,b1). same_file(b3,b2). same_file(b3,b4).
same_file(b4,b1). same_file(b4,b2). same_file(b4,b3).

same_file(c1,c2). same_file(c1,c3). same_file(c1,c4).
same_file(c2,c1). same_file(c2,c3). same_file(c2,c4).
same_file(c3,c1). same_file(c3,c2). same_file(c3,c4).
same_file(c4,c1). same_file(c4,c2). same_file(c4,c3).

same_file(d1,d2). same_file(d1,d3). same_file(d1,d4).
same_file(d2,d1). same_file(d2,d3). same_file(d2,d4).
same_file(d3,d1). same_file(d3,d2). same_file(d3,d4).
same_file(d4,d1). same_file(d4,d2). same_file(d4,d3).

% same_rank relations
same_rank(a1,b1). same_rank(a1,c1). same_rank(a1,d1).
same_rank(a2,b2). same_rank(a2,c2). same_rank(a2,d2).
same_rank(a3,b3). same_rank(a3,c3). same_rank(a3,d3).
same_rank(a4,b4). same_rank(a4,c4). same_rank(a4,d4).

same_rank(b1,a1). same_rank(b1,c1). same_rank(b1,d1).
same_rank(b2,a2). same_rank(b2,c2). same_rank(b2,d2).
same_rank(b3,a3). same_rank(b3,c3). same_rank(b3,d3).
same_rank(b4,a4). same_rank(b4,c4). same_rank(b4,d4).

same_rank(c1,a1). same_rank(c1,b1). same_rank(c1,d1).
same_rank(c2,a2). same_rank(c2,b2). same_rank(c2,d2).
same_rank(c3,a3). same_rank(c3,b3). same_rank(c3,d3).
same_rank(c4,a4). same_rank(c4,b4). same_rank(c4,d4).

same_rank(d1,a1). same_rank(d1,b1). same_rank(d1,c1).
same_rank(d2,a2). same_rank(d2,b2). same_rank(d2,c2).
same_rank(d3,a3). same_rank(d3,b3). same_rank(d3,c3).
same_rank(d4,a4). same_rank(d4,b4). same_rank(d4,c4).

% same_diagonal relations
same_diagonal(a1,b2). same_diagonal(a1,c3). same_diagonal(a1,d4).
same_diagonal(a2,b1). same_diagonal(a2,b3). same_diagonal(a2,c4).
same_diagonal(a3,b2). same_diagonal(a3,b4). same_diagonal(a3,c1).
same_diagonal(a4,b3). same_diagonal(a4,c2). same_diagonal(a4,d1).

same_diagonal(b1,a2). same_diagonal(b1,c2). same_diagonal(b1,d3).
same_diagonal(b2,a1). same_diagonal(b2,a3). same_diagonal(b2,c1).
same_diagonal(b2,c3). same_diagonal(b2,d4).
same_diagonal(b3,a2). same_diagonal(b3,a4). same_diagonal(b3,c2).
same_diagonal(b3,d1). same_diagonal(b3,c4).
same_diagonal(b4,a3). same_diagonal(b4,c3). same_diagonal(b4,d2).

same_diagonal(c1,b2). same_diagonal(c1,a3). same_diagonal(c1,d2).
same_diagonal(c2,b1). same_diagonal(c2,d1). same_diagonal(c2,b3).
same_diagonal(c2,a4). same_diagonal(c2,d3).
same_diagonal(c3,b2). same_diagonal(c3,b4). same_diagonal(c3,d2).
same_diagonal(c3,d4). same_diagonal(c3,a1).
same_diagonal(c4,b3). same_diagonal(c4,a2). same_diagonal(c4,d3).

same_diagonal(d1,c2). same_diagonal(d1,b3). same_diagonal(d1,a4).
same_diagonal(d2,c1). same_diagonal(d2,c3). same_diagonal(d2,b4).
same_diagonal(d3,c2). same_diagonal(d3,b1). same_diagonal(d3,c4).
same_diagonal(d4,c3). same_diagonal(d4,b2). same_diagonal(d4,a1).

% adjacent relations
adjacent(a1,a2). adjacent(a1,b1). adjacent(a1,b2).
adjacent(a2,a1). adjacent(a2,a3). adjacent(a2,b1). adjacent(a2,b2). adjacent(a2,b3).
adjacent(a3,a2). adjacent(a3,a4). adjacent(a3,b2). adjacent(a3,b3). adjacent(a3,b4).
adjacent(a4,a3). adjacent(a4,b3). adjacent(a4,b4).

adjacent(b1,a1). adjacent(b1,a2). adjacent(b1,b2). adjacent(b1,c1). adjacent(b1,c2).
adjacent(b2,a1). adjacent(b2,a2). adjacent(b2,a3). adjacent(b2,b1). adjacent(b2,b3).
adjacent(b2,c1). adjacent(b2,c2). adjacent(b2,c3).
adjacent(b3,a2). adjacent(b3,a3). adjacent(b3,a4). adjacent(b3,b2). adjacent(b3,b4).
adjacent(b3,c2). adjacent(b3,c3). adjacent(b3,c4).
adjacent(b4,a3). adjacent(b4,a4). adjacent(b4,b3). adjacent(b4,c3). adjacent(b4,c4).

adjacent(c1,b1). adjacent(c1,b2). adjacent(c1,c2). adjacent(c1,d1). adjacent(c1,d2).
adjacent(c2,b1). adjacent(c2,b2). adjacent(c2,b3). adjacent(c2,c1). adjacent(c2,c3).
adjacent(c2,d1). adjacent(c2,d2). adjacent(c2,d3).
adjacent(c3,b2). adjacent(c3,b3). adjacent(c3,b4). adjacent(c3,c2). adjacent(c3,c4).
adjacent(c3,d2). adjacent(c3,d3). adjacent(c3,d4).
adjacent(c4,b3). adjacent(c4,b4). adjacent(c4,c3). adjacent(c4,d3). adjacent(c4,d4).

adjacent(d1,c1). adjacent(d1,c2). adjacent(d1,d2).
adjacent(d2,c1). adjacent(d2,c2). adjacent(d2,c3). adjacent(d2,d1). adjacent(d2,d3).
adjacent(d3,c2). adjacent(d3,c3). adjacent(d3,c4). adjacent(d3,d2). adjacent(d3,d4).
adjacent(d4,c3). adjacent(d4,c4). adjacent(d4,d3).

% between relations

% between same_file (upward)
between(a1,a3,a2). between(a1,a4,a2). between(a1,a4,a3). between(a2,a4,a3).
between(b1,b3,b2). between(b1,b4,b2). between(b1,b4,b3). between(b2,b4,b3).
between(c1,c3,c2). between(c1,c4,c2). between(c1,c4,c3). between(c2,c4,c3).
between(d1,d3,d2). between(d1,d4,d2). between(d1,d4,d3). between(d2,d4,d3).

% between same_file (downward)
between(a3,a1,a2). between(a4,a1,a2). between(a4,a1,a3). between(a4,a2,a3).
between(b3,b1,b2). between(b4,b1,b2). between(b4,b1,b3). between(b4,b2,b3).
between(c3,c1,c2). between(c4,c1,c2). between(c4,c1,c3). between(c4,c2,c3).
between(d3,d1,d2). between(d4,d1,d2). between(d4,d1,d3). between(d4,d2,d3).

% between same_rank (left)
between(a1,c1,b1). between(a1,d1,b1). between(a1,d1,c1). between(b1,d1,c1).
between(a2,c2,b2). between(a2,d2,b2). between(a2,d2,c2). between(b2,d2,c2).
between(a3,c3,b3). between(a3,d3,b3). between(a3,d3,c3). between(b3,d3,c3).
between(a4,c4,b4). between(a4,d4,b4). between(a4,d4,c4). between(b4,d4,c4).

% between same_rank (right)
between(c1,a1,b1). between(d1,a1,b1). between(d1,a1,c1). between(d1,b1,c1).
between(c2,a2,b2). between(d2,a2,b2). between(d2,a2,c2). between(d2,b2,c2).
between(c3,a3,b3). between(d3,a3,b3). between(d3,a3,c3). between(d3,b3,c3).
between(c4,a4,b4). between(d4,a4,b4). between(d4,a4,c4). between(d4,b4,c4).

% between same_diagonal
between(a1,c3,b2). between(a1,d4,b2). between(a1,d4,c3).
between(c3,a1,b2). between(d4,a1,b2). between(d4,a1,c3).
between(a2,c4,b3). between(c4,a2,b3).
between(a3,c1,b2). between(c1,a3,b2).
between(a4,c2,b3). between(a4,d1,b3). between(a4,d1,c2).
between(c2,a4,b3). between(d1,a4,b3). between(d1,a4,c2).

between(b1,d3,c2). between(d3,b1,c2).
between(b2,d4,c3). between(d4,b2,c3).
between(b3,d1,c2). between(d1,b3,c2).
between(b4,d2,c3). between(d2,b4,c3).

between(c1,a3,b2). between(a3,c1,b2).
between(c2,a4,b3). between(a4,c2,b3).
between(c3,a1,b2). between(a1,c3,b2).
between(c4,a2,b3). between(a2,c4,b3).

% knight_move relations
knight_move(a1,b3). knight_move(a1,c2).
knight_move(a2,c1). knight_move(a2,c3). knight_move(a2,b4).
knight_move(a3,c2). knight_move(a3,c4). knight_move(a3,b1).
knight_move(a4,b2). knight_move(a4,c3).
knight_move(b1,a3). knight_move(b1,c3). knight_move(b1,d2).
knight_move(b2,a4). knight_move(b2,c4). knight_move(b2,d1). knight_move(b2,d3).
knight_move(b3,a1). knight_move(b3,c1). knight_move(b3,d2). knight_move(b3,d4).
knight_move(b4,a2). knight_move(b4,c2).
knight_move(c1,a2). knight_move(c1,b3). knight_move(c1,d3).
knight_move(c2,a1). knight_move(c2,a3). knight_move(c2,b4). knight_move(c2,d4).
knight_move(c3,a2). knight_move(c3,a4). knight_move(c3,b1). knight_move(c3,d1).
knight_move(c4,b2). knight_move(c4,d2).
knight_move(d1,b2). knight_move(d1,c3).
knight_move(d2,b1). knight_move(d2,b3). knight_move(d2,c4).
knight_move(d3,b2). knight_move(d3,c1). knight_move(d3,c4).
knight_move(d4,b3). knight_move(d4,c2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ACTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Attacked squares update
prim_action(update_attack_status_knight(P,S)) :- piece(P), square(S).
prim_action(update_attack_status_king(P,S))   :- piece(P), square(S).
prim_action(update_attack_status_rook(P,S))   :- piece(P), square(S).
prim_action(update_attack_status_queen(P,S))   :- piece(P), square(S).

% White moves
prim_action(move_white_knight(P,From,To,K,Kpos)) :-
    piece(P), piece(K), square(From), square(To), square(Kpos).

prim_action(move_white_king(P,From,To,K,Kpos))   :-
    piece(P), piece(K), square(From), square(To), square(Kpos).

prim_action(move_white_rook_vertically(P,From,To,K,Kpos)) :-
    piece(P), piece(K), square(From), square(To), square(Kpos).

prim_action(move_white_rook_horizontally(P,From,To,K,Kpos)) :-
    piece(P), piece(K), square(From), square(To), square(Kpos).

prim_action(move_queen_diagonally(P,From,To,K,Kpos)) :-
    piece(P), piece(K), square(From), square(To), square(Kpos).

prim_action(move_queen_vertically(P,From,To,K,Kpos)) :-
    piece(P), piece(K), square(From), square(To), square(Kpos).

prim_action(move_queen_horizontally(P,From,To,K,Kpos)) :-
    piece(P), piece(K), square(From), square(To), square(Kpos).

% Black moves / capture
prim_action(move_black(P,From,To)) :-
    piece(P), square(From), square(To).
prim_action(black_capture(P,From,To,Att)) :-
    piece(P), piece(Att), square(From), square(To).

% Declare checkmate
prim_action(declare_checkmate(C,P,Kpos)) :-
    color(C), piece(P), square(Kpos).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FLUENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% All boolean fluents take values true/false
rel_fluent(white_turn).
rel_fluent(black_turn).

rel_fluent(to_update_king).
rel_fluent(to_update_knight).
rel_fluent(to_update_rook).
rel_fluent(to_update_queen).

rel_fluent(king_in_check(C))  :- color(C).
rel_fluent(checkmate(C))      :- color(C).

rel_fluent(at(P,S))           :- piece(P), square(S).
rel_fluent(occupied_by_color(S,C)) :- square(S), color(C).
rel_fluent(attacked_by(P,S))  :- piece(P), square(S).

% Numeric fluent: number of white moves done
fun_fluent(white_moves).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CAUSAL LAWS  causes_val(Action, FluentTerm, NewVal, Condition)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%  UPDATE ATTACK STATUS KNIGHT  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% For all squares Att such that knight_move(S,Att),
% mark attacked_by(P,Att) = true when we do the update.
causes_val(update_attack_status_knight(P,S),
           attacked_by(P,Att),
           true,
           knight_move(S,Att)).

% After updating, to_update_knight becomes false
causes_val(update_attack_status_knight(_P,_S),
           to_update_knight,
           false,
           true).

%%%%%%%%%%%%%  UPDATE ATTACK STATUS KING  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% King attacks adjacent squares
causes_val(update_attack_status_king(P,S),
           attacked_by(P,Att),
           true,
           adjacent(S,Att)).

causes_val(update_attack_status_king(_P,_S),
           to_update_king,
           false,
           true).

%%%%%%%%%%%%%  UPDATE ATTACK STATUS ROOK  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

causes_val(update_attack_status_rook(P,S),
           attacked_by(P,Att),
           true,
           and(
             or(same_rank(S,Att), same_file(S,Att)),
             neg(
               some(mid,
                 some(blocker,
                   and(
                     neg(and(is_king(blocker), belongs_to(blocker,black))),
                     and(
                     between(S,Att,mid),
                     at(blocker,mid) = true
                   )
                 ))
             ))
           )).

causes_val(update_attack_status_rook(_P,_S),
           to_update_rook,
           false,
           true).


%%%%%%%%%%%%%  UPDATE ATTACK STATUS QUEEN  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

causes_val(update_attack_status_queen(P,S),
           attacked_by(P,Att),
           true,
           and(
             or(
               same_rank(S,Att),
               or(same_file(S,Att), same_diagonal(S,Att))
             ),
             neg(
               some(mid,
                 some(blocker,
                   and(
                     neg(and(is_king(blocker), belongs_to(blocker,black))),
                     and(
                     between(S,Att,mid),
                     at(blocker,mid) = true
                   )
                 ))
             ))
           )).

causes_val(update_attack_status_queen(_P,_S),
           to_update_queen,
           false,
           true).

%%%%%%%%%%%%%  MOVE WHITE KNIGHT  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Turn change
causes_val(move_white_knight(_P,_F,_T,_K,_Kpos),
           white_turn, false, true).
causes_val(move_white_knight(_P,_F,_T,_K,_Kpos),
           black_turn, true,  true).

% Move the piece: at(P,From)=false, at(P,To)=true
causes_val(move_white_knight(P,From,_To,_K,_Kpos),
           at(P,From),
           false,
           true).

causes_val(move_white_knight(P,_From,To,_K,_Kpos),
           at(P,To),
           true,
           true).

% Update occupation for white
causes_val(move_white_knight(_P,From,_To,_K,_Kpos),
           occupied_by_color(From,white),
           false,
           true).

causes_val(move_white_knight(_P,_From,To,_K,_Kpos),
           occupied_by_color(To,white),
           true,
           true).

% capture detection: if occupied_by_color(To,black) was true, set it to false
causes_val(move_white_knight(_P,_From,To,_K,_Kpos),
           occupied_by_color(To,black),
           false,
           occupied_by_color(To,black) = true).

% remove any black piece at To
causes_val(move_white_knight(_P,_From,To,_K,_Kpos),
           at(B,To),
           false,
           and(at(B,To) = true, belongs_to(B,black))).

% check detection: if the new knight square attacks black king’s square
causes_val(move_white_knight(_P,_From,To,_K,Kpos),
           king_in_check(black),
           true,
           knight_move(To,Kpos)).

% remove all attacked_by squares of this knight (reset attacked squares for moved piece)
causes_val(move_white_knight(P,_From,_To,_K,_Kpos),
           attacked_by(P,S),
           false,
           true).

% mark that we must recompute knight attacks
causes_val(move_white_knight(_P,_F,_T,_K,_Kpos),
           to_update_knight,
           true,
           true).

% Increment white_moves: white_moves' = white_moves + 1
causes_val(move_white_knight(_P,_F,_T,_K,_Kpos),
           white_moves,
           N,
           N is white_moves + 1).

%%%%%%%%%%%%%  MOVE WHITE KING  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% turn change
causes_val(move_white_king(_P,_F,_T,_K,_Kpos),
           white_turn, false, true).
causes_val(move_white_king(_P,_F,_T,_K,_Kpos),
           black_turn, true,  true).

% position
causes_val(move_white_king(P,From,_To,_K,_Kpos),
           at(P,From),
           false,
           true).

causes_val(move_white_king(P,_From,To,_K,_Kpos),
           at(P,To),
           true,
           true).

% occupation (white)
causes_val(move_white_king(_P,From,_To,_K,_Kpos),
           occupied_by_color(From,white),
           false,
           true).

causes_val(move_white_king(_P,_From,To,_K,_Kpos),
           occupied_by_color(To,white),
           true,
           true).

% capture detection: if occupied_by_color(To,black) was true, set it to false
causes_val(move_white_king(_P,_From,To,_K,_Kpos),
           occupied_by_color(To,black),
           false,
           occupied_by_color(To,black) = true).

% remove any black piece at To
causes_val(move_white_king(_P,_From,To,_K,_Kpos),
           at(B,To),
           false,
           and(at(B,To) = true, belongs_to(B,black))).

% Remove all attacked_by squares of piece P (reset attacked squares for moved king)
causes_val(move_white_king(P,_From,_To,_K,_Kpos),
           attacked_by(P,S),
           false,
           true) :- square(S).

% mark we must recompute king attacks
causes_val(move_white_king(_P,_From,_To,_K,_Kpos),
           to_update_king,
           true,
           true).

% Increment white_moves: white_moves' = white_moves + 1
causes_val(move_white_king(_P,_F,_T,_K,_Kpos),
           white_moves,
           N,
           N is white_moves + 1).

%%%%%%%%%%%%%  MOVE WHITE ROOK VERTICALLY  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% turn change, position, occupation, capture, ecc. 
causes_val(move_white_rook_vertically(_P,_F,_T,_K,_Kpos),
           white_turn, false, true).
causes_val(move_white_rook_vertically(_P,_F,_T,_K,_Kpos),
           black_turn, true,  true).

causes_val(move_white_rook_vertically(P,From,_To,_K,_Kpos),
           at(P,From),
           false,
           true).

causes_val(move_white_rook_vertically(P,_From,To,_K,_Kpos),
           at(P,To),
           true,
           true).

causes_val(move_white_rook_vertically(_P,From,_To,_K,_Kpos),
           occupied_by_color(From,white),
           false,
           true).

causes_val(move_white_rook_vertically(_P,_From,To,_K,_Kpos),
           occupied_by_color(To,white),
           true,
           true).

causes_val(move_white_rook_vertically(_P,_From,To,_K,_Kpos),
           occupied_by_color(To,black),
           false,
           occupied_by_color(To,black) = true).

causes_val(move_white_rook_vertically(_P,_From,To,_K,_Kpos),
           at(B,To),
           false,
           and(at(B,To) = true, belongs_to(B,black))).

% check detection (rook lines)
causes_val(move_white_rook_vertically(_P,_From,To,_K,Kpos),
           king_in_check(black),
           true,
           and(
             or(same_file(To,Kpos), same_rank(To,Kpos)),
             neg(
               some(mid,
                 some(blocker,
                   and(
                     between(To,Kpos,mid),
                     at(blocker,mid) = true
                   )
                 ))
             )
           )).

% reset attacked_by for this rook
causes_val(move_white_rook_vertically(P,_From,_To,_K,_Kpos),
           attacked_by(P,S),
           false,
           true) :- square(S).

% mark rook attacks must be recomputed
causes_val(move_white_rook_vertically(_P,_F,_T,_K,_Kpos),
           to_update_rook,
           true,
           true).

% increment counter
causes_val(move_white_rook_vertically(_P,_F,_T,_K,_Kpos),
           white_moves,
           N,
           N is white_moves + 1).

%%%%%%%%%%%%%  MOVE WHITE ROOK HORIZONTALLY  %%%%%%%%%%%%%%%%%%%%%%%%%%%

causes_val(move_white_rook_horizontally(_P,_F,_T,_K,_Kpos),
           white_turn, false, true).
causes_val(move_white_rook_horizontally(_P,_F,_T,_K,_Kpos),
           black_turn, true,  true).

causes_val(move_white_rook_horizontally(P,From,_To,_K,_Kpos),
           at(P,From),
           false,
           true).

causes_val(move_white_rook_horizontally(P,_From,To,_K,_Kpos),
           at(P,To),
           true,
           true).

causes_val(move_white_rook_horizontally(_P,From,_To,_K,_Kpos),
           occupied_by_color(From,white),
           false,
           true).

causes_val(move_white_rook_horizontally(_P,_From,To,_K,_Kpos),
           occupied_by_color(To,white),
           true,
           true).

causes_val(move_white_rook_horizontally(_P,_From,To,_K,_Kpos),
           occupied_by_color(To,black),
           false,
           occupied_by_color(To,black) = true).

causes_val(move_white_rook_horizontally(_P,_From,To,_K,_Kpos),
           at(B,To),
           false,
           and(at(B,To) = true, belongs_to(B,black))).

causes_val(move_white_rook_horizontally(_P,_From,To,_K,Kpos),
           king_in_check(black),
           true,
           and(
             or(same_file(To,Kpos), same_rank(To,Kpos)),
             neg(
               some(mid,
                 some(blocker,
                   and(
                     between(To,Kpos,mid),
                     at(blocker,mid) = true
                   )
                 ))
             )
           )).

causes_val(move_white_rook_horizontally(P,_From,_To,_K,_Kpos),
           attacked_by(P,S),
           false,
           true) :- square(S).

causes_val(move_white_rook_horizontally(_P,_F,_T,_K,_Kpos),
           to_update_rook,
           true,
           true).

causes_val(move_white_rook_horizontally(_P,_F,_T,_K,_Kpos),
           white_moves,
           N,
           N is white_moves + 1).

%%%%%%%%%%%%%  MOVE WHITE QUEEN DIAGONALLY  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% turn change
causes_val(move_queen_diagonally(_P,_F,_T,_K,_Kpos),
           white_turn, false, true).
causes_val(move_queen_diagonally(_P,_F,_T,_K,_Kpos),
           black_turn, true,  true).

% position
causes_val(move_queen_diagonally(P,From,_To,_K,_Kpos),
           at(P,From),
           false,
           true).

causes_val(move_queen_diagonally(P,_From,To,_K,_Kpos),
           at(P,To),
           true,
           true).

% occupation (white)
causes_val(move_queen_diagonally(_P,From,_To,_K,_Kpos),
           occupied_by_color(From,white),
           false,
           true).

causes_val(move_queen_diagonally(_P,_From,To,_K,_Kpos),
           occupied_by_color(To,white),
           true,
           true).

% capture detection: if occupied_by_color(To,black) was true, set it to false
causes_val(move_queen_diagonally(_P,_From,To,_K,_Kpos),
           occupied_by_color(To,black),
           false,
           occupied_by_color(To,black) = true).

% remove any black piece at To
causes_val(move_queen_diagonally(_P,_From,To,_K,_Kpos),
           at(B,To),
           false,
           and(at(B,To) = true, belongs_to(B,black))).

% check detection: queen lines (rank/file/diagonal) with no blocker
causes_val(move_queen_diagonally(_P,_From,To,_K,Kpos),
           king_in_check(black),
           true,
           and(
             or(
               same_file(To,Kpos),
               or(same_rank(To,Kpos), same_diagonal(To,Kpos))
             ),
             neg(
               some(mid,
                 some(blocker,
                   and(
                     between(To,Kpos,mid),
                     at(blocker,mid) = true
                   )
                 ))
             )
           )).

% reset attacked_by for this queen
causes_val(move_queen_diagonally(P,_From,_To,_K,_Kpos),
           attacked_by(P,S),
           false,
           true) :- square(S).

% mark queen attacks must be recomputed
causes_val(move_queen_diagonally(_P,_F,_T,_K,_Kpos),
           to_update_queen,
           true,
           true).

% increment move counter
causes_val(move_queen_diagonally(_P,_F,_T,_K,_Kpos),
           white_moves,
           N,
           N is white_moves + 1).


%%%%%%%%%%%%%  MOVE WHITE QUEEN VERTICALLY  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

causes_val(move_queen_vertically(_P,_F,_T,_K,_Kpos),
           white_turn, false, true).
causes_val(move_queen_vertically(_P,_F,_T,_K,_Kpos),
           black_turn, true,  true).

causes_val(move_queen_vertically(P,From,_To,_K,_Kpos),
           at(P,From),
           false,
           true).

causes_val(move_queen_vertically(P,_From,To,_K,_Kpos),
           at(P,To),
           true,
           true).

causes_val(move_queen_vertically(_P,From,_To,_K,_Kpos),
           occupied_by_color(From,white),
           false,
           true).

causes_val(move_queen_vertically(_P,_From,To,_K,_Kpos),
           occupied_by_color(To,white),
           true,
           true).

causes_val(move_queen_vertically(_P,_From,To,_K,_Kpos),
           occupied_by_color(To,black),
           false,
           occupied_by_color(To,black) = true).

causes_val(move_queen_vertically(_P,_From,To,_K,_Kpos),
           at(B,To),
           false,
           and(at(B,To) = true, belongs_to(B,black))).

causes_val(move_queen_vertically(_P,_From,To,_K,Kpos),
           king_in_check(black),
           true,
           and(
             or(
               same_file(To,Kpos),
               or(same_rank(To,Kpos), same_diagonal(To,Kpos))
             ),
             neg(
               some(mid,
                 some(blocker,
                   and(
                     between(To,Kpos,mid),
                     at(blocker,mid) = true
                   )
                 ))
             )
           )).

causes_val(move_queen_vertically(P,_From,_To,_K,_Kpos),
           attacked_by(P,S),
           false,
           true) :- square(S).

causes_val(move_queen_vertically(_P,_F,_T,_K,_Kpos),
           to_update_queen,
           true,
           true).

causes_val(move_queen_vertically(_P,_F,_T,_K,_Kpos),
           white_moves,
           N,
           N is white_moves + 1).


%%%%%%%%%%%%%  MOVE WHITE QUEEN HORIZONTALLY  %%%%%%%%%%%%%%%%%%%%%%%%%%

causes_val(move_queen_horizontally(_P,_F,_T,_K,_Kpos),
           white_turn, false, true).
causes_val(move_queen_horizontally(_P,_F,_T,_K,_Kpos),
           black_turn, true,  true).

causes_val(move_queen_horizontally(P,From,_To,_K,_Kpos),
           at(P,From),
           false,
           true).

causes_val(move_queen_horizontally(P,_From,To,_K,_Kpos),
           at(P,To),
           true,
           true).

causes_val(move_queen_horizontally(_P,From,_To,_K,_Kpos),
           occupied_by_color(From,white),
           false,
           true).

causes_val(move_queen_horizontally(_P,_From,To,_K,_Kpos),
           occupied_by_color(To,white),
           true,
           true).

causes_val(move_queen_horizontally(_P,_From,To,_K,_Kpos),
           occupied_by_color(To,black),
           false,
           occupied_by_color(To,black) = true).

causes_val(move_queen_horizontally(_P,_From,To,_K,_Kpos),
           at(B,To),
           false,
           and(at(B,To) = true, belongs_to(B,black))).

causes_val(move_queen_horizontally(_P,_From,To,_K,Kpos),
           king_in_check(black),
           true,
           and(
             or(
               same_file(To,Kpos),
               or(same_rank(To,Kpos), same_diagonal(To,Kpos))
             ),
             neg(
               some(mid,
                 some(blocker,
                   and(
                     between(To,Kpos,mid),
                     at(blocker,mid) = true
                   )
                 ))
             )
           )).

causes_val(move_queen_horizontally(P,_From,_To,_K,_Kpos),
           attacked_by(P,S),
           false,
           true) :- square(S).

causes_val(move_queen_horizontally(_P,_F,_T,_K,_Kpos),
           to_update_queen,
           true,
           true).

causes_val(move_queen_horizontally(_P,_F,_T,_K,_Kpos),
           white_moves,
           N,
           N is white_moves + 1).


%%%%%%%%%%%%%  MOVE BLACK (KING MOVE, NO CAPTURE)  %%%%%%%%%%%%%%%%%%%%%

causes_val(move_black(_P,_F,_T),
           white_turn, true,  true).
causes_val(move_black(_P,_F,_T),
           black_turn, false, true).

causes_val(move_black(P,From,_To),
           at(P,From),
           false,
           true).

causes_val(move_black(P,_From,To),
           at(P,To),
           true,
           true).

causes_val(move_black(_P,From,_To),
           occupied_by_color(From,black),
           false,
           true).

causes_val(move_black(_P,_From,To),
           occupied_by_color(To,black),
           true,
           true).

% not in check anymore
causes_val(move_black(_P,_F,_T),
           king_in_check(black),
           false,
           true).

%%%%%%%%%%%%%  BLACK CAPTURE (KING CAPTURES WHITE PIECE) %%%%%%%%%%%%%%

% remove captured white piece from square To
causes_val(black_capture(_P,_From,To,Att),
           at(Att,To),
           false,
           true).

% remove all attacked_by(Att,_) for the captured white piece
causes_val(black_capture(_P,_From,_To,Att),
           attacked_by(Att,S),
           false,
           true) :- square(S).

% turn change
causes_val(black_capture(_P,_F,_T,_Att),
           white_turn, true,  true).
causes_val(black_capture(_P,_F,_T,_Att),
           black_turn, false, true).

% move king
causes_val(black_capture(P,From,_To,_Att),
           at(P,From),
           false,
           true).

causes_val(black_capture(P,_From,To,_Att),
           at(P,To),
           true,
           true).

% update black occupation
causes_val(black_capture(_P,From,_To,_Att),
           occupied_by_color(From,black),
           false,
           true).

causes_val(black_capture(_P,_From,To,_Att),
           occupied_by_color(To,black),
           true,
           true).

% remove white occupation at To
causes_val(black_capture(_P,_From,To,_Att),
           occupied_by_color(To,white),
           false,
           true).

% not in check anymore
causes_val(black_capture(_P,_F,_T,_Att),
           king_in_check(black),
           false,
           true).

%%%%%%%%%%%%%  DECLARE CHECKMATE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

causes_val(declare_checkmate(C,_P,_Kpos),
           checkmate(C),
           true,
           true).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRECONDITIONS  poss(Action, ConditionFormula)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%  UPDATE ATTACK STATUS KNIGHT  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

poss(update_attack_status_knight(P,S),
     and( and(at(P,S) = true,
              black_turn = true),
          and(neg(white_turn = true),
              and(to_update_knight = true,
                  and(belongs_to(P,white),
                      is_knight(P)))))).

%%%%%%%%%%%%%  UPDATE ATTACK STATUS KING  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

poss(update_attack_status_king(P,S),
     and( and(at(P,S) = true,
              black_turn = true),
          and(neg(white_turn = true),
              and(to_update_king = true,
                  and(belongs_to(P,white),
                      is_king(P)))))).

%%%%%%%%%%%%%  UPDATE ATTACK STATUS ROOK  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

poss(update_attack_status_rook(P,S),
     and(
       and(at(P,S) = true,
           black_turn = true),
       and(neg(white_turn = true),
       and(to_update_rook = true,
       and(belongs_to(P,white),
           is_rook(P))))
     )).

%%%%%%%%%%%%%  UPDATE ATTACK STATUS QUEEN  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

poss(update_attack_status_queen(P,S),
     and(
       and(at(P,S) = true,
           black_turn = true),
       and(neg(white_turn = true),
       and(to_update_queen = true,
       and(belongs_to(P,white),
           is_queen(P))))
     )).

%%%%%%%%%%%%%  MOVE WHITE KNIGHT  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

poss(move_white_knight(P,From,To,K,Kpos),
     and(
        and(at(P,From) = true,
            neg(occupied_by_color(To,white) = true)),
        and(belongs_to(P,white),
        and(belongs_to(K,black),
        and(is_king(K),
        and(at(K,Kpos) = true,
        and(white_turn = true,
        and(neg(black_turn = true),
        and(is_knight(P),
        and(knight_move(From,To),
        and(neg(king_in_check(black) = true),
            neg(to_update_knight = true)))))))))))).

%%%%%%%%%%%%%  MOVE WHITE KING  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

poss(move_white_king(P,From,To,K,Kpos),
     and(
        and(at(P,From) = true,
            neg(occupied_by_color(To,white) = true)),
        and(belongs_to(P,white),
        and(belongs_to(K,black),
        and(is_king(K),
        and(at(K,Kpos) = true,
        and(white_turn = true,
        and(neg(black_turn = true),
        and(is_king(P),
        and(adjacent(From,To),
        and(neg(king_in_check(black) = true),
        and(neg(to_update_king = true),
            neg(adjacent(To,Kpos)))))))))))))).

%%%%%%%%%%%%%  MOVE WHITE ROOK VERTICALLY  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

poss(move_white_rook_vertically(P,From,To,K,Kpos),
     and(
       and(at(P,From) = true,
           neg(occupied_by_color(To,white) = true)),
       and(belongs_to(P,white),
       and(belongs_to(K,black),
       and(is_king(K),
       and(at(K,Kpos) = true,
       and(white_turn = true,
       and(neg(black_turn = true),
       and(is_rook(P),
       and(same_file(From,To),
       and(
         neg(
           some(mid,
             some(blocker,
               and(
                 between(From,To,mid),
                 at(blocker,mid) = true
               )
             ))
         ),
       and(neg(king_in_check(black) = true),
           neg(to_update_rook = true))))))))))))).

%%%%%%%%%%%%%  MOVE WHITE ROOK (HORIZONTALLY)  %%%%%%%%%%%%%%%%%%%%%%%%%

poss(move_white_rook_horizontally(P,From,To,K,Kpos),
     and(
       and(at(P,From) = true,
           neg(occupied_by_color(To,white) = true)),
       and(belongs_to(P,white),
       and(belongs_to(K,black),
       and(is_king(K),
       and(at(K,Kpos) = true,
       and(white_turn = true,
       and(neg(black_turn = true),
       and(is_rook(P),
       and(same_rank(From,To),
       and(
         % no blocker between From and To
         neg(
           some(mid,
             some(blocker,
               and(
                 between(From,To,mid),
                 at(blocker,mid) = true
               )
             ))
         ),
         and(neg(king_in_check(black) = true),
             neg(to_update_rook = true))
       ))))))))))).


%%%%%%%%%%%%%  MOVE WHITE QUEEN DIAGONALLY  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

poss(move_queen_diagonally(P,From,To,K,Kpos),
     and(
       and(at(P,From) = true,
           neg(occupied_by_color(To,white) = true)),
       and(belongs_to(P,white),
       and(belongs_to(K,black),
       and(is_king(K),
       and(at(K,Kpos) = true,
       and(white_turn = true,
       and(neg(black_turn = true),
       and(is_queen(P),
       and(same_diagonal(From,To),
       and(
         % no blocker between From and To
         neg(
           some(mid,
             some(blocker,
               and(
                 between(From,To,mid),
                 at(blocker,mid) = true
               )
             ))
         ),
         and(neg(king_in_check(black) = true),
             neg(to_update_queen = true))
       ))))))))))).

%%%%%%%%%%%%%  MOVE WHITE QUEEN VERTICALLY  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

poss(move_queen_vertically(P,From,To,K,Kpos),
     and(
       and(at(P,From) = true,
           neg(occupied_by_color(To,white) = true)),
       and(belongs_to(P,white),
       and(belongs_to(K,black),
       and(is_king(K),
       and(at(K,Kpos) = true,
       and(white_turn = true,
       and(neg(black_turn = true),
       and(is_queen(P),
       and(same_file(From,To),
       and(
         neg(
           some(mid,
             some(blocker,
               and(
                 between(From,To,mid),
                 at(blocker,mid) = true
               )
             ))
         ),
         and(neg(king_in_check(black) = true),
             neg(to_update_queen = true))
       ))))))))))).


%%%%%%%%%%%%%  MOVE WHITE QUEEN HORIZONTALLY  %%%%%%%%%%%%%%%%%%%%%%%%%%

poss(move_queen_horizontally(P,From,To,K,Kpos),
     and(
       and(at(P,From) = true,
           neg(occupied_by_color(To,white) = true)),
       and(belongs_to(P,white),
       and(belongs_to(K,black),
       and(is_king(K),
       and(at(K,Kpos) = true,
       and(white_turn = true,
       and(neg(black_turn = true),
       and(is_queen(P),
       and(same_rank(From,To),
       and(
         neg(
           some(mid,
             some(blocker,
               and(
                 between(From,To,mid),
                 at(blocker,mid) = true
               )
             ))
         ),
         and(neg(king_in_check(black) = true),
             neg(to_update_queen = true))
       ))))))))))).


%%%%%%%%%%%%%  MOVE BLACK (KING MOVE, NO CAPTURE)  %%%%%%%%%%%%%%%%%%%%%

poss(move_black(P,From,To),
     and(
       and(at(P,From) = true,
           neg(occupied_by_color(To,black) = true)),
       and(belongs_to(P,black),
       and(black_turn = true,
       and(neg(white_turn = true),
       and(king_in_check(black) = true,
       and(neg(to_update_king = true),
       and(neg(to_update_knight = true),
       and(neg(to_update_rook = true),
       and(neg(to_update_queen = true),
       and(is_king(P),
       and(adjacent(From,To),
       and(neg(occupied_by_color(To,white) = true),
       and(
           % not (exists s: adjacent(From,s) & occupied_by_color(s,white))
           neg(some(s,
               and(adjacent(From,s),
                   occupied_by_color(s,white) = true))),
           % not (exists Att: belongs_to(Att,white) & attacked_by(Att,To))
           neg(some(att,
               and(belongs_to(att,white),
                   attacked_by(att,To) = true)))
       )))))))))))))).

%%%%%%%%%%%%%  BLACK CAPTURE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

poss(black_capture(P,From,To,Att),
     and(
       and(at(P,From) = true,
           at(Att,To) = true),
       and(belongs_to(Att,white),
       and(neg(occupied_by_color(To,black) = true),
       and(occupied_by_color(To,white) = true,
       and(belongs_to(P,black),
       and(black_turn = true,
       and(neg(white_turn = true),
       and(neg(to_update_king = true),
       and(neg(to_update_knight = true),
       and(neg(to_update_rook = true),
       and(neg(to_update_queen = true),
       and(is_king(P),
       and(adjacent(From,To),
           % not (exists att': belongs_to(att',white) & attacked_by(att',To))
           neg(some(att2,
               and(belongs_to(att2,white),
                   attacked_by(att2,To) = true)))
       )))))))))))))).

%%%%%%%%%%%%%  DECLARE CHECKMATE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

poss(declare_checkmate(C,P,Kpos),
     and(
       and(at(P,Kpos) = true,
           is_king(P)),
       and(belongs_to(P,black),
       and(black_turn = true,
       and(neg(white_turn = true),
       and(king_in_check(C) = true,
       and(neg(to_update_king = true),
       and(neg(to_update_knight = true),
       and(neg(to_update_rook = true),
       and(neg(to_update_queen = true),
       neg(
        some(adj, 
            and(
                adjacent(Kpos, adj), 
                neg(
                    or(
                        occupied_by_color(adj, black) = true, 
                        some(wp, 
                            and(
                                belongs_to(wp, white), 
                                attacked_by(wp, adj) = true
                            )
                        )
                    )
                )
            )
        )
    )
    
       )))))))))).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIAL STATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% white_moves = 0
initially(white_moves, 0).

% turns
initially(white_turn, true).
initially(black_turn, false).

% no pending updates at start
initially(to_update_king,   false).
initially(to_update_knight, false).
initially(to_update_rook,   false).
initially(to_update_queen,  false).

% no king in check, no checkmate initially
initially(king_in_check(white), false).
initially(king_in_check(black), false).
initially(checkmate(white), false).
initially(checkmate(black), false).

% pieces position
initially(at(wN,c2), true).
initially(at(wK,a1), true).
initially(at(wQ,d1), true).
initially(at(wR,b1), true).
initially(at(bK,c4), true).
initially(at(bR,b4), true).
initially(at(bP1,b3), true).
initially(at(bP2,c3), true).
initially(at(bP3,d3), true).

% all other (piece,square) pairs: at = false
initially(at(P,S), false) :-
    piece(P), square(S),
    \+ initially(at(P,S), true).

% occupied squares
initially(occupied_by_color(a1,white), true).
initially(occupied_by_color(b1,white), true).
initially(occupied_by_color(d1,white), true).
initially(occupied_by_color(c2,white), true).

initially(occupied_by_color(b3,black), true).
initially(occupied_by_color(c3,black), true).
initially(occupied_by_color(d3,black), true).
initially(occupied_by_color(b4,black), true).
initially(occupied_by_color(c4,black), true).

% all other (square,color) pairs: not occupied
initially(occupied_by_color(S,C), false) :-
    square(S), color(C),
    \+ initially(occupied_by_color(S,C), true).

% attacked squares by white knight
initially(attacked_by(wN,a1), true).
initially(attacked_by(wN,a3), true).
initially(attacked_by(wN,b4), true).
initially(attacked_by(wN,d4), true).

% attacked squares by white king
initially(attacked_by(wK,b1), true).
initially(attacked_by(wK,b2), true).
initially(attacked_by(wK,a2), true).

% attacked squares by white rook
initially(attacked_by(wR,a1), true).
initially(attacked_by(wR,c1), true).
initially(attacked_by(wR,d1), true).
initially(attacked_by(wR,b2), true).
initially(attacked_by(wR,b3), true).

% attacked squares by white queen
initially(attacked_by(wQ,d2), true).
initially(attacked_by(wQ,d3), true).
initially(attacked_by(wQ,c2), true).
initially(attacked_by(wQ,b3), true).
initially(attacked_by(wQ,c1), true).
initially(attacked_by(wQ,b1), true).
initially(attacked_by(wQ,a1), true).

% all other attacked_by(P,S) = false
initially(attacked_by(P,S), false) :-
    piece(P), square(S),
    \+ initially(attacked_by(P,S), true).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPLEX ACTIONS / CONTROLLERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% One non-deterministic white move (any white piece)
proc(white_move,
    ndet(
      move_white_knight(P, From, To, K, Kpos),
    ndet(
      move_white_king(P2, From2, To2, K2, Kpos2),
    ndet(
      move_white_rook_vertically(PrV, FrV, ToV, KrV, KposRV),
    ndet(
      move_white_rook_horizontally(PrH, FrH, ToH, KrH, KposRH),
    ndet(
      move_queen_diagonally(PqD, FqD, TqD, KqD, KposQD),
    ndet(
      move_queen_vertically(PqV, FqV, TqV, KqV, KposQV),
      move_queen_horizontally(PqH, FqH, TqH, KqH, KposQH)
    ))))))).

% Update white attacks: king, knight, rook, queen
proc(update_attacks,
     ndet(
       update_attack_status_king(Pk, Sk),
     ndet(
       update_attack_status_knight(Pn, Sn),
     ndet(
       update_attack_status_rook(Pr, Sr),
       update_attack_status_queen(Pq, Sq)
     )))).


% Black's response: either move the black king or capture a white piece
proc(black_response,
     ndet(
       move_black(_Pb, _Fb, _Tb),
       black_capture(_Pb2, _Fb2, _Tb2, _Att)
     )).

% Try to declare checkmate for some color C, king piece P and position Kpos
proc(try_declare_mate,
     declare_checkmate(_C, _P, _Kpos)).

% Basic controller (finds a sequence of legal moves)
proc(basic,
     [ while(
        and(
          neg(checkmate(black) = true),
          white_moves < 3
          ),
         [ white_move,
           update_attacks,
           ndet(black_response, try_declare_mate)
         ]
       )
     ]).

proc(control(basic),basic).

% Smart controller (finds fastest checkmate)
proc(smart,
  [ while(
      and(
        neg(checkmate(black) = true),
        white_moves < 3
      ),
      [ white_move,
        update_attacks,
        ndet(black_response, try_declare_mate)
      ]
    ),
    ?( and( checkmate(black) = true,
            white_moves =< 3))
  ]).

proc(control(smart), search(smart)).
 


