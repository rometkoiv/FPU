#source ./simulate_topdesign.tcl
#protsessor
add_force {/TopDesign/CLK} -radix bin {1 0ns} {0 5000ps} -repeat_every 10000ps
run 20ns

#reset
add_force {/TopDesign/BTN} -radix bin {00010 0ns}
run 200ns

#Sisend
#Mant A 11
add_force {/TopDesign/SW} -radix bin {0000000000000011 0ns}
run 200ns
add_force {/TopDesign/BTN} -radix bin {00000 0ns}
run 200ns
add_force {/TopDesign/BTN} -radix bin {00001 0ns}
run 200ns
add_force {/TopDesign/BTN} -radix bin {00000 0ns}
run 200ns
#Pow A 1
add_force {/TopDesign/SW} -radix bin {0010000000000001 0ns}
add_force {/TopDesign/BTN} -radix bin {00001 0ns}
run 200ns
add_force {/TopDesign/BTN} -radix bin {00000 0ns}
run 200ns
#Mant B 5
add_force {/TopDesign/SW} -radix bin {0100000000000101 0ns}
add_force {/TopDesign/BTN} -radix bin {00001 0ns}
run 200ns
add_force {/TopDesign/BTN} -radix bin {00000 0ns}
run 200ns
#Pow B 1
add_force {/TopDesign/SW} -radix bin {0110000000000001 0ns}
add_force {/TopDesign/BTN} -radix bin {00001 0ns}
run 200ns
add_force {/TopDesign/BTN} -radix bin {00000 0ns}
run 200ns
#Liidame
add_force {/TopDesign/SW} -radix bin {0000000000000001 0ns}
add_force {/TopDesign/BTN} -radix bin {10000 0ns}
run 200ns
add_force {/TopDesign/BTN} -radix bin {00000 0ns}
run 200ns
add_force {/TopDesign/SW} -radix bin {0010000000000001 0ns}
add_force {/TopDesign/BTN} -radix bin {10000 0ns}
run 200ns
#Lahutame
add_force {/TopDesign/SW} -radix bin {0000000000000001 0ns}
add_force {/TopDesign/BTN} -radix bin {01000 0ns}
run 200ns
add_force {/TopDesign/BTN} -radix bin {00000 0ns}
run 200ns
add_force {/TopDesign/SW} -radix bin {0010000000000001 0ns}
add_force {/TopDesign/BTN} -radix bin {01000 0ns}
run 200ns
#Korrutame
add_force {/TopDesign/SW} -radix bin {0000000000000001 0ns}
add_force {/TopDesign/BTN} -radix bin {00100 0ns}
run 200ns
add_force {/TopDesign/BTN} -radix bin {00000 0ns}
run 200ns
add_force {/TopDesign/SW} -radix bin {0010000000000001 0ns}
add_force {/TopDesign/BTN} -radix bin {00100 0ns}
run 200ns





