//=============================================================================
// Project       : UART VIP
//=============================================================================
// Filename      : test_pkg.sv
// Author        : Huy Nguyen
// Company       : NO
// Date          : 20-Dec-2021
//=============================================================================
// Description   : 
//
//
//
//=============================================================================
`ifndef GUARD_UART_TEST_PKG__SV
`define GUARD_UART_TEST_PKG__SV

package test_pkg;
  import uvm_pkg::*;
  import uart_pkg::*;
  import seq_pkg::*;
  import env_pkg::*;

  // Include your file

    `include "uart_base_test.sv" 
    /*========== BASE FUNCTION TEST =========*/
    `include "uart_single_tx_test.sv" 
    `include "uart_single_rx_test.sv" 

    `include "uart_multi_tx_test.sv" 
    `include "uart_multi_rx_test.sv" 

    `include "uart_full_duplex_test.sv" 

    /*========== HALF-DUPLEX CONFIG TEST =========*/
    `include "uart_half_tx_seq_cfg_test.sv"
    `include "uart_half_rx_seq_cfg_test.sv"
    `include "uart_half_tx_random_cfg_test.sv"
    `include "uart_half_rx_random_cfg_test.sv"

    /*========== FULL-DUPLEX CONFIG TEST =========*/
    `include "uart_full_duplex_seq_cfg_test.sv"
    `include "uart_full_duplex_random_cfg_test.sv"

    /*========== CORNER TEST =========*/
    `include "uart_corner_baud_jump_test.sv"
    `include "uart_corner_width_switch_test.sv"
    
endpackage: test_pkg

`endif


