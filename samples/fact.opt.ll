; ModuleID = 'samples/fact.ll'

declare i32 @puti(i32)

define i32 @"fact$Int$"(i32 %n) nounwind readnone {
entry:
  %sletmp.i1 = icmp slt i32 %n, 2
  br i1 %sletmp.i1, label %merge, label %else.lr.ph

else.lr.ph:                                       ; preds = %entry
  %tmp = add i32 %n, -1
  br label %else

else:                                             ; preds = %else.lr.ph, %else
  %indvar = phi i32 [ 0, %else.lr.ph ], [ %indvar.next, %else ]
  %accumulator.tr2 = phi i32 [ 1, %else.lr.ph ], [ %multmp.i, %else ]
  %n.tr3 = sub i32 %n, %indvar
  %multmp.i = mul i32 %n.tr3, %accumulator.tr2
  %indvar.next = add i32 %indvar, 1
  %exitcond = icmp eq i32 %indvar.next, %tmp
  br i1 %exitcond, label %merge, label %else

merge:                                            ; preds = %else, %entry
  %accumulator.tr.lcssa = phi i32 [ 1, %entry ], [ %multmp.i, %else ]
  ret i32 %accumulator.tr.lcssa
}

define i32 @main() {
entry:
  %calltmp1.i = tail call i32 @puti(i32 24)
  ret i32 0
}
