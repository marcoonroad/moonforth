also word
also math

\ begin

definitions memory
  : cells 1 * ;

definitions word
  : only reset also ;

definitions math
  also stack
    : 1-      1 - ;
    : 1+      1 + ;
    : id      ;
    : unless  not if ;
    : neg     0 swap - ;
  except stack

definitions stack
  : nip     swap drop ;
  : over    swap dup rot swap ;
  : ?dup    dup if dup then ;
  : -rot    rot rot ;
  : tuck    swap over ;
  : 2dup    over over ;
  : 2drop   drop drop ;

definitions math
  also stack
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

definitions token
  also stack
    : drop-tokens next drop ;
    : pop-tokens  next ;
    : push-tokens expand ;
    : -rot-tokens rot-tokens rot-tokens ;
  except stack

definitions math
  also stack
    :rec fac
      dup 1 =< if drop 1
      else dup 1 - fac * then ;
  except stack

\ ...

vocabulary aliases
definitions aliases
  also exception
  also world

  alias error      throw
  alias raise      throw
  alias list-words words
  alias print      .

  alias :fix       :rec
  alias :fixpoint  :rec
  alias :recursive :rec
  alias :mu        :rec
  alias :lambda    :fun
  alias :function  :fun
  alias :fn        :fun
  alias :\         :fun

  except exception
  except world

vocabulary session
definitions session
  also stack
  also word
  also world
  also exception
  also runtime
  also module

  also token
    \ alias for [ vocabulary X definitions X ]
    : module dup-tokens vocabulary definitions ;
  except token

\ user definitions come here...

\ end