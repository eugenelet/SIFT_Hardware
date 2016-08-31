## Specified UMC 90nm library ## 
set search_path {  . \
                   ../01_RTL/ \
                   ../00_MEM/ \
                   /Si2_RAID-1/Lib/umc90/SP_RVT/synopsys/ \
                   /Si2_RAID-1/EDA/synopsys/syn_2016.03_linux/libraries/syn/ }
set synthetic_library [list dw_foundation.sldb SHAB90_4096X16X1CM16_WC.db]
set link_library [list l90sprvt_wc.db dw_foundation.sldb SHAB90_4096X16X1CM16_WC.db]
set target_library [list l90sprvt_wc.db dw_foundation.sldb SHAB90_4096X16X1CM16_WC.db]
set symbol_library [list generic.sdb ]
set REPORT_DIR          ./REPORT
set NETLIST_DIR         ./NETLIST

set hdlin_ff_always_sync_set_reset true

###################################################################
## Define Design TOP module name                                  #
###################################################################
set DESIGN      "CORE"  

###################################################################
## Read Verilog RTL source file                                   #
###################################################################
read_verilog -rtl $DESIGN\.v
current_design $DESIGN

###################################################################
## Define Design Constraints                                      #
###################################################################  
create_clock -name "clk" -period 15 clk
set_ideal_network clk

###################################################################
## Wire Load Model                                                #
###################################################################
# mode      : top & segmented
# wire laod : wl10, wl20, wl30, wl40, wl50
#set_wire_load_mode segmented
#set_wire_load_model -name wl50 -library l90sprvt_wc

###################################################################
## Optimize design                                                #
################################################################### 
uniquify
set_fix_multiple_port_nets -all -buffer_constants
set_host_options -max_cores 4
compile  

#using gated clock for low power
#replace_clock_gates -global
#set_clock_gating_style -sequential_cell latch
#insert_clock_gating
#compile_ultra -gate_clock 

## Change netlist naming rule ##
set bus_inference_style "%s\[%d\]"
set bus_naming_style "%s\[%d\]"
set hdlout_internal_busses true

change_names -hierarchy -rule verilog

define_name_rules name_rule -allowed "a-z A-Z 0-9 _" -max_length 255 -type cell
define_name_rules name_rule -allowed "a-z A-Z 0-9 _[]" -max_length 255 -type net
define_name_rules name_rule -map {{"\\*cell\\*" "cell"}}
change_names -hierarchy -rules name_rule

##################################################################
## Report design timing, area                                    #
##################################################################
report_timing   >  $REPORT_DIR/$DESIGN\.timing
report_area     >  $REPORT_DIR/$DESIGN\.area
report_resource >  $REPORT_DIR/$DESIGN\.resource

###################################################################
## Save Design Netlist and SDF/SDC file                           #
################################################################### 
write -format verilog -output $NETLIST_DIR/$DESIGN\_syn.v -hierarchy
write_sdf -version 3.0 -context verilog -load_delay net $NETLIST_DIR/$DESIGN\_syn.sdf
write_sdc  $NETLIST_DIR/$DESIGN\_syn.sdc

report_timing  
report_area   

exit
