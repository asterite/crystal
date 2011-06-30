
define private i32 @"$main1"() {
entry:
  %calltmp = call i32 @"fact$Int$"(i32 4)
  %calltmp1 = call i32 @puti(i32 %calltmp)
  ret i32 %calltmp1
}

declare i32 @puti(i32)

define i32 @"fact$Int$"(i32 %n) {
entry:
  %calltmp = call i1 @"Int#<="(i32 %n, i32 1)
  br i1 %calltmp, label %merge, label %else

else:                                             ; preds = %entry
  %calltmp1 = call i32 @"Int#-"(i32 %n, i32 1)
  %calltmp2 = call i32 @"fact$Int$"(i32 %calltmp1)
  %calltmp3 = call i32 @"Int#*"(i32 %n, i32 %calltmp2)
  br label %merge

merge:                                            ; preds = %entry, %else
  %iftmp = phi i32 [ %calltmp3, %else ], [ 1, %entry ]
  ret i32 %iftmp
}

define private i1 @"Int#<="(i32 %x0, i32 %x1) {
entry:
  %sletmp = icmp sle i32 %x0, %x1
  ret i1 %sletmp
}

define private i32 @"Int#*"(i32 %x0, i32 %x1) {
entry:
  %multmp = mul i32 %x1, %x0
  ret i32 %multmp
}

define private i32 @"Int#-"(i32 %x0, i32 %x1) {
entry:
  %subtmp = sub i32 %x0, %x1
  ret i32 %subtmp
}

define i32 @main() {
entry:
  %0 = call i32 @"$main1"()
  ret i32 0
}
