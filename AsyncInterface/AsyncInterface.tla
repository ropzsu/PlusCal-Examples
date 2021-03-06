---------------------- MODULE AsyncInterface -----------------------
EXTENDS Naturals, TLC
\*CONSTANT Data  \* TODO: how specify Data as a range in the Model Checker?

\* Based on the AsynchInterface TLA+ example in Ch. 3 of "Specifying Systems"

(*
--algorithm AsyncInterface {
  variables 
    val \in 0..100,   \* TODO: change 0..100 to Data
    rdy \in 0..1,
    ack \in 0..1;
    
    process (Send = "send")
      variable oldrdy;
    {
      s00:  while (TRUE) {
      s01:    await rdy = ack;
      s02:    val := 44;  \* TODO: how choose a random val?
              oldrdy := rdy;
              rdy := 1 - rdy;
        
              print <<ack, rdy, val, "Send">>;
              assert (val \in 0..100); 
              assert (rdy \in 0..1); 
              assert (ack \in 0..1);
              assert (rdy # oldrdy);
              assert (rdy # ack);
            }    
    }; \* end process Send
    
    
    process (Recv = "recv")
      variable oldack;
    {
      r00:  while (TRUE) {
      r01:    await rdy # ack;
      r02:    oldack := ack;
              ack := 1 - ack;
  
              print <<ack, rdy, val, "Recv">>;
              \* TypeInvariants
              assert (val \in 0..100); 
              assert (rdy \in 0..1); 
              assert (ack \in 0..1);
              assert (ack # oldack);
              assert (rdy = ack);
            }       
    }; \* end process Recv
    
} \* end algorithm
*)
\* BEGIN TRANSLATION
CONSTANT defaultInitValue
VARIABLES val, rdy, ack, pc, oldrdy, oldack

vars == << val, rdy, ack, pc, oldrdy, oldack >>

ProcSet == {"send"} \cup {"recv"}

Init == (* Global variables *)
        /\ val \in 0..100
        /\ rdy \in 0..1
        /\ ack \in 0..1
        (* Process Send *)
        /\ oldrdy = defaultInitValue
        (* Process Recv *)
        /\ oldack = defaultInitValue
        /\ pc = [self \in ProcSet |-> CASE self = "send" -> "s00"
                                        [] self = "recv" -> "r00"]

s00 == /\ pc["send"] = "s00"
       /\ pc' = [pc EXCEPT !["send"] = "s01"]
       /\ UNCHANGED << val, rdy, ack, oldrdy, oldack >>

s01 == /\ pc["send"] = "s01"
       /\ rdy = ack
       /\ pc' = [pc EXCEPT !["send"] = "s02"]
       /\ UNCHANGED << val, rdy, ack, oldrdy, oldack >>

s02 == /\ pc["send"] = "s02"
       /\ val' = 44
       /\ oldrdy' = rdy
       /\ rdy' = 1 - rdy
       /\ PrintT(<<ack, rdy', val', "Send">>)
       /\ Assert((val' \in 0..100), 
                 "Failure of assertion at line 24, column 15.")
       /\ Assert((rdy' \in 0..1), 
                 "Failure of assertion at line 25, column 15.")
       /\ Assert((ack \in 0..1), 
                 "Failure of assertion at line 26, column 15.")
       /\ Assert((rdy' # oldrdy'), 
                 "Failure of assertion at line 27, column 15.")
       /\ Assert((rdy' # ack), "Failure of assertion at line 28, column 15.")
       /\ pc' = [pc EXCEPT !["send"] = "s00"]
       /\ UNCHANGED << ack, oldack >>

Send == s00 \/ s01 \/ s02

r00 == /\ pc["recv"] = "r00"
       /\ pc' = [pc EXCEPT !["recv"] = "r01"]
       /\ UNCHANGED << val, rdy, ack, oldrdy, oldack >>

r01 == /\ pc["recv"] = "r01"
       /\ rdy # ack
       /\ pc' = [pc EXCEPT !["recv"] = "r02"]
       /\ UNCHANGED << val, rdy, ack, oldrdy, oldack >>

r02 == /\ pc["recv"] = "r02"
       /\ oldack' = ack
       /\ ack' = 1 - ack
       /\ PrintT(<<ack', rdy, val, "Recv">>)
       /\ Assert((val \in 0..100), 
                 "Failure of assertion at line 43, column 15.")
       /\ Assert((rdy \in 0..1), 
                 "Failure of assertion at line 44, column 15.")
       /\ Assert((ack' \in 0..1), 
                 "Failure of assertion at line 45, column 15.")
       /\ Assert((ack' # oldack'), 
                 "Failure of assertion at line 46, column 15.")
       /\ Assert((rdy = ack'), "Failure of assertion at line 47, column 15.")
       /\ pc' = [pc EXCEPT !["recv"] = "r00"]
       /\ UNCHANGED << val, rdy, oldrdy >>

Recv == r00 \/ r01 \/ r02

Next == Send \/ Recv

Spec == Init /\ [][Next]_vars

\* END TRANSLATION


====================================================================
