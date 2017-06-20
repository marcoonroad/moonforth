also word
also math

\ begin

definitions memory
  : cells 1 * ;

definitions forth
  : only reset also ;

definitions math also stack
  : 1-      1 - ;
  : 1+      1 + ;
  : id      ;
  : unless  not if ;
  : neg     0 swap - ;

definitions stack
  : nip     swap drop ;
  : over    swap dup rot swap ;
  : ?dup    dup if dup then ;
  : -rot    rot rot ;
  : tuck    swap over ;
  : 2dup    over over ;
  : 2drop   drop drop ;

definitions math also stack
  : /=      = not ;
  : =<      2dup < -rot = | ;
  : >=      < not ;
  : >       swap < ;
  : abs     dup 0 < if neg then ;
  : diff    - abs ;
  : min     2dup < if drop else nip then ;
  : max     2dup > if drop else nip then ;

  :rec ^
    dup 1 =< if drop
    else 1- over -rot ^ * then ;

  : ^2 2 ^ ;
  except stack

definitions token also stack
  : drop-tokens next drop ;
  : pop-tokens  next ;
  : push-tokens expand ;
  except stack

definitions math
  alias :fix       :rec
  alias :fixpoint  :rec
  alias :recursive :rec
  alias :mu        :rec
  alias :lambda    :fun
  alias :function  :fun
  alias :fn        :fun
  alias :\         :fun

  :rec fac
    dup 1 =< if drop 1
    else dup 1 - fac * then ;

\ ...

vocabulary session
definitions session
  also world
  also exception
  also runtime
  also module

\ user definitions come here...

\ end