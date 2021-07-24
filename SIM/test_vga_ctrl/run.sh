#!/bin/bash -f

option=$1


if [[ ${option} == dump ]]; then
    xsim top -gui
else
    rm -rf xsim.dir
    #xvlog -sv -f ${RTL_DIR}/rtl_list.f -incr -log sim.log
    xvlog -sv -f ${RTL_DIR}/rtl_list.f \
              -f ${SIM_DIR}/lib/bmp_driver/sim_lib.f \
                 testbench.sv -L uvm -define NO_OF_TRANSACTIONS=2000
    xelab testbench -relax -s top -timescale 1ns/1ps  -debug all
    xsim top -testplusarg UVM_TESTNAME=bus_test_base  \
             -testplusarg UVM_VERBOSITY=UVM_LOW -runall \
             -wdb waves.wdb
fi
