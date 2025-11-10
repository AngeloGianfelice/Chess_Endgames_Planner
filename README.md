# ♟️ Chess Endgames Planner

**Authors:**  
Angelo Gianfelice (1851260)  
Stefano Previti (2151985)  
**Course:** Planning and Reasoning 2025/26 — *Sapienza University of Rome*

---

## 🧩 Overview

This project explores **Automated Planning and Reasoning** in simplified **chess endgame scenarios**.  
It combines **PDDL** planning and **Indigolog** reasoning to model, plan, and simulate *forced checkmate* sequences.

The domain focuses on positions where one side (White) has a material advantage, and the objective is to find a **forced mate** within a fixed number of moves on a **4×4 simplified chessboard**.

---

## 🧠 Project Structure

```
Chess_Endgames_Planner/
│
├── PDDL/
│   ├── domain.pddl                 # PDDL domain description (pieces, moves, predicates, etc.)
│   ├── problem1_smothered.pddl     # Mate in 1 (Smothered Mate)
│   ├── problem2_anastasia.pddl     # Mate in 3 (Anastasia’s Mate)
│   └── problem3_damiano.pddl       # Mate in 5 (Damiano’s Mate)
│
├── Indigolog/
│   ├── chess.pl                    # Indigolog implementation of the chess domain and controllers
│   └── main.pl                     # Main program: legality & projection tasks
```

---

## ⚙️ PDDL Domain and Planner

- **Planner:** [ENHSP](https://github.com/hstairs/enhsp)
- **Heuristics tested:** `blind`, `hadd`, `hmax`
- **Search algorithms:** `GBFS`, `A*`

Three problem instances of increasing complexity were solved:

| Problem | Mate Type | Plan Length | Best Heuristic | Found Mate |
|----------|------------|--------------|----------------|-------------|
| 1 | Smothered Mate | 3 | blind/hadd/hmax | ✅ |
| 2 | Anastasia’s Mate | 9 | hadd/hmax | ✅ |
| 3 | Damiano’s Mate | 15 | hadd/hmax | ✅ |

---

## 🤖 Indigolog Implementation

The Indigolog implementation reuses the same predicates and actions as the PDDL domain.  
It focuses on *Anastasia’s Mate* and supports the following reasoning tasks:

1. **Controller Execution:** Finds a legal sequence of moves leading to checkmate.  
2. **Legality Task:** Verifies if a given sequence of actions is executable from an initial situation.  
3. **Projection Task:** Simulates whether a condition (e.g., a piece position) will hold after executing a sequence.

---

## 🧪 How to Run

### PDDL
1. Install [ENHSP](https://github.com/hstairs/enhsp).
2. Run a problem instance:
   ```bash
   java -jar enhsp.jar -o PDDL/domain.pddl -f PDDL/problem1_smothered.pddl -sp gbfs -h hadd
   ```

### Indigolog
1. Install [IndiGolog](https://github.com/roboticslab-uc3m/indigolog) (requires SWI-Prolog).
2. Run the main program:
   ```bash
   swipl Indigolog/main.pl
   ```

---

## 🧾 References

- [ENHSP Planner](https://github.com/hstairs/enhsp)  

