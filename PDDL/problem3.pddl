(define (problem mate-in-five)
  (:domain chess)

  (:objects
  
    ;; player colors
    white black - color
    
    ;; pieces on the board
    wQ - piece          
    wK - piece
    wR1 wR2 - piece          
    bK - piece          
    bR - piece  
    bN - piece
    bP1 bP2 - piece 
    wP - piece
    
    ;; 4x4 board definition
    a1 a2 a3 a4 - square
    b1 b2 b3 b4 - square
    c1 c2 c3 c4 - square
    d1 d2 d3 d4 - square
  )

  (:init
  
    ;; === Move counter initialization ===

    (= (white_moves) 0)

    ;; === Initial position definition ===
    
    ;; pieces definition
    (is_king wK)
    (is_king bK)
    (is_rook bR)
    (is_knight bN)
    (is_rook wR1)
    (is_rook wR2)
    (is_queen wQ)
    (is_pawn bP1)
    (is_pawn bP2)
    (is_pawn wP)
    
    ;; pieces positions
    (at bN d3)
    (at wK d2)
    (at wQ d1)
    (at bK b4)
    (at wR1 a2)
    (at wR2 b1)
    (at bR c4)
    (at bP1 b3)
    (at bP2 c2)
    (at wP b2)

    ;; pieces ownership
    
    (belongs_to wK white)
    (belongs_to wR1 white)
    (belongs_to wR2 white)
    (belongs_to wQ white)
    (belongs_to wP white)
    (belongs_to bN black)
    (belongs_to bK black)
    (belongs_to bR black)
    (belongs_to bP1 black)
    (belongs_to bP2 black)
    (belongs_to wP white)
    
    ;; occupied squares
    (occupied_by_color a2 white)
    (occupied_by_color b1 white)
    (occupied_by_color d1 white)
    (occupied_by_color b2 white)
    (occupied_by_color d2 white)
    (occupied_by_color d3 black)
    (occupied_by_color b3 black)
    (occupied_by_color b4 black)
    (occupied_by_color c4 black)
    (occupied_by_color c2 black)
    
    ;; === Attacked squares definition ===
      
    ;; white king attacks
    (attacked_by wK d3)
    (attacked_by wK c3)
    (attacked_by wK c1)
    (attacked_by wK c2)
    
    ;; white rooks attacks
    (attacked_by wR1 a1)
    (attacked_by wR1 a3)
    (attacked_by wR1 a4)
    (attacked_by wR2 c1)
    (attacked_by wR2 a1)
    
    ;; white queen attacks
    (attacked_by wQ c1)
    (attacked_by wQ c2)
    (attacked_by wQ b3)
    
    (attacked_by wP a3)
    (attacked_by wP c3)
    
    ;; it's white's turn
    (white_turn)
    (not (black_turn))
    
    ;;  === Board definition ===

    ;; same file relations                  
    (same_file a1 a2) (same_file a1 a3) (same_file a1 a4)
    (same_file a2 a1) (same_file a2 a3) (same_file a2 a4) 
    (same_file a3 a1) (same_file a3 a2) (same_file a3 a4) 
    (same_file a4 a1) (same_file a4 a2) (same_file a4 a3)
    
    (same_file b1 b2) (same_file b1 b3) (same_file b1 b4)
    (same_file b2 b1) (same_file b2 b3) (same_file b2 b4) 
    (same_file b3 b1) (same_file b3 b2) (same_file b3 b4) 
    (same_file b4 b1) (same_file b4 b2) (same_file b4 b3)
    
    (same_file c1 c2) (same_file c1 c3) (same_file c1 c4)
    (same_file c2 c1) (same_file c2 c3) (same_file c2 c4) 
    (same_file c3 c1) (same_file c3 c2) (same_file c3 c4) 
    (same_file c4 c1) (same_file c4 c2) (same_file c4 c3)
    
    (same_file d1 d2) (same_file d1 d3) (same_file d1 d4)
    (same_file d2 d1) (same_file d2 d3) (same_file d2 d4) 
    (same_file d3 d1) (same_file d3 d2) (same_file d3 d4) 
    (same_file d4 d1) (same_file d4 d2) (same_file d4 d3)
    
    ;; same rank relations 
    (same_rank a1 b1) (same_rank a1 c1) (same_rank a1 d1)
    (same_rank a2 b2) (same_rank a2 c2) (same_rank a2 d2)
    (same_rank a3 b3) (same_rank a3 c3) (same_rank a3 d3)
    (same_rank a4 b4) (same_rank a4 c4) (same_rank a4 d4)
    
    (same_rank b1 a1) (same_rank b1 c1) (same_rank b1 d1)
    (same_rank b2 a2) (same_rank b2 c2) (same_rank b2 d2)
    (same_rank b3 a3) (same_rank b3 c3) (same_rank b3 d3)
    (same_rank b4 a4) (same_rank b4 c4) (same_rank b4 d4)
    
    (same_rank c1 a1) (same_rank c1 b1) (same_rank c1 d1)
    (same_rank c2 a2) (same_rank c2 b2) (same_rank c2 d2)
    (same_rank c3 a3) (same_rank c3 b3) (same_rank c3 d3)
    (same_rank c4 a4) (same_rank c4 b4) (same_rank c4 d4)
    
    (same_rank d1 a1) (same_rank d1 b1) (same_rank d1 c1)
    (same_rank d2 a2) (same_rank d2 b2) (same_rank d2 c2)
    (same_rank d3 a3) (same_rank d3 b3) (same_rank d3 c3)
    (same_rank d4 a4) (same_rank d4 b4) (same_rank d4 c4)

    ;; same diagonal relations
    (same_diagonal a1 b2) (same_diagonal a1 c3) (same_diagonal a1 d4)
    (same_diagonal a2 b1) (same_diagonal a2 b3) (same_diagonal a2 c4)
    (same_diagonal a3 b2) (same_diagonal a3 b4) (same_diagonal a3 c1)
    (same_diagonal a4 b3) (same_diagonal a4 c2) (same_diagonal a4 d1)
    
    (same_diagonal b1 a2) (same_diagonal b1 c2) (same_diagonal b1 d3)
    (same_diagonal b2 a1) (same_diagonal b2 a3) (same_diagonal b2 c1) (same_diagonal b2 c3) (same_diagonal b2 d4)
    (same_diagonal b3 a2) (same_diagonal b3 a4) (same_diagonal b3 c2) (same_diagonal b3 d1) (same_diagonal b3 c4)
    (same_diagonal b4 a3) (same_diagonal b4 c3) (same_diagonal b4 d2) 
    
    (same_diagonal c1 b2) (same_diagonal c1 a3) (same_diagonal c1 d2)
    (same_diagonal c2 b1) (same_diagonal c2 d1) (same_diagonal c2 b3) (same_diagonal c2 a4) (same_diagonal c2 d3)
    (same_diagonal c3 b2) (same_diagonal c3 b4) (same_diagonal c3 d2) (same_diagonal c3 d4) (same_diagonal c3 a1)
    (same_diagonal c4 b3) (same_diagonal c4 a2) (same_diagonal c4 d3)
    
    (same_diagonal d1 c2) (same_diagonal d1 b3) (same_diagonal d1 a4) 
    (same_diagonal d2 c1) (same_diagonal d2 c3) (same_diagonal d2 b4)
    (same_diagonal d3 c2) (same_diagonal d3 b1) (same_diagonal d3 c4)
    (same_diagonal d4 c3) (same_diagonal d4 b2) (same_diagonal d4 a1)
    
    ;; adjacent squares relations
    (adjacent a1 a2) (adjacent a1 b1) (adjacent a1 b2)
    (adjacent a2 a1) (adjacent a2 a3) (adjacent a2 b1) (adjacent a2 b2) (adjacent a2 b3)
    (adjacent a3 a2) (adjacent a3 a4) (adjacent a3 b2) (adjacent a3 b3) (adjacent a3 b4)
    (adjacent a4 a3) (adjacent a4 b3) (adjacent a4 b4)
    
    (adjacent b1 a1) (adjacent b1 a2) (adjacent b1 b2) (adjacent b1 c1) (adjacent b1 c2)
    (adjacent b2 a1) (adjacent b2 a2) (adjacent b2 a3) (adjacent b2 b1) (adjacent b2 b3) (adjacent b2 c1) (adjacent b2 c2) (adjacent b2 c3)
    (adjacent b3 a2) (adjacent b3 a3) (adjacent b3 a4) (adjacent b3 b2) (adjacent b3 b4) (adjacent b3 c2) (adjacent b3 c3) (adjacent b3 c4)
    (adjacent b4 a3) (adjacent b4 a4) (adjacent b4 b3) (adjacent b4 c3) (adjacent b4 c4)
    
    (adjacent c1 b1) (adjacent c1 b2) (adjacent c1 c2) (adjacent c1 d1) (adjacent c1 d2)
    (adjacent c2 b1) (adjacent c2 b2) (adjacent c2 b3) (adjacent c2 c1) (adjacent c2 c3) (adjacent c2 d1) (adjacent c2 d2) (adjacent c2 d3)
    (adjacent c3 b2) (adjacent c3 b3) (adjacent c3 b4) (adjacent c3 c2) (adjacent c3 c4) (adjacent c3 d2) (adjacent c3 d3) (adjacent c3 d4)
    (adjacent c4 b3) (adjacent c4 b4) (adjacent c4 c3) (adjacent c4 d3) (adjacent c4 d4)
    
    (adjacent d1 c1) (adjacent d1 c2) (adjacent d1 d2)
    (adjacent d2 c1) (adjacent d2 c2) (adjacent d2 c3) (adjacent d2 d1) (adjacent d2 d3)
    (adjacent d3 c2) (adjacent d3 c3) (adjacent d3 c4) (adjacent d3 d2) (adjacent d3 d4)
    (adjacent d4 c3) (adjacent d4 c4) (adjacent d4 d3)
    
    ;; === between relations ===
    
    ;; between same_file (upward)
    (between a1 a3 a2) (between a1 a4 a2) (between a1 a4 a3) (between a2 a4 a3) 
    (between b1 b3 b2) (between b1 b4 b2) (between b1 b4 b3) (between b2 b4 b3) 
    (between c1 c3 c2) (between c1 c4 c2) (between c1 c4 c3) (between c2 c4 c3) 
    (between d1 d3 d2) (between d1 d4 d2) (between d1 d4 d3) (between d2 d4 d3) 
    
    ;; between same_file (downward)
    (between a3 a1 a2) (between a4 a1 a2) (between a4 a1 a3) (between a4 a2 a3) 
    (between b3 b1 b2) (between b4 b1 b2) (between b4 b1 b3) (between b4 b2 b3) 
    (between c3 c1 c2) (between c4 c1 c2) (between c4 c1 c3) (between c4 c2 c3) 
    (between d3 d1 d2) (between d4 d1 d2) (between d4 d1 d3) (between d4 d2 d3) 

    ;; between same_rank (left)
    (between a1 c1 b1) (between a1 d1 b1) (between a1 d1 c1) (between b1 d1 c1)
    (between a2 c2 b2) (between a2 d2 b2) (between a2 d2 c2) (between b2 d2 c2)
    (between a3 c3 b3) (between a3 d3 b3) (between a3 d3 c3) (between b3 d3 c3)
    (between a4 c4 b4) (between a4 d4 b4) (between a4 d4 c4) (between b4 d4 c4)
    
    ;; between same_rank (right)
    (between c1 a1 b1) (between d1 a1 b1) (between d1 a1 c1) (between d1 b1 c1)
    (between c2 a2 b2) (between d2 a2 b2) (between d2 a2 c2) (between d2 b2 c2)
    (between c3 a3 b3) (between d3 a3 b3) (between d3 a3 c3) (between d3 b3 c3)
    (between c4 a4 b4) (between d4 a4 b4) (between d4 a4 c4) (between d4 b4 c4)

    ;; between same_diagonal
    (between a1 c3 b2) (between a1 d4 b2) (between a1 d4 c3) (between c3 a1 b2) (between d4 a1 b2) (between d4 a1 c3)
    (between a2 c4 b3) (between c4 a2 b3)
    (between a3 c1 b2) (between c1 a3 b2)
    (between a4 c2 b3) (between a4 d1 b3) (between a4 d1 c2) (between c2 a4 b3) (between d1 a4 b3) (between d1 a4 c2)
    
    (between b1 d3 c2) (between d3 b1 c2)
    (between b2 d4 c3) (between d4 b2 c3)
    (between b3 d1 c2) (between d1 b3 c2)
    (between b4 d2 c3) (between d2 b4 c3)
    
    (between c1 a3 b2) (between a3 c1 b2)
    (between c2 a4 b3) (between a4 c2 b3)
    (between c3 a1 b2) (between a1 c3 b2)
    (between c4 a2 b3) (between a2 c4 b3)
    
  )

  (:goal (and
    (checkmate black)
    (<= (white_moves) 5)
)))


