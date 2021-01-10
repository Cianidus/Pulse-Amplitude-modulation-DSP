vlog filter.v top_corr.v mov_av.v tb_corr.v signal_generator.v top_signal.v sg_driver.v 
vsim -gui -L altera_mf_ver -L altera_mf work.tb_corr -default_radix decimal
add wave -noupdate tb_corr/top_corr/gen_signal/clk
add wave -noupdate tb_corr/top_corr/gen_signal/address_bus
add wave -noupdate tb_corr/top_corr/gen_signal/sg_driver/period
add wave -noupdate -format analog -min 0 -max 6000 -height 100  tb_corr/top_corr/xcross_inst/in
add wave -noupdate -format analog -min 0 -max 6000 -height 100  tb_corr/top_corr/xcross_inst/out
add wave -noupdate tb_corr/top_corr/mov_av_inst/time_point
add wave -noupdate -format analog -min 0 -max 6000 -height 100  tb_corr/top_corr/mov_av_inst/sr
add wave -noupdate tb_corr/top_corr/mov_av_inst/acc
add wave -noupdate tb_corr/top_corr/mov_av_inst/timer
add wave -noupdate tb_corr/top_corr/mov_av_inst/time_mark
add wave -noupdate tb_corr/top_corr/mov_av_inst/time_point
add wave -noupdate tb_corr/top_corr/mov_av_inst/phase_timer
add wave -noupdate tb_corr/top_corr/mov_av_inst/phase_time
add wave -noupdate tb_corr/top_corr/mov_av_inst/phase_mark
add wave -noupdate tb_corr/top_corr/mov_av_inst/max
add wave -noupdate tb_corr/top_corr/mov_av_inst/norm_max_high
add wave -noupdate tb_corr/top_corr/mov_av_inst/norm_max_low
add wave -noupdate tb_corr/top_corr/mov_av_inst/amplitude
configure wave -timelineunits us
run 120 ms
wave zoom full
