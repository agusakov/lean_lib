import data.list.basic

inductive pos_list (α : Type) : Type 
| const : α → pos_list
| cons : α → pos_list → pos_list

namespace pos_list

variable {α : Type}
variables (p q r : pos_list α)

def steps : pos_list α → list (α × α) 
| (const a) := list.nil
| (cons a (const b)) := [⟨a,b⟩]
| (cons a (cons b p)) := ⟨a,b⟩ :: (cons b p).steps

def length : pos_list α → ℕ 
| (const a) := 0
| (cons a p) := p.length.succ

lemma steps_length : ∀ p : pos_list α, p.steps.length = p.length
| (const a) := rfl
| (cons a (const b)) := rfl
| (cons a (cons b p)) := by {
    rw[steps,length,← steps_length (cons b p),list.length],
  }

def to_list : pos_list α → list α 
| (const a) := [a]
| (cons a p) := list.cons a (to_list p)

lemma to_list_length : ∀ p : pos_list α, p.to_list.length = p.length.succ
| (const a) := rfl
| (cons a p) := by {rw[to_list,length,list.length,p.to_list_length],}

def head : pos_list α → α 
| (const a) := a
| (cons a p) := a

def foot : pos_list α → α 
| (const a) := a
| (cons a p) := p.foot

def append : pos_list α → pos_list α → pos_list α
| (const a) q := cons a q
| (cons a p) q := cons a (append p q)

lemma head_append : ∀ (p q : pos_list α),
 head (append p q) = head p
| (const a) q := rfl
| (cons a p) q := rfl

lemma foot_append : ∀ (p q : pos_list α),
 foot (append p q) = foot q
| (const a) q := rfl
| (cons a p) q := foot_append p q

lemma append_assoc : ∀ (p q r : pos_list α), 
 append (append p q) r = append p (append q r)
| (const a) q r := rfl
| (cons a p) q r := by {dsimp[append],rw[append_assoc p q r],}

lemma length_append : ∀ (p q : pos_list α), 
 length (append p q) = p.length + q.length + 1
| (const a) q := by {rw[append,length,length,zero_add],}
| (cons a p) q := by {
    rw[append,length,length,length_append p q,← nat.add_one,← nat.add_one],
    rw[add_assoc p.length 1 q.length,add_comm 1 q.length],
    repeat { rw[add_assoc] },
  }

lemma steps_cons : ∀ (a : α) (p : pos_list α), 
 steps (cons a p) = ⟨a,p.head⟩ :: p.steps
| a (const b) := rfl
| a (cons b p) := rfl

lemma steps_append : ∀ (p q : pos_list α) , 
 steps (append p q) = p.steps ++ (⟨p.foot,q.head⟩ :: q.steps)
| (const a) q := by {rw[append,steps,foot,steps_cons],refl}
| (cons a p) q := by {
    rw[append,steps_cons,steps_cons,foot,head_append],
    rw[steps_append p q,list.cons_append],repeat {rw[list.append_assoc]},
}

def reverse : pos_list α → pos_list α 
| (const a) := const a
| (cons a p) := p.reverse.append (const a)

lemma head_reverse : ∀ (p : pos_list α), p.reverse.head = p.foot
| (const a) := rfl
| (cons a p) := by {dsimp[reverse,foot],rw[head_append,head_reverse p],}

lemma foot_reverse : ∀ (p : pos_list α), p.reverse.foot = p.head
| (const a) := rfl
| (cons a p) := by {dsimp[reverse,head],rw[foot_append],refl,}

lemma reverse_append : ∀ (p q : pos_list α),
 reverse (append p q) = append (reverse q) (reverse p) 
| (const a) q := rfl
| (cons a p) q := by {dsimp[append,reverse],rw[reverse_append p q,append_assoc],}

lemma reverse_reverse : ∀ (p : pos_list α), p.reverse.reverse = p
| (const a) := rfl
| (cons a p) := begin 
 dsimp[reverse],rw[reverse_append,reverse_reverse p],refl,
end

lemma length_reverse : ∀ (p : pos_list α), p.reverse.length = p.length
| (const a) := rfl
| (cons a p) := by {
    rw[reverse,length_append,length,length,length_reverse p],
    rw[← nat.add_one,add_zero (length p)],
}

def swap : (α × α) → (α × α) 
| ⟨a,b⟩ := ⟨b,a⟩

lemma steps_reverse : ∀ (p : pos_list α), 
 p.reverse.steps = (p.steps.map swap).reverse 
| (const a) := rfl
| (cons a p) := by {
 rw[reverse,steps_append,steps_reverse p,foot_reverse,head,steps],
 rw[steps_cons,list.map,swap,list.reverse_cons],
}

def all (r : α → Prop) : pos_list α → Prop
| (const a) := r a
| (cons a p) := (r a) ∧ (all p)

def chain (r : α → α → Prop) : pos_list α → Prop
| (const a) := true
| (cons a (const b)) := r a b
| (cons a (cons b p)) := (r a b) ∧ (chain (cons b p))

def pairwise (r : α → α → Prop) : pos_list α → Prop
| (const a) := true
| (cons a p) := (all (r a) p) ∧ (pairwise p)

def splice0 : ∀ (p q : pos_list α), pos_list α 
| (const a) q := q
| (cons a p) q := cons a (splice0 p q)

lemma length_splice0 : ∀ (p q : pos_list α),
 (splice0 p q).length = p.length + q.length
| (const a) q := by {rw[splice0,length,zero_add],}
| (cons a p) q := by {
    rw[splice0,length,length,length_splice0 p q,← nat.add_one,← nat.add_one],
    rw[add_assoc,add_assoc,add_comm 1],
}

lemma head_splice0 : ∀ (p q : pos_list α) (e : p.foot = q.head),
 (splice0 p q).head = p.head
| (const a) q e := e.symm
| (cons a p) q e := rfl

lemma foot_splice0 : ∀ (p q : pos_list α),
 foot (splice0 p q) = q.foot
| (const a) q := rfl
| (cons a p) q := foot_splice0 p q

lemma splice0_cons_append : ∀ (p : pos_list α) (b : α) (q : pos_list α) (e : p.foot = b),
 splice0 p (cons b q) = append p q
| (const a) b q e := by {rw[splice0,append,← e],refl}
| (cons a p) b q e := by {rw[splice0,append,splice0_cons_append p b q e],}

lemma const_splice0 (a : α) (q : pos_list α) :
 splice0 (const a) q = q := rfl

lemma splice0_const : ∀ (p : pos_list α) (b : α) (e : p.foot = b),
 splice0 p (const b) = p
| (const a) b e := by {rw[splice0],congr,exact e.symm}
| (cons a p) b e := by {rw[splice0,splice0_const p b e],}

lemma splice0_append : ∀ (p q r : pos_list α), 
 splice0 p (append q r) = append (splice0 p q) r 
| (const a) q r := rfl
| (cons a p) q r := by {rw[splice0,splice0,append,splice0_append p q r],}

lemma splice0_assoc : ∀ (p q r : pos_list α),
 splice0 (splice0 p q) r = splice0 p (splice0 q r)
| (const a) q r := rfl
| (cons a p) q r := by {rw[splice0,splice0,splice0,splice0_assoc p q r],}

lemma steps_splice0 : ∀ (p q : pos_list α) (e : p.foot = q.head),
 (splice0 p q).steps = p.steps ++ q.steps
| (const a) q e := by {rw[splice0,steps],refl}
| (cons a p) q e := by {
    change p.foot = q.head at e,
    rw[splice0,steps_cons,steps_cons,steps_splice0 p q e,list.cons_append,head_splice0],
    exact e
  }

lemma reverse_splice0 : ∀ (p q : pos_list α) (e : p.foot = q.head),
 (splice0 p q).reverse = splice0 q.reverse p.reverse
| (const a) q e := by {
    rw[reverse,splice0,splice0_const q.reverse a (q.foot_reverse.trans e.symm)],
  }
| (cons a p) q e := by {
    rw[splice0,reverse,reverse_splice0 p q e,reverse,splice0_append],
  }

def list_between (a b : α) : Type* := 
 { p : pos_list α // p.head = a ∧ p.foot = b }

namespace list_between

def const (a : α) : list_between a a := ⟨pos_list.const a,⟨rfl,rfl⟩⟩

def reverse {a b : α} (p : list_between a b) : list_between b a := 
 ⟨p.val.reverse,⟨p.val.head_reverse.trans p.property.right,
                p.val.foot_reverse.trans p.property.left⟩⟩

def match_eq {a b c : α} (p : list_between a b) (q : list_between b c) :
 p.val.foot = q.val.head := p.property.right.trans q.property.left.symm
  
def splice {a b c : α} (p : list_between a b) (q : list_between b c) :
 (list_between a c) := ⟨splice0 p.val q.val,begin
   rw[head_splice0 p.val q.val (match_eq p q),foot_splice0],
   exact ⟨p.property.left,q.property.right⟩
  end⟩ 

def length {a b : α} (p : list_between a b) : ℕ := p.val.length

lemma length_const (a : α) : (const a).length = 0 := rfl

lemma length_reverse {a b : α} (p : list_between a b) :
 p.reverse.length = p.length := 
  p.val.length_reverse

lemma length_splice {a b c : α} (p : list_between a b) (q : list_between b c) :
 (splice p q).length = p.length + q.length := 
  pos_list.length_splice0 p.val q.val

lemma const_splice {a b : α} (p : list_between a b) : 
 splice (const a) p = p := 
  subtype.eq (const_splice0 a p.val)

lemma splice_const {a b : α} (p : list_between a b) : 
 splice p (const b) = p := 
  subtype.eq (splice0_const p.val b p.property.right)

lemma reverse_splice {a b c : α} (p : list_between a b) (q : list_between b c) :
 (splice p q).reverse = splice q.reverse p.reverse := 
  subtype.eq (reverse_splice0 p.val q.val (match_eq p q)) 

lemma splice_assoc {a b c d : α}
 (p : list_between a b) (q : list_between b c) (r : list_between c d) :
  splice (splice p q) r = splice p (splice q r) := 
   subtype.eq (splice0_assoc p.val q.val r.val)

end list_between




end pos_list
