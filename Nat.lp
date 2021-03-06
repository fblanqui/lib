// Natural numbers

require open Stdlib.Set Stdlib.Prop Stdlib.FOL Stdlib.Eq;

inductive ℕ : TYPE ≔
| zero : ℕ
| s : ℕ → ℕ;

// set code for ℕ

constant symbol nat : Set;

rule τ nat ↪ ℕ;

// Enabling the use of decimal notation

builtin "0"  ≔ zero;
builtin "+1" ≔ s;

assert ⊢ 42 : ℕ;

// is0 predicate

symbol is0 : ℕ → Prop;

rule is0 0 ↪ ⊤
with is0 (s _) ↪ ⊥;

// s _ ≠ 0

opaque symbol s≠0 n : π (s n ≠ 0) ≔
begin
  assume n h; refine ind_eq h is0 top;
end;

// predecessor function

symbol p : ℕ → ℕ;

rule p 0 ↪ 0
with p (s $x) ↪ $x;

// s is injective

opaque symbol s_inj {x y} : π(s x = s y ⇒ x = y) ≔
begin
  assume x y h; apply feq p h;
end;

// Addition

symbol + : ℕ → ℕ → ℕ;

notation + infix left 20;

assert x y z ⊢ x + y + z ≡ (x + y) + z; // check associativity

rule 0 + $y ↪ $y
with s $x + $y ↪ s ($x + $y);

// Addition is commutative

opaque symbol add0r x : π (x + 0 = x) ≔
begin
  induction;
  // case x = 0
  reflexivity;
  // case x = s x'
  assume x' h; simplify; rewrite h; reflexivity;
end;

rule $x + 0 ↪ $x;

opaque symbol addsr x y : π (x + s y = s (x + y)) ≔
begin
  induction;
  // case x = 0
  reflexivity;
  // case x = s x'
  assume x' h y; simplify; rewrite h; reflexivity;
end;

rule $x + s $y ↪ s ($x + $y);

opaque symbol add_com x y : π (x + y = y + x) ≔
begin
  induction;
  // case x = 0
  reflexivity;
  // case x = s x'
  simplify; assume x' h y; rewrite h; reflexivity;
end;

// Addition is associative

opaque symbol add_assoc x y z : π ((x + y) + z = x + (y + z)) ≔
begin
  induction;
  // case x = 0
  reflexivity;
  // case x = s x'
  assume x' h y z; simplify; rewrite h; reflexivity;
end;

rule ($x + $y) + $z ↪ $x + ($y + $z);

// Multiplication

symbol × : ℕ → ℕ → ℕ; // \times

notation × infix left 30;

assert x y z ⊢ x + y × z ≡ x + (y × z); // check priorities

rule 0 × _  ↪ 0
with s $x × $y ↪ $y + $x × $y;

// Multiplication is commutative

opaque symbol mul0r x : π (x × 0 = 0) ≔
begin
  induction;
  // case x = 0
  reflexivity;
  // case x = s x'
  assume x' h; apply h;
end;

rule _ × 0 ↪ 0;

opaque symbol mulsr x y : π (x × s y = x × y + x) ≔
begin
  induction;
  // case x = 0
  reflexivity;
  // case x = s x'
  assume x' h y; simplify; rewrite h; reflexivity;
end;

rule $x × s $y ↪ $x + $x × $y;

opaque symbol mul_com x y : π (x × y = y × x) ≔
begin
  induction;
  // case x = 0
  reflexivity;
  // case x = s x'
  assume x' h y; simplify; rewrite h; reflexivity;
end;

// Multiplication distributes over addition

opaque symbol mul_addl x y z : π ((x + y) × z = x × z + y × z) ≔
begin
  induction;
  // case x = 0
  reflexivity;
  // case x = s x'
  assume x' h y z; simplify; rewrite h; reflexivity;
end;

rule ($x + $y) × $z ↪ $x × $z + $y × $z;

opaque symbol mul_addr x y z : π (z × (x + y) = z × x + z × y) ≔
begin
  assume x y z;
  rewrite mul_com;
  rewrite mul_addl;
  rewrite mul_com;
  rewrite [y × _]mul_com;
  reflexivity;
end;

rule $z × ($x + $y) ↪ $z × $x + $z × $y;

// Multiplication is associative

opaque symbol mul_assoc x y z : π ((x × y) × z = x × (y × z)) ≔
begin
  induction;
  // case x = 0
  reflexivity;
  // case x = s x'
  assume x' h y z; simplify; rewrite h; reflexivity;
end;

rule ($x × $y) × $z ↪ $x × ($y × $z);

// Order on ℕ

constant symbol ≤ : ℕ → ℕ → Prop; notation ≤ infix 10;
constant symbol 0≤ x : π(0 ≤ x);
constant symbol s_mon_≤ x y : π(x ≤ y) → π(s x ≤ s y);

symbol ind_≤ p : (Π x, π(p 0 x))
               → (Π x y, π(x ≤ y) → π(p x y) → π(p (s x) (s y)))
               → Π x y, π(x ≤ y) → π(p x y);

rule ind_≤ _ $a _ _ _ (0≤ $x) ↪ $a $x
with ind_≤ $p $a $b _ _ (s_mon_≤ $x $y $h)
   ↪ $b $x $y $h (ind_≤ $p $a $b $x $y $h);

// ≤ is reflexive

opaque symbol ≤_refl x : π(x ≤ x) ≔
begin
  induction;
  // case x=0
  apply 0≤;
  // case x=s
  assume x h; apply s_mon_≤; apply h;
end;

opaque symbol ≤0 {x} : π(x ≤ 0 ⇒ x = 0) ≔
begin
  // we put in appropriate form for applying induction
  have l : Π x y, π(x ≤ y ⇒ y = 0 ⇒ x = 0);
  refine ind_≤ _ _ _;
  // case 0≤
  reflexivity;
  // case s_mon_≤
  assume x y xy h a; apply ⊥ₑ; apply s≠0 _ a;
  // conclusion
  assume x h; apply l _ _ h _; reflexivity;
end;

opaque symbol ¬s≤0 {x} : π(¬ (s x ≤ 0)) ≔
begin
  assume x h; apply ⊥ₑ; apply s≠0 x; apply ≤0 h;
end;

opaque symbol s≤s {x y} : π(s x ≤ s y ⇒ x ≤ y) ≔
begin
  have l : Π x y, π(x ≤ y ⇒ (`∀ a, x = s a ⇒ (`∀ b, y = s b ⇒ a ≤ b)));
  refine ind_≤ _ _ _;
  // case 0≤
  assume x a h b i; apply ⊥ₑ; apply s≠0; focus 1; symmetry; apply h;
  // case s_mon_≤
  assume x y xy h a i b j;
  have i':π(x = a); apply s_inj i; // allow apply s_inj in i instead ?
  have j':π(y = b); apply s_inj j; // allow apply s_inj in i instead ?
  rewrite left i'; rewrite left j'; apply xy;
  // conclusion
  assume x y xy; apply l _ _ xy; reflexivity; reflexivity;
end;

// ≤ is transitive

opaque symbol ≤_trans x y : π(x ≤ y) → Π z, π(y ≤ z) → π(x ≤ z) ≔
begin
  refine ind_≤ _ _ _;
  // case 0≤
  assume x z _; apply 0≤;
  // case s_mon_≤
  assume x y xy h z i;
  generalize z; induction;
  // case z=0
  assume i; apply ⊥ₑ; apply ¬s≤0 i;
  // case z=s
  assume z i j; apply s_mon_≤; apply h; apply s≤s j;
end;
