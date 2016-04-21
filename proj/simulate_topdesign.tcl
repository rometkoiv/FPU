#protsessor
add_force {/TopDesign/CLK} -radix bin {1 0ns} {0 5000ps} -repeat_every 10000ps
run 20ns
#Sisend
add_force {/TopDesign/SW} -radix bin {0000000000000011 0ns}
run 200ns
add_force {/TopDesign/BTN} -radix bin {00000 0ns}
run 200ns
add_force {/TopDesign/BTN} -radix bin {00001 0ns}
run 200ns
add_force {/TopDesign/SW} -radix bin {0010000000000001 0ns}
add_force {/TopDesign/BTN} -radix bin {00000 0ns}
run 200ns
add_force {/TopDesign/BTN} -radix bin {00001 0ns}
run 200ns
add_force {/TopDesign/SW} -radix bin {0100000000000101 0ns}
add_force {/TopDesign/BTN} -radix bin {00000 0ns}
run 200ns
add_force {/TopDesign/BTN} -radix bin {00001 0ns}
run 200ns
add_force {/TopDesign/SW} -radix bin {0110000000000001 0ns}
add_force {/TopDesign/BTN} -radix bin {00000 0ns}
run 200ns
add_force {/TopDesign/BTN} -radix bin {00001 0ns}
run 200ns

