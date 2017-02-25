// TODO: add the copyright notice
// TODO: synchronise with the last version of Alk
//require "domains.k"

module ALK-SYNTAX 

  syntax DVar ::= "NULL"

  syntax ValFld ::=
     Id "->" Value

  syntax ValFldList ::= List{ValFld, ""}


  syntax Value ::=
       Int
     | Bool
     | Float
     | String
     | DVar
     | "{" ValFldList "}"   // structures
     | "{" ValueList "}"    // sets
     | "[" ValueList "]"    // arrays
     | "<" ValueList ">"    // linear lists (sequences)

  syntax ValueList ::= List{Value, ","} 

  syntax OpRel ::= "<" | "<=" | "==" | ">" | ">=" | "!="

  syntax Interval ::= Exp ".." Exp // [strict]

  syntax FunctionCall ::= Exp "("  Exps ")" [strict(1)]

  syntax VarAssign ::= Exp "=" Exp   [strict(2)]

  syntax IncDec ::=
       "++" Id                
     | "--" Id

  syntax VarUpdate ::=  
       VarAssign
     | IncDec

  syntax Exp ::=
       Id
     | Value
     | FunctionCall  
     | IncDec
     | (Exp)                   [bracket]
     | "emptyList"
     | "emptySet"
     | "sin" "(" Exp ")"       [strict]
     | "cos" "(" Exp ")"       [strict]
     | "tan" "(" Exp ")"       [strict]
     | "asin" "(" Exp ")"      [strict]
     | "acos" "(" Exp ")"      [strict]
     | "atan" "(" Exp ")"      [strict]
     | "sqrt" "(" Exp ")"      [strict]
     | "ceil" "(" Exp ")"      [strict]
     | "floor" "(" Exp ")"     [strict]
     | "int" "(" Exp ")"       [strict]
     | "new" "(" Exp ")"       [strict]
     | "random" "(" Exp ")"    [strict]
//     | "{" Exp "}"            // singleton set
//     | "<" Exp ">"            // singleton list
     |  "singletonSet" "(" Exp ")"        [strict]
     |  "singletonList" "(" Exp ")"       [strict]
     | "{" Interval "}"        [strict]
     | "<" Interval ">"        [strict]
     | "[" Interval "]"        [strict]
     > Exp "[" Exp "]"         [strict]
     > Exp "." "at" "(" Exp ")"             [strict]
     | Exp "." "topFront" "(" ")"           [strict]
     | Exp "." "topBack" "(" ")"            [strict]
     | Exp "." "size" "(" ")"               [strict]
     | Exp "." "update" "(" Exp "," Exp ")" [strict]
     | Exp "." "insert" "(" Exp "," Exp ")" [strict]
     | Exp "." "removeAt" "(" Exp ")"       [strict]
     | Exp "." "removeAllEqTo" "(" Exp ")"  [strict]
     | Exp "." "pushFront" "(" Exp ")"      [strict]
     | Exp "." "pushBack" "(" Exp ")"       [strict]
     | Exp "." "popFront" "(" ")"           [strict]
     | Exp "." "popBack" "(" ")"            [strict]
     > Exp "." Id                           [left, strict(1)]
     > left:
       Exp "*" Exp           [left, strict] 
     | Exp "/" Exp           [left, strict]
     | Exp "%" Exp           [left, strict]
     > left:
       Exp "+" Exp           [left, strict] 
     | Exp "-" Exp           [left, strict]
     > left:
       Exp "U" Exp           [left, strict]
     | Exp "^" Exp           [left, strict]
     | Exp "\\" Exp          [left, strict]
     > Exp OpRel Exp         [noassoc, strict(1,3)]
     > Exp "belongsTo" Exp   [strict]
     > "!" Exp               [strict]
     > left:
       Exp "&&" Exp          [left, strict] 
     > Exp "||" Exp          [left, strict]

  syntax Stmt ::=
        Id "(" Ids ")" "{" Stmt "}"
     |  FunctionCall ";"                         [strict]
     |  VarUpdate ";"                            [strict]
     |  Exp "." "update" "(" Exp "," Exp ")" ";" [strict(2,3)]
     |  Exp "." "insert" "(" Exp "," Exp ")" ";" [strict(2,3)]
     |  Exp "." "removeAt" "(" Exp ")" ";"       [strict(2)]
     |  Exp "." "removeAllEqTo" "(" Exp ")" ";"  [strict(2)]
     |  Exp "." "pushFront" "(" Exp ")" ";"      [strict(2)]
     |  Exp "." "pushBack" "(" Exp ")" ";"       [strict(2)]
     |  Exp "." "popFront" "(" ")" ";"
     |  Exp "." "popBack" "(" ")" ";"
     | "choose"  Id "in" Exp ";"                 [prefer, strict(2)]
     | "choose"  Id "in" Exp "s.t." Exp ";"      [strict(2)]
     | "success" ";"
     | "failure" ";"
     |  "{" "}" 
     |  "{" Stmt "}" 
     | "if" "(" Exp ")" Stmt "else" Stmt         [avoid, strict]
     | "if" "(" Exp ")" Stmt
     |  "while" "(" Exp ")" Stmt 
     |  "forall" Id "in" Exp  Stmt              [strict(2)]
     |  "for" "(" VarAssign ";" Exp";" VarUpdate ")" Stmt
     | "return" Exp ";"                         [strict]
     > Stmt Stmt [right]

  syntax Ids ::= List{Id, ","}
  syntax Exps ::= List{Exp, ","}

endmodule

module ALK
  imports ALK-SYNTAX

  syntax ExtendedValue ::=
       Value 
     | "$updateVal" "(" Int "," ExtendedValue ")"    // helper for updating
     | "$updateVal" "(" Id "," ExtendedValue ")"    // helper for updating
     | "$insertVal" "(" Int "," ExtendedValue ")"    // helper for inserting
     | "$removeAtVal" "(" Int ")"    // helper for removing at a given position
     | "$removeAllEqToVal" "(" ExtendedValue ")"    // helper for removing all equal to a given value

  syntax ExtendedValueList ::= List{ExtendedValue, ","}

  syntax Exp ::= ExtendedValue

  syntax Stmt ::= Value ";"

  syntax KResult ::= ExtendedValue
     | ValFldList
     | ValueList

  configuration
    <k> $PGM:Stmt </k>
    <state> $INIT:Map </state> 
    <stack> .List </stack>
    <ltime> 0 </ltime>
    <utime> 0 </utime>
//<debug> .List </debug>

/* Expression  evaluation */

// state lookup
  rule <k> X:Id => V ...</k>
       <state>... X |-> V:Value  ...</state>

// singleton

/*
  rule { X:Exp } => X ~> { HOLE:Exp }               [heat]
  rule V:Value ~> { HOLE:Exp } => { V, .ValueList } [cool]

  rule < X:Exp > => X ~> < HOLE:Exp >               [heat]
  rule V:Value ~> < HOLE:Exp > => < V, .ValueList > [cool]
*/
  rule singletonSet(V:Value)  =>  { V, .ValueList }
  rule singletonList(V:Value) =>  < V, .ValueList >

// operators  


/*
  rule I1 * I2 => I1 *Int I2
  rule I1 / I2 => I1 /Int I2
  rule I1 % I2 => I1 %Int I2
  rule I1 + I2 => I1 +Int I2
  rule I1 - I2 => I1 -Int I2

  rule I1:Int != I2:Int => I1 =/=Int I2 
  rule I1:Int == I2:Int => I1 ==Int I2 
  rule I1:Int < I2:Int => I1 <Int I2 
  rule I1:Int <= I2:Int => I1 <=Int I2 
  rule I1:Int >= I2:Int => I1 >=Int I2
  rule I1:Int > I2:Int => I1 >Int I2  
*/


  rule <k> I1:Int + I2:Int => I1 +Int I2 ...</k>
       <ltime> T:Int => T +Int maxInt($log(I1), $log(I2)) </ltime>
       <utime> T':Int => T' +Int 1 </utime>


  rule <k> I1:Int - I2:Int => I1 -Int I2...</k>
       <ltime> T:Int => T +Int maxInt($log(I1), $log(I2)) </ltime> 
       <utime> T':Int => T' +Int 1 </utime>

  rule <k> I1:Int * I2:Int => I1 *Int I2 ...</k>
       <ltime> T:Int => T +Int $log(I1) *Int $log(I2) </ltime>
       <utime> T':Int => T' +Int 1 </utime>

  rule <k> I1:Int / I2:Int => I1 /Int I2 ...</k>
       <ltime> T:Int => T +Int $log(I1) * $log(I2) </ltime>
       <utime> T':Int => T' +Int 1 </utime>
       when I2 =/=Int 0 
 
  rule <k> I1:Int % I2:Int => I1 %Int I2 ...</k>
       <ltime> T:Int => T +Int $log(I1) *Int $log(I2) </ltime>
       <utime> T':Int => T' +Int 1 </utime>
       when I2 =/=Int 0

  rule <k> I1:Int < I2:Int => (I1 <Int I2) ...</k>
       <ltime> T:Int => T +Int maxInt($log(I1), $log(I2)) </ltime>
       <utime> T':Int => T' +Int 1 </utime>

  rule <k> I1:Int > I2:Int => (I1 >Int I2) ...</k>
       <ltime> T:Int => T +Int maxInt($log(I1), $log(I2)) </ltime>
       <utime> T':Int => T' +Int 1 </utime>

  rule <k> I1:Int <= I2:Int => (I1 <=Int I2) ...</k>
       <ltime> T:Int => T +Int maxInt($log(I1), $log(I2)) </ltime>
       <utime> T':Int => T' +Int 1 </utime> 


  rule <k> I1:Int >= I2:Int => (I1 >=Int I2) ...</k>
       <ltime> T:Int => T +Int maxInt($log(I1), $log(I2)) </ltime>
       <utime> T':Int => T' +Int 1 </utime> 

  rule <k> I1:Int == I2:Int => (I1 ==Int I2) ...</k>
       <ltime> T:Int => T +Int maxInt($log(I1), $log(I2)) </ltime>
       <utime> T':Int => T' +Int 1 </utime> 

  rule <k> I1:Int != I2:Int => (I1 =/=Int I2) ...</k>
       <ltime> T:Int => T +Int maxInt($log(I1), $log(I2)) </ltime>
       <utime> T':Int => T' +Int 1 </utime> 

  rule F1 * F2 => F1 *Float F2
  rule F1 / F2 => F1 /Float F2
  rule F1 % F2 => F1 %Float F2
  rule F1 + F2 => F1 +Float F2
  rule F1 - F2 => F1 -Float F2

  rule F1:Float != F2:Float => F1 =/=Float F2 
  rule F1:Float == F2:Float => F1 ==Float F2 
  rule F1:Float < F2:Float => F1 <Float F2 
  rule F1:Float <= F2:Float => F1 <=Float F2 
  rule F1:Float >= F2:Float => F1 >=Float F2
  rule F1:Float > F2:Float => F1 >Float F2  

  rule sin(F:Float) => sinFloat(F)
  rule cos(F:Float) => cosFloat(F)
  rule tan(F:Float) => tanFloat(F)
  rule asin(F:Float) => asinFloat(F)
  rule acos(F:Float) => acosFloat(F)
  rule atan(F:Float) => atanFloat(F)

  rule sqrt(F:Float) => sqrtFloat(F)
  rule ceil(F:Float) => ceilFloat(F)
  rule floor(F:Float) => floorFloat(F)
  rule int(F:Float) => Float2Int(F)

  rule random(I:Int) => randomRandom(I)
       [transition]

  rule choose X:Id in S:Value;
       =>
       if (S.size() > 0)
          X = S[random(S.size())];
       else
         failure;

  syntax Id ::= "$l" [token] 

  rule choose X:Id in S:Value s.t. B ;
       =>
       $l = emptyList;
       for ($i = 0; $i < S.size(); ++$i) {
         X = S[$i];
         if (B) $l.pushBack(X);
       }
       if ($l.size() > 0 ) 
         choose X in $l;
       else
         failure;

  rule (success; ~> K) => success; 
    requires K =/=K .K

  rule (failure; ~> K) => failure; 
    requires K =/=K .K

  rule <k> success; </k>
       <state> Sigma:Map => $cleanup(Sigma) </state>
    requires $isNotClean(Sigma)

  rule <k> failure; </k>
       <state> Sigma:Map => $cleanup(Sigma) </state>
    requires $isNotClean(Sigma)

  rule <k> .K </k>
       <state> Sigma:Map => $cleanup(Sigma) </state>
    requires $isNotClean(Sigma)

// not complete
  syntax Bool ::= "$isNotClean" "(" Map ")" [function]
  rule $isNotClean(M) => ($i in keys(M)) orBool ($l in keys(M))

  syntax Map ::= "$cleanup" "(" Map ")" [function]
  rule $cleanup(M) => removeAll(M, (SetItem($i) SetItem($l)))

  rule emptyList => < .ValueList >

/*
  rule true && B:Exp => B 
  rule false && B:Exp => false 
  rule true || B:Exp => true
  rule false || B:Exp => B
  rule !true => false
  rule !false => true 
*/

  rule <k> true && B:Exp => B ...</k>
       <ltime> T:Int => T +Int 1 </ltime>
       <utime> T':Int => T' +Int 1 </utime>

  rule <k> false && B:Exp => false...</k>
       <ltime> T:Int => T +Int 1 </ltime>
       <utime> T':Int => T' +Int 1 </utime> 

  rule <k> true || B:Exp => true ...</k>
       <ltime> T:Int => T +Int 1 </ltime>
       <utime> T':Int => T' +Int 1 </utime>

  rule <k> false || B:Exp => B ...</k>
       <ltime> T:Int => T +Int 1 </ltime>
       <utime> T':Int => T' +Int 1 </utime>

  rule <k> ! false  => true ...</k>
       <ltime> T:Int => T +Int 1 </ltime>
       <utime> T':Int => T' +Int 1 </utime>

  rule <k> ! true => false ...</k>
       <ltime> T:Int => T +Int 1 </ltime>
       <utime> T':Int => T' +Int 1 </utime>

// "at" "(" Exp ")"
//  rule V:Value.at(I:Int) => V.$lookup(I)

  rule <k> V:Value.at(I:Int) => V.$lookup(I) ...</k>
       <ltime> T:Int => T +Int $log(V.$lookup(I)) </ltime>
       <utime> T':Int => T' +Int 1 </utime>

// "topFront" "(" ")"
//  rule V:Value.topFront() => V.$lookup(0)

  rule <k> V:Value.topFront() => V.$lookup(0) ...</k>
       <ltime> T:Int => T +Int $log(V.$lookup(0)) </ltime>
       <utime> T':Int => T' +Int 1 </utime>

// "topBack" "(" ")"
//  rule V:Value.topBack() => V.$lookup(V.$size() -Int 1)

  rule <k> V:Value.topBack() => V.$lookup(V.$size() -Int 1) ...</k>
       <ltime> T:Int => T +Int $log(V.$lookup(V.$size() -Int 1)) </ltime>
       <utime> T':Int => T' +Int 1 </utime>

// "size" "(" ")"
//  rule V:Value.size() => V.$size() 

  rule <k> V:Value.size() => V.$size() ...</k>
       <ltime> T:Int => T +Int $log(V.$size()) </ltime>
       <utime> T':Int => T' +Int 1 </utime>

// Exp "." "update" "(" Exp "," Exp ")"
//  rule V:Value.update(I:Int, V':Value) => V.$update(I, V')

  rule <k> V:Value.update(I:Int, V':Value) => V.$update(I, V') ...</k>
       <ltime> T:Int => T +Int $log(V') </ltime>
       <utime> T':Int => T' +Int 1 </utime>

// Exp "." "insert" "(" Exp "," Exp ")"
//  rule V:Value.insert(I:Int, V':Value) => V.$insert(I, V')

  rule <k> V:Value.insert(I:Int, V':Value) => V.$insert(I, V') ...</k>
       <ltime> T:Int => T +Int I +Int $log(V') </ltime>
       <utime> T':Int => T' +Int I </utime>


// Exp "." "removeAt" "(" Exp ")"
//  rule V:Value.removeAt(I:Int) => V.$removeAt(I)

  rule <k> V:Value.removeAt(I:Int) => V.$removeAt(I) ...</k>
       <ltime> T:Int => T +Int I </ltime>
       <utime> T':Int => T' +Int I </utime>

// Exp "." "removeAllEqTo" "(" Exp ")"
//  rule V:Value.removeAllEqTo(V':Value) => V.$removeAllEqTo(V')

  rule <k> V:Value.removeAllEqTo(V':Value) => V.$removeAllEqTo(V') ...</k>
       <ltime> T:Int => T +Int (V.$size() *Int $log(V')) </ltime>  // it is an approximation
       <utime> T':Int => T' +Int V.$size() </utime>

// Exp "." "pushFront" "(" Exp ")"
//  rule V:Value.pushFront(V':Value) => V.$insert(0, V')

  rule <k> V:Value.pushFront(V':Value) => V.$insert(0, V') ...</k>
       <ltime> T:Int => T +Int $log(V') </ltime>  
       <utime> T':Int => T' +Int 1 </utime>

// Exp "." "pushBack" "(" Exp ")"
//  rule V:Value.pushBack(V':Value) => V.$insert(V.$size(), V')

  rule <k> V:Value.pushBack(V':Value) => V.$insert(V.$size(), V') ...</k>
       <ltime> T:Int => T +Int $log(V') </ltime>  
       <utime> T':Int => T' +Int 1 </utime>

// Exp "." "popFront" "(" ")"
//  rule V:Value.popFront() => V.$removeAt(0)

  rule <k> V:Value.popFront() => V.$removeAt(0) ...</k>
       <ltime> T:Int => T +Int 1 </ltime>  
       <utime> T':Int => T' +Int 1 </utime>

// Exp "." "popBack" "(" ")"
//  rule V:Value.popBack() => V.$removeAt(V.$size() -Int 1)

  rule <k> V:Value.popBack() => V.$removeAt(V.$size() -Int 1) ...</k>
       <ltime> T:Int => T +Int 1 </ltime>  
       <utime> T':Int => T' +Int 1 </utime>

// "new" "(" Exp ")"
  rule <k> new(V:Value) => ?X:DVar ...</k>
       <state> ST:Map => ST[?X:DVar <- V] </state>

// Exp "[" Exp "]"
  rule <k> (V:Value[I:Int]) => (V.$lookup(I)) ...</k>
       <ltime> T:Int => T +Int $log(V.$lookup(I)) </ltime>
       <utime> T':Int => T' +Int 1 </utime>

// Exp "." Id
  // ValFldList
  rule { X:Id  -> V:Value Vs:ValFldList }.X => V 
  rule { X':Id  -> _:Value Vs:ValFldList }.X => { Vs }.X
    requires X' =/=K X

// Exp ".." Exp
  context HOLE:Exp .. _:Exp
  context _:Exp .. HOLE:Exp
  rule A:Int .. B:Int => $interval2List(A, B)  // [macro]


// Exp "=" Exp

  // updating simple variables
  rule <k> X:Id = V:ExtendedValue => V ...</k>
       <state> St:Map => St[X <- V] </state>

  // updating arrays components
  context _:Exp[HOLE] = _

  rule <k> X:Id[I:Int] = V:ExtendedValue => V'.$update(I, V) ...</k>
       <state>... X |-> (V':Value => V'.$update(I, V)) ...</state>

  rule <k> X:Exp[I:Int] = V:Value => V ...</k>
       <state> St:Map => St[X <- [$initList(I,V)]] </state>
       <ltime> T:Int => T +Int $log(V) </ltime>
       <utime> T':Int => T' +Int 1 </utime>
     requires isId(X) andBool notBool X in keys(St)


  rule <k> X:Exp[I:Int] = V:ExtendedValue => X = $updateVal(I, V) ...</k>
       <state> St:Map </state>
//       requires notBool X in keys(St)
     requires notBool isId(X)

  // updating structures components
  rule <k> X:Id.F:Id = V:ExtendedValue => V'.$update(F, V) ...</k>
       <state>... X |-> (V':Value => V'.$update(F, V)) ...</state>

  rule <k> X:Exp.F:Id = V:Value => X = $updateVal(F, V) ...</k>
       <state> St:Map => St[X <- { F -> V .ValFldList}] </state>
       <ltime> T:Int => T +Int $log(V) </ltime>
       <utime> T':Int => T' +Int 1 </utime>
     requires isId(X) andBool notBool X in keys(St)

  rule <k> X:Exp.F:Id = V:ExtendedValue => X = $updateVal(F, V) ...</k>
       <state> St:Map </state>
//       requires notBool X in keys(St)
     requires notBool isId(X)

  // updating lists components
  context _:Exp.at(HOLE) = _:Exp
  rule (X:Exp.at(I:Int) => X[I]) = _:ExtendedValue
 

// Exp "." "update" "(" Exp "," Exp ")" ";"

  rule X:Exp.update(I:Int, V:Value); => X = X.update(I, V);

// Exp "." "insert" "(" Exp "," Exp ")" ";"

  rule X:Exp.insert(I:Int, V:Value); => X = X.insert(I, V);

// Exp "." "removeAt" "(" Exp ")" ";"

  rule X:Exp.removeAt(I:Int); => X = X.removeAt(I);

// Exp "." "removeAllEqTo" "(" Exp ")" ";"

  rule X:Exp.removeAllEqTo(V:Value); => X = X.removeAllEqTo(V);

// Exp "." "pushFront" "(" Exp ")" ";"

  rule X:Exp.pushFront(V:Value); => X = X.insert(0, V);

// Exp "." "pushBack" "(" Exp ")" ";"

  rule X:Exp.pushBack(V:Value); => X = X.insert(X.size(), V);

// Exp "." "popFront" "(" ")" ";"


  rule X:Exp.popFront(); => X = X.removeAt(0);

// Exp "." "popBack" "(" ")" ";"

  rule X:Exp.popBack(); => X = X.removeAt(X.size() - 1);

// "++" Id
  rule <k> ++ X:Id => V +Int 1 ...</k>
       <state>... X |-> (V:Int => V +Int 1) ...</state>
       <ltime> T:Int => T +Int $log(V +Int 1) </ltime>
       <utime> T':Int => T' +Int 1 </utime>

// "--" Id
  rule <k> -- X:Id => V -Int 1 ...</k>
       <state>... X |-> (V:Int => V -Int 1) ...</state>
       <ltime> T:Int => T +Int $log(V -Int 1) </ltime>
       <utime> T':Int => T' +Int 1 </utime>

// Exp "belongsTo" Exp
//  rule V1:Value belongsTo V2:Value => V1 $in V2

  rule <k> V1:Value belongsTo V2:Value => V1 $in V2 ...</k>
       <ltime> T:Int => T +Int $log(V2) </ltime>
       <utime> T':Int => T' +Int 1 </utime>

// sets

  rule emptySet => { .ValueList }
//  rule { Vs1:ValueList } U { Vs2:ValueList } => { Vs1 $cup Vs2 }

  rule <k> { Vs1:ValueList } U { Vs2:ValueList } => { Vs1 $cup Vs2 } ...</k>
       <ltime> T:Int => T +Int (Vs1.$size() *Int $logs(Vs2)) </ltime>  // an approximation
       <utime> T':Int => T' +Int 1 </utime>

//  rule { Vs1:ValueList } ^ { Vs2:ValueList } => { Vs1 $cap Vs2 }

  rule <k> { Vs1:ValueList } ^ { Vs2:ValueList } => { Vs1 $cap Vs2 } ...</k>
       <ltime> T:Int => T +Int (Vs1.$size() *Int $logs(Vs2)) </ltime>  // an approximation
       <utime> T':Int => T' +Int 1 </utime>

//  rule { Vs1:ValueList } \ { Vs2:ValueList } => { Vs1 $setminus Vs2 }

  rule <k> { Vs1:ValueList } \ { Vs2:ValueList } => { Vs1 $setminus Vs2 } ...</k>
       <ltime> T:Int => T +Int (Vs2.$size() *Int $logs(Vs2)) </ltime>  // an approximation
       <utime> T':Int => T' +Int 1 </utime>

  // statements

  rule V:Value; => .
  rule {} => .
  rule { S:Stmt } => S 
  rule if (E:Exp) S:Stmt => if (E) S else {}
  rule if (true) S:Stmt else _ => S
  rule if (false) _ else S:Stmt => S
  rule while (E:Exp) S:Stmt => if (E) { S while (E) S }

  syntax Id ::= "$i" [token]
  rule forall X:Id in V:Value S:Stmt => $i = 0; while ($i < V.$size()) { X = V[$i]; S $i = $i + 1; }  
  rule for (X:Id = E1:Exp;  E2:Exp; E3:VarUpdate) S:Stmt
       => X = E1; while(E2) { S E3; }
       

  rule St1:Stmt St2:Stmt => St1 ~> St2

// function declaration

  syntax Value ::= "lambda" "(" Ids ")" "." Stmt
  rule <k> F:Id (Ps:Ids) { St:Stmt } => .K ...</k>
       <state>... .Map => F |-> lambda(Ps).{St} ...</state>

/* Function Call
  - the current program-state together with the formal parameters are saved on the stack
  - the actual parameters (arguments) are evaluated and then the formal paramaters are
    bound to their corresponding values
  - then the body of the function is executed
*/
  syntax KItem ::= "[" K "," Map "," Ids "]"
  rule <k> (lambda(Ps:Ids).St:Stmt(Es:Exps) ~> K:K)
           =>
           (evaluate Es to .ValueList ~> 
           bindParams Ps to HOLE ~> St ~> 
           return 0;) 
       </k> 
       <state> Sigma:Map </state>
       <stack> .List => ListItem([K, Sigma, Ps]) ...</stack>

// evaluation of the  arguments
  syntax ValueList ::= "evaluate" Exps "to" ValueList 
  context evaluate HOLE, _ to _
  rule evaluate (V:Value, Es:Exps => Es) to (Vs:ValueList => $append(V, Vs))
  rule (evaluate .Exps to Vs ~> bindParams Ps to HOLE) => bindParams Ps to Vs

// binding the formal parameters to their  corresponding values
  syntax Values ::= "bindParams" Ids "to" Exps 
  rule <k> bindParams (P:Id, Ps:Ids => Ps) to (V:Value, Vs:ValueList => Vs) ...</k> 
       <state> Sigma:Map => updateMap(Sigma, P |-> V) </state>

  rule bindParams .Ids to .Exps => .K

/* Return
    case 1, the high of the stack is > 1 : 
    - restore the code to be executed after call, this is on the top of the stack
    - restore the state that is updated with the possible new values of those global names
      that are not hidden by the formal parameters (the global names updated by the
      function body)
    Note that the global names are always found on the bottom of the stack.
*/
  rule <k> (return V:Value; ~> _) => V ~> K </k>
       <state> Sigma:Map => 
               updateMap(Sigma', removeAll(Sigma, keys(Sigma) -Set (keys(getGlobals(Stack)) -Set ids2Set(Ps))))
       </state>
       <stack> (ListItem([K:K, Sigma':Map, Ps:Ids]) Stack:List) => Stack </stack>
    requires Stack =/=K .List
/* case 2, the stack has just one element - hence its state component includes the global names:
   - the restored state is obtained from the current state by removing the non-global names;
     if there are global variables hidden by the formal parameters, then their old values are
     restored
*/
  rule <k> (return V:Value; ~> _) => V ~> K </k>
       <state> Sigma:Map => 
               updateMap(removeAll(Sigma, keys(Sigma) -Set keys(Sigma')),removeAll(Sigma', keys(Sigma') -Set ids2Set(Ps)))
       </state>
       <stack> ListItem([K:K, Sigma':Map, Ps:Ids]) => .List </stack>

  syntax Map ::= getGlobals(List) [function]
  rule getGlobals(.List) => .Map
  rule getGlobals(ListItem([_, G:Map, _]) .List) => G
  rule getGlobals(ListItem([_,_,_]) Stack:List) => getGlobals(Stack)
    requires Stack =/=K .List


// final state

  rule <k> .K </k>
       (<stack> _ </stack> => .Bag)  

/*
   \section{Internal Operations}
*/

  syntax ValueOrValueList ::= Value | ValueList

  syntax Value ::= ValueOrValueList "." "$lookup" "(" Value ")" [function]

  // cons lists
  rule (V:Value, Vs:ValueList).$lookup(0) => V 
  rule (V:Value, Vs:ValueList).$lookup(I:Int) => Vs.$lookup(I -Int 1)
    requires I >Int 0 ==K true

  // array values
  rule [ Vs:ValueList ].$lookup(I:Int) => Vs.$lookup(I)

  // linear lists
  rule < Vs:ValueList >.$lookup(I:Int) => Vs.$lookup(I)

  // sets 
  rule { Vs:ValueList }.$lookup(I:Int) => Vs.$lookup(I)

  syntax Int ::= ValueOrValueList "." "$size" "("  ")" [function]

  // cons lists
  rule (.ValueList).$size() => 0 
  rule (V:Value, Vs:ValueList).$size() => Vs.$size() +Int 1

  // array values
  rule [ Vs:ValueList ].$size() => Vs.$size()

  // linear lists
  rule < Vs:ValueList >.$size() => Vs.$size()

  // sets 
  rule { Vs:ValueList }.$size() => Vs.$size()

  syntax  Value ::= Value "." "$update" "(" Int "," ExtendedValue ")" [function]
  syntax  ValueList ::= ValueList "." "$update" "(" Int "," ExtendedValue ")" [function]
  syntax  ValueOrValueList ::= ValueOrValueList "." "$update" "(" Int "," ExtendedValue ")" [function]

  // cons lists
  rule (V:Value, Vs:ValueList).$update(0, V':Value) => V' , Vs 
  rule (V:Value, Vs:ValueList).$update(0, $updateVal(I:Int, V')) => V.$update(I, V'), Vs
  rule (V:Value, Vs:ValueList).$update(0, $updateVal(F:Id, V')) => V.$update(F, V'), Vs
  rule (V:Value, Vs:ValueList).$update(0, $insertVal(I:Int, V')) => V.$insert(I, V'), Vs
  rule ((V:Value, Vs:ValueList).$update(0, $removeAtVal(V'))) => (V.$removeAt(V'), Vs)
  rule ((V:Value, Vs:ValueList).$update(0, $removeAllEqToVal(V'))) => (V.$removeAllEqTo(V'), Vs)
  rule ((V:Value, Vs:ValueList).$update(I, V')) => (V, (Vs.$update(I -Int 1, V')))
    requires I >Int 0
  rule .ValueList.$update(I, V') => $initList(I,V')
  
  // arrays
  rule [ Vs:ValueList ].$update(I:Int, V) => [ Vs.$update(I,V) ]

  // linear lists 
  rule < Vs:ValueList >.$update(I:Int, V) => < Vs.$update(I, V) >

  // sets 
  rule { Vs:ValueList }.$update(I:Int, V) => { Vs.$update(I, V) }

  syntax  ValFldList ::= ValFldList "." "$update" "(" Id "," ExtendedValue ")" [function]
  syntax  Value ::= Value "." "$update" "(" Id "," ExtendedValue ")" [function]

  // field lists
  rule ((F:Id -> V:Value) Vs:ValFldList).$update(F, V':Value) => (F -> V') Vs 
  rule ((F:Id -> V:Value) Vs:ValFldList).$update(F, $updateVal(I:Int, V')) => (F -> V.$update(I, V')) Vs
  rule ((F:Id -> V:Value) Vs:ValFldList).$update(F, $updateVal(F':Id, V')) => (F -> V.$update(F', V')) Vs
  rule ((F:Id -> V:Value) Vs:ValFldList).$update(F, $insertVal(I:Int, V')) => (F -> V.$insert(I, V')) Vs
  rule (((F:Id -> V:Value) Vs:ValFldList).$update(F, $removeAtVal(V'))) => ((F -> V.$removeAt(V')) Vs)
  rule (((F:Id -> V:Value) Vs:ValFldList).$update(F, $removeAllEqToVal(V'))) => ((F -> V.$removeAllEqTo(V')) Vs)
  rule (((F:Id -> V:Value) Vs:ValFldList).$update(F':Id, V')) => ((F -> V) (Vs.$update(F', V')))
    requires F =/=K F'
  rule .ValFldList.$update(F':Id, V') => F' -> V' .ValFldList

  // structures
  rule { Vs:ValFldList }.$update(F, V:ExtendedValue) => { Vs.$update(F, V) }


  syntax  Value ::= Value "." "$insert" "(" Int "," ExtendedValue ")" [function]
  syntax  ValueList ::= ValueList "." "$insert" "(" Int "," ExtendedValue ")" [function]
  syntax  ValueOrValueList ::= ValueOrValueList "." "$insert" "(" Int "," ExtendedValue ")" [function]


  // cons lists 
  rule Vs:ValueList.$insert(0, V:Value) => V , Vs 
  rule (V:Value, Vs:ValueList).$insert(I:Int, V') => V, (Vs.$insert(I -Int 1, V'))
    requires I >Int 0

  // arrays
  rule [ Vs:ValueList ].$insert(I:Int, V:Value) => [ Vs.$insert(I,V) ]


  // linear lists
  rule < Vs:ValueList >.$insert(I:Int, V:Value) => < Vs.$insert(I,V) >

  // sets
  rule { Vs:ValueList }.$insert(I:Int, V:Value) => { Vs.$insert(I,V) }

  syntax  Value ::= Value "." "$removeAt" "(" Int ")" [function]
  syntax  ValueList ::= ValueList "." "$removeAt" "(" Int ")" [function]
  syntax  ValueOrValueList ::= ValueOrValueList "." "$removeAt" "(" Int ")" [function]


  // cons lists 
  rule (V:Value, Vs:ValueList).$removeAt(0) => Vs 
  rule (V:Value, Vs:ValueList).$removeAt(I:Int) => V, (Vs.$removeAt(I -Int 1))
    requires I >Int 0

  // arrays
  rule [ Vs:ValueList ].$removeAt(I:Int) => [ Vs.$removeAt(I) ]

  // linear lists
  rule < Vs:ValueList >.$removeAt(I:Int) => < Vs.$removeAt(I) >

  // sets
  rule { Vs:ValueList }.$removeAt(I:Int) => { Vs.$removeAt(I) }

  syntax  Value ::= Value "." "$removeAllEqTo" "(" Value ")" [function]
  syntax  ValueList ::= ValueList "." "$removeAllEqTo" "(" Value ")" [function]
  syntax  ValueOrValueList ::= ValueOrValueList "." "$removeAllEqTo" "(" Value ")" [function]


  // cons lists 
  rule .ValueList.$removeAllEqTo(V) => .ValueList 
  rule (V:Value, Vs:ValueList).$removeAllEqTo(V) => Vs.$removeAllEqTo(V) 
  rule (V:Value, Vs:ValueList).$removeAllEqTo(V':Value) => V, (Vs.$removeAllEqTo(V'))
    requires V =/=K V'

  // arrays
  rule [ Vs:ValueList ].$removeAllEqTo(V:Value) => [ Vs.$removeAllEqTo(V) ]


  // linear lists
  rule < Vs:ValueList >.$removeAllEqTo(V:Value) => < Vs.$removeAllEqTo(V) >

  // sets
  rule { Vs:ValueList }.$removeAllEqTo(V:Value) => { Vs.$removeAllEqTo(V) }


  syntax Bool ::= Value "$in" ValueOrValueList [function, klabel("$in")]

  rule V:Value $in { Vs:ValueList } => V $in Vs
  rule V:Value $in [ Vs:ValueList ] => V $in Vs
  rule V:Value $in < Vs:ValueList > => V $in Vs
  rule V:Value $in (V':Value, _:ValueList) => true 
    requires V ==K V'  // TODO: V ==Value V'
  rule V:Value $in (V':Value, Vs:ValueList) => V:Value $in Vs
    requires V =/=K V'     // TODO: notBool V ==Value V'
  rule V:Value $in .ValueList => false


  syntax Bool ::= "$isSet" "(" ValueList ")" [function]
  rule $isSet(.ValueList) => true
  rule $isSet(V:Value, Vs:ValueList) => (notBool V $in Vs) andBool $isSet(Vs)

  syntax ValueList ::= ValueList "$cup" ValueList [function]
  rule Vs1:ValueList $cup (V:Value, Vs2:ValueList) => Vs1 $cup Vs2
    requires V $in Vs1
  rule Vs1:ValueList $cup (V:Value, Vs2:ValueList) => (V, Vs1) $cup Vs2
    requires notBool (V $in Vs1)
  rule Vs1:ValueList $cup .ValueList => Vs1

  syntax ValueList ::= ValueList "$cap" ValueList [function]
  rule Vs1:ValueList $cap (V:Value, Vs2:ValueList) => V, (Vs1 $cap Vs2)
    requires V $in Vs1
  rule Vs1:ValueList $cap (V:Value, Vs2:ValueList) => Vs1 $cap Vs2
    requires notBool (V $in Vs1)
  rule Vs1:ValueList $cap .ValueList => .ValueList

  syntax ValueList ::= ValueList "$setminus" ValueList [function]
  rule (V:Value, Vs1:ValueList) $setminus Vs2:ValueList => Vs1 $setminus Vs2
    requires V $in Vs2
  rule (V:Value, Vs1:ValueList) $setminus Vs2:ValueList => V, (Vs1 $setminus Vs2)
    requires notBool (V $in Vs2)
  rule .ValueList $setminus Vs2:ValueList => .ValueList

  syntax ValueList ::= "$interval2List" "(" Int "," Int ")" [function]

  rule $interval2List(A:Int, B:Int) => .ValueList
    requires A >Int B

  rule  $interval2List(A:Int, B:Int) => A, $interval2List(A +Int 1, B)
    requires A <=Int B

  syntax ValueList ::= "$append" "(" Value "," ValueList ")" [function]
  rule $append(V:Value, .ValueList) => (V, .ValueList)
  rule $append(V:Value, (V':Value, Vs:ValueList)) => (V', $append(V:Value, Vs))

  syntax ValueList ::= "$initList" "(" Int "," Value ")" [function]
  rule $initList(0, V) => V, .ValueList
  rule $initList(I, V) => 0, $initList(I -Int 1, V)
    requires I >Int 0

  syntax Set ::= ids2Set(Ids) [function]
  rule ids2Set(.Ids) => .Set
  rule ids2Set(X:Id, Xs:Ids)  => SetItem(X) ids2Set(Xs)

  syntax Int ::= "$log" "(" Value ")" [function]

  rule $log(I:Int) => 1 +Int $log(I /Int 2) requires I >Int 1
  rule $log(1) => 0 
  rule $log(0) => 0 

  rule $log(I:Int) => $log(0 -Int I) requires I <Int 0

  rule $log({ Vs:ValueList }) => $logs(Vs)
  rule $log([ Vs:ValueList ]) => $logs(Vs)
  rule $log(< Vs:ValueList >) => $logs(Vs)

  rule $log({ Vfs:ValFldList }) => $logfs(Vfs)

  syntax Int ::= "$logs" "(" ValueList ")" [function]

  rule $logs(.ValueList) => 0
  rule $logs(V:Value, Vs:ValueList) => $log(V) +Int $logs(Vs)

  syntax Int ::= "$logfs" "(" ValFldList ")" [function]

  rule $logfs(.ValFldList) => 0
  rule $logfs((_ -> V:Value) Vfs:ValFldList) => $log(V) +Int $logfs(Vfs)
endmodule