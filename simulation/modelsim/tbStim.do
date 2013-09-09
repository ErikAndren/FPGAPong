onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -height 16 /vgatestpattern/Clk
add wave -noupdate -height 16 /vgatestpattern/ARst_N
add wave -noupdate -height 16 /vgatestpattern/HSyncN
add wave -noupdate -height 16 /vgatestpattern/VSyncN
add wave -noupdate -height 16 /vgatestpattern/Red
add wave -noupdate -height 16 /vgatestpattern/Green
add wave -noupdate -height 16 /vgatestpattern/Blue
add wave -noupdate /vgatestpattern/RstSync/AsyncRst
add wave -noupdate /vgatestpattern/RstSync/Clk
add wave -noupdate /vgatestpattern/RstSync/Rst_N
add wave -noupdate /vgatestpattern/PixelClkPll0/c0
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {469014 ps} 0} {{Edit Cursor} {0 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 350
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {29704192 ps}
view wave 
wave clipboard store
wave create -pattern none -portmode in -language vhdl /vgatestpattern/Clk 
wave create -pattern none -portmode in -language vhdl /vgatestpattern/ARst_N 
wave edit invert -start 66444ps -end 1000000ps Edit:/vgatestpattern/ARst_N 
wave modify -driver freeze -pattern clock -initialvalue 0 -period 20ns -dutycycle 50 -starttime 0ns -endtime 3000000ns Edit:/vgatestpattern/Clk 
wave modify -driver freeze -pattern constant -value 1 -starttime 0ns -endtime 3000000ns Edit:/vgatestpattern/ARst_N 
wave edit invert -start 0ps -end 80123ps Edit:/vgatestpattern/ARst_N 
WaveCollapseAll -1
wave clipboard restore
