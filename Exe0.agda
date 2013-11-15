module Exe0 where

open import Basics

{-----------------------------------------------------------------------------
TOP TIP: if you have annoyingly many open goals, comment out big chunks of the
file with a multi-line comment a bit like this one.
-----------------------------------------------------------------------------}


{----------------------------------------------------------------------------}
{- 1.1: Tree Sort                                                           -}
{----------------------------------------------------------------------------}

-- 1.1.1 implement concatenation for lists

data List (X : Set) : Set where
  <>   : List X
  _,_  : X -> List X -> List X

_++_ : {X : Set} -> List X -> List X -> List X
<> ++ ys = ys
x , xs ++ ys = x , (xs ++ ys)

infixr 3 _++_

-- a datatype of node-labelled binary trees is given as follows

data Tree (X : Set) : Set where
  leaf     : Tree X
  _<[_]>_  : Tree X -> X -> Tree X -> Tree X

-- 1.1.2 implement the insertion of a number into a tree, ensuring that
-- the numbers in the tree are in increasing order from left to right;
-- make sure to retain duplicates

data Nat : Set where
  zero : Nat
  suc : Nat -> Nat
{-# BUILTIN NATURAL Nat #-}
{-# BUILTIN ZERO zero #-}
{-# BUILTIN SUC suc #-}


_<=_ : Nat -> Nat -> Two
zero   <=  n      = tt
suc m  <=  zero   = ff
suc m  <=  suc n  = m <= n

insertTree : Nat -> Tree Nat -> Tree Nat
insertTree n leaf = leaf <[ n ]> leaf
insertTree n (t <[ x ]> t₁) with n <= x
insertTree n (t <[ x ]> t₁) | tt = (insertTree n t) <[ x ]> t₁
insertTree n (t <[ x ]> t₁) | ff = t <[ x ]> (insertTree n t₁)

-- 1.1.3 implement the function which takes the elements of a list and
-- builds an ordered tree from them, using insertTree

makeTree : List Nat -> Tree Nat
makeTree <> = leaf
makeTree (x , xs) = insertTree x (makeTree xs)

-- 1.1.4 implement the function which flattens a tree to a list,
-- using concatenation

flatten : {X : Set} -> Tree X -> List X
flatten leaf = <>
flatten (t <[ x ]> t₁) = (flatten t) ++ (x , flatten t₁)

-- 1.1.5 using the above components, implement a sorting algorithm which
-- works by building a tree and then flattening it

treeSort : List Nat -> List Nat
treeSort ts = flatten (makeTree ts)

-- 1.1.6 give a collection of unit tests which cover every program line
-- from 1.1.1 to 1.1.5

myTest : (treeSort (3 , 1 , 2 , <>)) == (1 , 2 , 3 , <>)
myTest = refl

testConcatenation : ((1 , 2 , 3 , <>) ++ (4 , <>)) == (1 , 2 , 3 , 4 , <>)
testConcatenation = refl

testInsert : (insertTree 5 ((leaf <[ 3 ]> (leaf <[ 7 ]> leaf)))) == (leaf <[ 3 ]> ((leaf <[ 5 ]> leaf) <[ 7 ]> leaf))
testInsert = refl

testFlatten : (flatten (leaf <[ 1 ]> (( leaf <[ 2 ]> leaf) <[ 3 ]> leaf))) == (1 , 2 , 3 , <>)
testFlatten = refl

testTreeSort : (treeSort (3 , 1 , 2 , <>)) == (1 , 2 , 3 , <>)
testTreeSort = refl

-- 1.1.7 implement a fast version of flatten, taking an accumulating parameter,
-- never using ++. and ensuring that the law
--
--   fastFlatten t xs == flatten t ++ xs
--
-- is true; for an extra style point, ensure that the accumulating parameter
-- is never given a name in your program

fastFlatten : {X : Set} -> Tree X -> List X -> List X
fastFlatten leaf acc = acc
fastFlatten (l <[ x ]> r) acc = fastFlatten l (x , fastFlatten r acc)

-- 1.1.8 use fastFlatten to build a fast version of tree sort

fastTreeSort : List Nat -> List Nat
fastTreeSort xs = fastFlatten (makeTree xs) <>

-- 1.1.9 again, give unit tests which cover every line of code

fastFlattenTest : (fastFlatten (leaf <[ 1 ]> (( leaf <[ 2 ]> leaf) <[ 3 ]> leaf)) <>) == (1 , 2 , 3 , <>)
fastFlattenTest = refl

myfastTest : (fastTreeSort (3 , 1 , 2 , <>)) == (1 , 2 , 3 , <>)
myfastTest = refl

{----------------------------------------------------------------------------}
{- 1.2: Shooting Propositional Logic Fish In A Barrel                       -}
{----------------------------------------------------------------------------}

-- 1.2.1 implement the following operations; try to use only
--   [C-c C-c] and [C-c C-a]

inl : {A B : Set} -> A -> A + B
inl a = tt , a

inr : {A B : Set} -> B -> A + B
inr b = ff , b

orCommute : {A B : Set} -> A + B -> B + A
orCommute (tt , snd) = ff , snd
orCommute (ff , snd) = tt , snd

orAbsorbL : {A : Set} -> Zero + A -> A
orAbsorbL (tt , ())
orAbsorbL (ff , snd) = snd

orAbsorbR : {A : Set} -> A + Zero -> A
orAbsorbR (tt , snd) = snd
orAbsorbR (ff , ())

orAssocR : {A B C : Set} -> (A + B) + C -> A + (B + C)
orAssocR (tt , tt , snd) = tt , snd
orAssocR (tt , ff , snd) = ff , (tt , snd)
orAssocR (ff , snd) = ff , (ff , snd)

orAssocL : {A B C : Set} -> A + (B + C) -> (A + B) + C
orAssocL (tt , snd) = tt , (tt , snd)
orAssocL (ff , tt , snd) = tt , (ff , snd)
orAssocL (ff , ff , snd) = ff , snd

-- 1.2.2 implement the following operations; try to use only
--   [C-c C-c] and [C-c C-a]

andCommute : {A B : Set} -> A * B -> B * A
andCommute (fst , snd) = snd , fst

andAbsorbL : {A : Set} -> A -> One * A
andAbsorbL x = <> , x

andAbsorbR : {A : Set} -> A -> A * One
andAbsorbR x = x , <>

andAssocR : {A B C : Set} -> (A * B) * C -> A * (B * C)
andAssocR ((x , y) , z) = x , y , z

andAssocL : {A B C : Set} -> A * (B * C) -> (A * B) * C
andAssocL (x , y , z) = (x , y) , z

-- how many times is [C-c C-c] really needed?

-- 1.2.3 implement the following operations; try to use only
--   [C-c C-c] and [C-c C-a]

distribute : {A B C : Set} -> A * (B + C) -> (A * B) + (A * C)
distribute (a , tt , b) = tt , (a , b)
distribute (a , ff , c) = ff , (a , c)

factor : {A B C : Set} -> (A * B) + (A * C) -> A * (B + C)
factor (tt , a , b) = a , (tt , b)
factor (ff , a , c) = a , ({!!} , {!!})


-- 1.2.4 try to implement the following operations; try to use only
--   [C-c C-c] and [C-c C-a]; at least one of them will prove to be
--   impossible, in which case you should comment it out and explain
--   why it's impossible

Not : Set -> Set
Not X = X -> Zero

deMorgan1 : {A B : Set} -> (Not A + Not B) -> (A * B) -> Zero
deMorgan1 x = {!!}

deMorgan2 : {A B : Set} -> Not (A * B) -> (Not A + Not B)
deMorgan2 x = {!!}

deMorgan3 : {A B : Set} -> (Not A * Not B) -> (A + B) -> Zero
deMorgan3 x y = {!!}

deMorgan4 : {A B : Set} -> Not (A + B) -> (Not A * Not B)
deMorgan4 x = {!!}


-- 1.2.5 try to implement the following operations; try to use only
--   [C-c C-c] and [C-c C-a]; at least one of them will prove to be
--   impossible, in which case you should comment it out and explain
--   why it's impossible

dnegI : {X : Set} -> X -> Not (Not X)
dnegI x f = {!!}

dnegE : {X : Set} -> Not (Not X) -> X
dnegE = {!!}

neg321 : {X : Set} -> Not (Not (Not X)) -> Not X
neg321 nnnx x = {!!}

hamlet : {B : Set} -> B + Not B
hamlet = {!!}

nnHamlet : {B : Set} -> Not (Not (B + Not B))
nnHamlet noham = {!!}
