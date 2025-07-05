(define (domain chess)
  (:requirements :strips :typing :numeric-fluents :adl :negative-preconditions :quantified-preconditions)

  (:types
    piece square color
  )

  (:predicates
    (at ?p - piece ?s - square)
    (belongs_to ?p - piece ?c - color)
    (checkmate ?c - color)
    (king_in_check ?c - color)
    (occupied_by_color ?s - square ?c - color)
    (is_king ?p - piece)
    (is_rook ?p - piece)
    (is_queen ?p - piece)
    (is_bishop ?p - piece)
    (is_knight ?p - piece)
    (is_pawn ?p - piece)
    (same_rank ?s1 - square ?s2 - square)
    (same_file ?s1 - square ?s2 - square)
    (same_diagonal ?s1 - square ?s2 - square)
    (knight_move ?s1 - square ?s2 - square)
    (adjacent ?s1 - square ?s2 - square)
    (to_update_king)
    (to_update_knight)
    (to_update_rook)
    (to_update_bishop)
    (to_update_queen)
    (white_turn)
    (black_turn)
    (between ?from - square ?to - square ?mid - square)

    ;; New predicates for attacked squares per piece
    (attacked_by ?p - piece ?s - square)
  )

  (:functions
    (white_moves)                        
  )

(:action update_attack_status_knight
  :parameters (?p - piece ?s - square)
  :precondition (and
    (at ?p ?s)
    (black_turn)
    (not (white_turn))
    (to_update_knight)
    (belongs_to ?p white)
    (is_knight ?p)
  )
  :effect (and
    ;; For all squares: if there exists a piece attacking it, mark as attacked
    (forall (?att - square)
        (when (knight_move ?s ?att) (attacked_by ?p ?att)))
    (not (to_update_knight))
  )
)

(:action update_attack_status_king
  :parameters (?p - piece ?s - square)
  :precondition (and
    (at ?p ?s)
    (black_turn)
    (not (white_turn))
    (to_update_king)
    (belongs_to ?p white)
    (is_king ?p)
  )
  :effect (and
    (forall (?att - square)
        (when (adjacent ?s ?att) (attacked_by ?p ?att)))
    (not (to_update_king))
  )
)

(:action update_attack_status_rook
  :parameters (?p - piece ?s - square)
  :precondition (and
    (at ?p ?s)
    (black_turn)
    (not (white_turn))
    (to_update_rook)
    (belongs_to ?p white)
    (is_rook ?p)
  )
  :effect (and
  
    (forall (?att - square)
        (when (and
           (or (same_rank ?s ?att) (same_file ?s ?att))  ; or (same_file ?s ?att)
           (not (exists (?mid - square ?blocker - piece)
             (and
               (not (and (is_king ?blocker) (belongs_to ?blocker black)))
               (between ?s ?att ?mid)
               (at ?blocker ?mid)
             )
           ))
        )
        (attacked_by ?p ?att)
        )
    )
    (not (to_update_rook))
  )
)

(:action update_attack_status_bishop
  :parameters (?p - piece ?s - square)
  :precondition (and
    (at ?p ?s)
    (black_turn)
    (not (white_turn))
    (to_update_bishop)
    (belongs_to ?p white)
    (is_bishop ?p)
  )
  :effect (and
  
    (forall (?att - square)
        (when (and
           (same_diagonal ?s ?att) ; or (same_file ?s ?att)
           (not (exists (?mid - square ?blocker - piece)
             (and
               (not (and (is_king ?blocker) (belongs_to ?blocker black)))
               (between ?s ?att ?mid)
               (at ?blocker ?mid)
             )
           ))
        )
        (attacked_by ?p ?att)
        )
    )
        
    (not (to_update_bishop))
  )
)

(:action update_attack_status_queen
  :parameters (?p - piece ?s - square)
  :precondition (and
    (at ?p ?s)
    (black_turn)
    (not (white_turn))
    (to_update_queen)
    (belongs_to ?p white)
    (is_queen ?p)
  )
  :effect (and
  
    (forall (?att - square)
        (when (and
           (or (same_rank ?s ?att) (same_file ?s ?att) (same_diagonal ?s ?att))  ; or (same_file ?s ?att)
           (not (exists (?mid - square ?blocker - piece)
             (and
               (not (and (is_king ?blocker) (belongs_to ?blocker black)))
               (between ?s ?att ?mid)
               (at ?blocker ?mid)
             )
           ))
        )
        (attacked_by ?p ?att)
        )
    )
    
    (not (to_update_queen))
  )
)
  
  (:action move_white_knight
    :parameters (?p - piece ?from - square ?to - square ?k - piece ?kpos - square)
    :precondition (and
      (at ?p ?from)
      (not (occupied_by_color ?to white))
      (belongs_to ?p white)
      (belongs_to ?k black)
      (is_king ?k)
      (at ?k ?kpos)
      (white_turn)
      (not (black_turn))
      (is_knight ?p)
      (knight_move ?from ?to)
      (not (king_in_check black))
      (not(to_update_knight))
    )
    :effect (and
        ;; Standard move effects
        (black_turn)
        (not (white_turn))
        (not (at ?p ?from))
        (at ?p ?to)
        (not (occupied_by_color ?from white))
        (occupied_by_color ?to white)
        (increase (white_moves) 1)
        
        ;;capture detection
        (when (occupied_by_color ?to black) (not (occupied_by_color ?to black)))
        (forall (?b - piece)
            (when (and (at ?b ?to) (belongs_to ?b black))
                (not (at ?b ?to))
            )
        )

        ;; Check detection (same as before)
        (when (knight_move ?to ?kpos) (king_in_check black))
        
        (forall (?s - square)
          (not (attacked_by ?p ?s))
        )
        
        (to_update_knight)
        
    )
)
          
    (:action move_white_king
    :parameters (?p - piece ?from - square ?to - square ?k - piece ?kpos - square)
    :precondition (and
      (at ?p ?from)
      (not(occupied_by_color ?to white))
      (belongs_to ?p white)
      (belongs_to ?k black)
      (is_king ?k)
      (at ?k ?kpos)
      (white_turn)
      (not (black_turn))
      (is_king ?p)
      (adjacent ?from ?to)
      (not (king_in_check black))
      (not (to_update_king))
      (not (adjacent ?to ?kpos))
    )
    :effect (and
        ;; Standard move effects
        (black_turn)
        (not (white_turn))
        (not (at ?p ?from))
        (at ?p ?to)
        (not (occupied_by_color ?from white))
        (occupied_by_color ?to white)
        (increase (white_moves) 1)
        
        ;;capture detection
        (when (occupied_by_color ?to black) (not (occupied_by_color ?to black)))
        (forall (?b - piece)
            (when (and (at ?b ?to) (belongs_to ?b black))
                (not (at ?b ?to))
            )
        )

        ;; Remove all attacked_by squares of piece ?p (reset attacked squares for moved piece)
        (forall (?s - square) (not (attacked_by ?p ?s)))
        (to_update_king)
            )
          )
          
    (:action move_white_rook_vertically
    :parameters (?p - piece ?from - square ?to - square ?k - piece ?kpos - square)
    :precondition (and
      (at ?p ?from)
      (not(occupied_by_color ?to white))
      (belongs_to ?p white)
      (belongs_to ?k black)
      (is_king ?k)
      (at ?k ?kpos)
      (white_turn)
      (not (black_turn))
      (is_rook ?p)
      (same_file ?from ?to)
      (not (exists (?mid - square ?blocker - piece)
                    (and
                        (between ?from ?to ?mid)
                        (at ?blocker ?mid)
                    )
                )
            )
      (not (king_in_check black))
      (not(to_update_rook))
    )
    :effect (and
        ;; Standard move effects
        (black_turn)
        (not (white_turn))
        (not (at ?p ?from))
        (at ?p ?to)
        (not (occupied_by_color ?from white))
        (occupied_by_color ?to white)
        (increase (white_moves) 1)
        
        ;;capture detection
        (when (occupied_by_color ?to black) (not (occupied_by_color ?to black)))
        (forall (?b - piece)
            (when (and (at ?b ?to) (belongs_to ?b black))
                (not (at ?b ?to))
            )
        )

        ;; Check detection
        (when 
            (and (or (same_file ?to ?kpos) (same_rank ?to ?kpos)) 
                (not (exists (?mid - square ?blocker - piece)
                    (and
                        (between ?to ?kpos ?mid)
                        (at ?blocker ?mid)
                    )
                )
            )
        )
        (king_in_check black))

        ;; Remove all attacked_by squares of piece ?p (reset attacked squares for moved piece)
        (forall (?s - square) (not (attacked_by ?p ?s)))

        (to_update_rook)
        
            )
          )
          
    (:action move_white_rook_horizontally
    :parameters (?p - piece ?from - square ?to - square ?k - piece ?kpos - square)
    :precondition (and
      (at ?p ?from)
      (not(occupied_by_color ?to white))
      (belongs_to ?p white)
      (belongs_to ?k black)
      (is_king ?k)
      (at ?k ?kpos)
      (white_turn)
      (not (black_turn))
      (is_rook ?p)
      (same_rank ?from ?to)
      (not (exists (?mid - square ?blocker - piece)
                    (and
                        (between ?from ?to ?mid)
                        (at ?blocker ?mid)
                    )
                )
            )
      (not (king_in_check black))
      (not (to_update_rook))
    )
    :effect (and
        ;; Standard move effects
        (black_turn)
        (not (white_turn))
        (not (at ?p ?from))
        (at ?p ?to)
        (not (occupied_by_color ?from white))
        (occupied_by_color ?to white)
        (increase (white_moves) 1)
        
        ;;capture detection
        (when (occupied_by_color ?to black) (not (occupied_by_color ?to black)))
        (forall (?b - piece)
            (when (and (at ?b ?to) (belongs_to ?b black))
                (not (at ?b ?to))
            )
        )

        ;; Check detection
        (when 
            (and (or (same_file ?to ?kpos) (same_rank ?to ?kpos)) 
                (not (exists (?mid - square ?blocker - piece)
                    (and
                        (between ?to ?kpos ?mid)
                        (at ?blocker ?mid)
                    )
                )
            )
        )
        (king_in_check black))

        ;; Remove all attacked_by squares of piece ?p (reset attacked squares for moved piece)
        (forall (?s - square) (not (attacked_by ?p ?s)))

        (to_update_rook)
            )
          )
          
    (:action move_bishop
    :parameters (?p - piece ?from - square ?to - square ?k - piece ?kpos - square)
    :precondition (and
      (at ?p ?from)
      (not(occupied_by_color ?to white))
      (belongs_to ?p white)
      (belongs_to ?k black)
      (is_king ?k)
      (at ?k ?kpos)
      (white_turn)
      (not (black_turn))
      (is_bishop ?p)
      (same_diagonal ?from ?to)
      (not (exists (?mid - square ?blocker - piece)
                    (and
                        (between ?from ?to ?mid)
                        (at ?blocker ?mid)
                    )
                )
            )
      (not (king_in_check black))
      (not(to_update_bishop))
    )
    :effect (and
        ;; Standard move effects
        (black_turn)
        (not (white_turn))
        (not (at ?p ?from))
        (at ?p ?to)
        (not (occupied_by_color ?from white))
        (occupied_by_color ?to white)
        (increase (white_moves) 1)
        
        ;;capture detection
        (when (occupied_by_color ?to black) (not (occupied_by_color ?to black)))
        (forall (?b - piece)
            (when (and (at ?b ?to) (belongs_to ?b black))
                (not (at ?b ?to))
            )
        )

        ;; Check detection
        (when 
            (and (same_diagonal ?to ?kpos) 
                (not (exists (?mid - square ?blocker - piece)
                    (and
                        (between ?to ?kpos ?mid)
                        (at ?blocker ?mid)
                    )
                )
            )
        )
        (king_in_check black))
        
        ;; Remove all attacked_by squares of piece ?p (reset attacked squares for moved piece)
        (forall (?s - square) (not (attacked_by ?p ?s)))
        
        (to_update_bishop)
            )
          )
          
    (:action move_queen_diagonally
    :parameters (?p - piece ?from - square ?to - square ?k - piece ?kpos - square)
    :precondition (and
      (at ?p ?from)
      (not(occupied_by_color ?to white))
      (belongs_to ?p white)
      (belongs_to ?k black)
      (is_king ?k)
      (at ?k ?kpos)
      (white_turn)
      (not (black_turn))
      (is_queen ?p)
      (same_diagonal ?from ?to)
      (not (exists (?mid - square ?blocker - piece)
                    (and
                        (between ?from ?to ?mid)
                        (at ?blocker ?mid)
                    )
                )
            )
      (not (king_in_check black))
      (not(to_update_queen))
    )
    :effect (and
        ;; Standard move effects
        (black_turn)
        (not (white_turn))
        (not (at ?p ?from))
        (at ?p ?to)
        (not (occupied_by_color ?from white))
        (occupied_by_color ?to white)
        (increase (white_moves) 1)
        
        ;;capture detection
        (when (occupied_by_color ?to black) (not (occupied_by_color ?to black)))
        (forall (?b - piece)
            (when (and (at ?b ?to) (belongs_to ?b black))
                (not (at ?b ?to))
            )
        )

        ;; Check detection
        (when 
            (and (or (same_file ?to ?kpos) (same_rank ?to ?kpos) (same_diagonal ?to ?kpos)) 
                (not (exists (?mid - square ?blocker - piece)
                    (and
                        (between ?to ?kpos ?mid)
                        (at ?blocker ?mid)
                    )
                )
            )
        )
        (king_in_check black))

        ;; Remove all attacked_by squares of piece ?p (reset attacked squares for moved piece)
        (forall (?s - square) (not (attacked_by ?p ?s)))

        ;; Add attacked_by squares from new position of ?p
        (to_update_queen)
            )
          )
    (:action move_queen_vertically
    :parameters (?p - piece ?from - square ?to - square ?k - piece ?kpos - square)
    :precondition (and
      (at ?p ?from)
      (not(occupied_by_color ?to white))
      (belongs_to ?p white)
      (belongs_to ?k black)
      (is_king ?k)
      (at ?k ?kpos)
      (white_turn)
      (not (black_turn))
      (is_queen ?p)
      (same_file ?from ?to)
      (not (exists (?mid - square ?blocker - piece)
                    (and
                        (between ?from ?to ?mid)
                        (at ?blocker ?mid)
                    )
                )
            )
      (not (king_in_check black))
      (not(to_update_queen))
    )
    :effect (and
        ;; Standard move effects
        (black_turn)
        (not (white_turn))
        (not (at ?p ?from))
        (at ?p ?to)
        (not (occupied_by_color ?from white))
        (occupied_by_color ?to white)
        (increase (white_moves) 1)
        
        ;;capture detection
        (when (occupied_by_color ?to black) (not (occupied_by_color ?to black)))
        (forall (?b - piece)
            (when (and (at ?b ?to) (belongs_to ?b black))
                (not (at ?b ?to))
            )
        )

        ;; Check detection
        (when 
            (and (or (same_file ?to ?kpos) (same_rank ?to ?kpos) (same_diagonal ?to ?kpos)) 
                (not (exists (?mid - square ?blocker - piece)
                    (and
                        (between ?to ?kpos ?mid)
                        (at ?blocker ?mid)
                    )
                )
            )
        )
        (king_in_check black))

        ;; Remove all attacked_by squares of piece ?p (reset attacked squares for moved piece)
        (forall (?s - square) (not (attacked_by ?p ?s)))

        ;; Add attacked_by squares from new position of ?p
        (to_update_queen)
            )
          )  
          
    (:action move_queen_horizontally
    :parameters (?p - piece ?from - square ?to - square ?k - piece ?kpos - square)
    :precondition (and
      (at ?p ?from)
      (not(occupied_by_color ?to white))
      (belongs_to ?p white)
      (belongs_to ?k black)
      (is_king ?k)
      (at ?k ?kpos)
      (white_turn)
      (not (black_turn))
      (is_queen ?p)
      (same_rank ?from ?to)
      (not (exists (?mid - square ?blocker - piece)
                    (and
                        (between ?from ?to ?mid)
                        (at ?blocker ?mid)
                    )
                )
            )
      (not (king_in_check black))
      (not(to_update_queen))
    )
    :effect (and
        ;; Standard move effects
        (black_turn)
        (not (white_turn))
        (not (at ?p ?from))
        (at ?p ?to)
        (not (occupied_by_color ?from white))
        (occupied_by_color ?to white)
        (increase (white_moves) 1)
        
        ;;capture detection
        (when (occupied_by_color ?to black) (not (occupied_by_color ?to black)))
        (forall (?b - piece)
            (when (and (at ?b ?to) (belongs_to ?b black))
                (not (at ?b ?to))
            )
        )

        ;; Check detection
        (when 
            (and (or (same_file ?to ?kpos) (same_rank ?to ?kpos) (same_diagonal ?to ?kpos)) 
                (not (exists (?mid - square ?blocker - piece)
                    (and
                        (between ?to ?kpos ?mid)
                        (at ?blocker ?mid)
                    )
                )
            )
        )
        (king_in_check black))

        ;; Remove all attacked_by squares of piece ?p (reset attacked squares for moved piece)
        (forall (?s - square) (not (attacked_by ?p ?s)))

        ;; Add attacked_by squares from new position of ?p
        (to_update_queen)
        )
    )
          
  ;; -------------------
  ;; ACTION: MOVE BLACK (HARD-CODED)
  ;; -------------------
  (:action move_black
    :parameters (?p - piece ?from - square ?to - square)
    :precondition (and
      (at ?p ?from)
      (not (occupied_by_color ?to black))
      (belongs_to ?p black)
      (black_turn)
      (not (white_turn))
      (king_in_check black)
      (not(to_update_king))
      (not(to_update_knight))
      (not(to_update_rook))
      (not(to_update_bishop))
      (not(to_update_queen))
      (is_king ?p)
      (adjacent ?from ?to)
      (not (occupied_by_color ?to white))
      (not (exists (?s - square) (and (adjacent ?from ?s) (occupied_by_color ?s white))))
      (not (exists (?att - piece) (and (belongs_to ?att white) (attacked_by ?att ?to))))
    )
    :effect (and
      (white_turn)
      (not (black_turn))
      (not (at ?p ?from))
      (at ?p ?to)
      (not (occupied_by_color ?from black))
      (occupied_by_color ?to black)
      (not (king_in_check black))
    )
  )

 (:action black_capture
    :parameters (?p - piece ?from - square ?to - square ?att - piece)
    :precondition (and
      (at ?p ?from)
      (at ?att ?to)
      (belongs_to ?att white)
      (not (occupied_by_color ?to black))
      (occupied_by_color ?to white)
      (belongs_to ?p black)
      (black_turn)
      (not (white_turn))
      (not(to_update_king))
      (not(to_update_knight))
      (not(to_update_rook))
      (not(to_update_bishop))
      (not(to_update_queen))
      (is_king ?p)
      (adjacent ?from ?to)
      (not (exists (?att - piece) (and (belongs_to ?att white) (attacked_by ?att ?to))))
    )
    :effect (and
      (not(at ?att ?to))
      (forall (?s - square) (not (attacked_by ?att ?s)))
      (white_turn)
      (not (black_turn))
      (not (at ?p ?from))
      (at ?p ?to)
      (not (occupied_by_color ?from black))
      (occupied_by_color ?to black)
      ;;capture detection
      (not (occupied_by_color ?to white))
      (not (king_in_check black))
  )
 )
  ;; -------------------
  ;; ACTION: DECLARE CHECKMATE
  ;; -------------------
  (:action declare_checkmate
    :parameters (?c - color ?p - piece ?kpos - square)
    :precondition (and
      (at ?p ?kpos)
      (is_king ?p)
      (belongs_to ?p black)
      (black_turn)
      (not (white_turn))
      (king_in_check ?c)
      (not(to_update_king))
      (not(to_update_knight))
      (not(to_update_rook))
      (not(to_update_bishop))
      (not(to_update_queen))
      
      ;; is king trapped??
      (forall (?adj - square)
        (imply
          (adjacent ?kpos ?adj)
          (or
            (occupied_by_color ?adj ?c)
            (exists (?wp - piece)
              (and
                (belongs_to ?wp white)
                (attacked_by ?wp ?adj)
              )
            )
          )
        )
      )
    )
    :effect (checkmate ?c)
  )
)

