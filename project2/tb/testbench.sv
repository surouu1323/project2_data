`timescale 1ns/1ps
module testbench;  
  import uvm_pkg::*;
  import uart_pkg::*;
  import test_pkg::*;

  /** Instantiate UART Interface */
  uart_if lhs_if();
  uart_if rhs_if();
  
  initial begin
    $fsdbDumpfile("inter.fsdb"); // Đổi từ inter.fsdb thành wave.fsdb cho đồng bộ
    $fsdbDumpvars(0, testbench);
  end


  /** Interconnect */
  uart_dut dut(.tx_lhs(lhs_if.rx),
               .rx_lhs(lhs_if.tx),
               .tx_rhs(rhs_if.rx),
               .rx_rhs(rhs_if.tx)
              );

  /** Set the VIP interface on the environment */
  initial begin
    lhs_if.tx = 1;
    rhs_if.tx = 1;
    uvm_config_db#(virtual uart_if)::set(uvm_root::get(),"uvm_test_top","lhs_vif",lhs_if);
    uvm_config_db#(virtual uart_if)::set(uvm_root::get(),"uvm_test_top","rhs_vif",rhs_if);

    /** Start the UVM test */
    run_test();
  end

endmodule


