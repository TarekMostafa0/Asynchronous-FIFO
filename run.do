vlib work
vlog -f file_list.txt
vsim -voptargs=+acc work.FIFO_TB
add wave *
run -all
