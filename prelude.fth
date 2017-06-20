\ : token
\  create ,
\  does> @ string= ;

\ : lift
\  create
\  does> ;

: first
  execute ;

: second
  rot swap
  first swap ;

\ : vector
\  create dup , cells allot
\  does> dup 1 cells + swap
\  @ ;

\ : index
\  1- rot min cells + ;

\ : clear
\  0 do dup i cells + 0 swap
\ ! loop drop ;

\ : print
\  0 do dup i cells + @ . cr
\  loop drop ;

\ : maximum
\  >r dup @ r> 1 do over i
\  cells + @ max loop swap
\  drop ;

\ : minimum
\  >r dup @ r> 1 do over i
\  cells + @ min loop swap
\  drop ;

\ : sum
\  0 tuck do over i cells + @
\  + loop swap drop ;

\ : product
\  1 tuck do over i cells + @
\  * loop swap drop ;

\ ...