class uart_half_rx_random_cfg_test extends uart_base_test;
  `uvm_component_utils(uart_half_rx_random_cfg_test)

  // Number of data packets to send per configuration
  int send_random_data_time = 10; // set number of test
  int test_case_time = 10;

  function new(string name="uart_half_rx_random_cfg_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Initial LHS configuration 
    if(uvm_config_db#(uart_configuration)::get(this, "uart_env*", "uart_lhs_cfg", uart_lhs_cfg)) begin
      uart_lhs_cfg.baud_rate    = uart_configuration::B_9600;
      uart_lhs_cfg.parity_mode  = uart_configuration::ODD;
      uart_lhs_cfg.data_width   = uart_configuration::D_8b;
      uart_lhs_cfg.stop_bit     = uart_configuration::STOP_1BIT;
    end 
    
    // Initial RHS configuration
    uart_rhs_cfg.copy(uart_lhs_cfg);
  endfunction

  virtual task main_phase(uvm_phase phase);
    uvm_event done_transfer_ev;
    phase.raise_objection(this);
    done_transfer_ev = uvm_event_pool::get_global("DONE_TRANSFER");

    /*=============  TEST START  ===============*/

    for (int test_case_cnt = 0; test_case_cnt < test_case_time; test_case_cnt++) begin
      // `uvm_info("TEST_SEQ", $sformatf("Starting Iteration %0d/%0d", i+1, test_case_time), UVM_LOW)


      // Randomize configuration for LHS
      if (!uart_lhs_cfg.randomize() with {
          // If data width is 9-bit, parity must be NONE
          (data_width == D_9b) -> (parity_mode == NONE);
          
      }) begin
          `uvm_error("RAND_FAIL", "LHS Randomization failed with constraints!")
      end
      
      // Assign configuration
      uart_rhs_cfg.baud_rate   = uart_lhs_cfg.baud_rate;
      uart_rhs_cfg.parity_mode = uart_lhs_cfg.parity_mode;
      uart_rhs_cfg.data_width  = uart_lhs_cfg.data_width;
      uart_rhs_cfg.stop_bit    = uart_lhs_cfg.stop_bit;
 
      uart_rhs_cfg.copy(uart_lhs_cfg);

      // LOG: Report current test case configuration
      `uvm_info("UART_CFG", $sformatf(">>> [CASE %0d] Applying Config: Baud=%s, Width=%s, Stop=%s, Parity=%s", 
          test_case_cnt,
          uart_lhs_cfg.baud_rate.name(), 
          uart_lhs_cfg.data_width.name(),
          uart_lhs_cfg.stop_bit.name(),
          uart_lhs_cfg.parity_mode.name()), UVM_LOW)


      // Loop to send multiple random data packets per configuration
      for (int i = 0; i < send_random_data_time; i++) begin
        int rand_val; 
        rand_val = $urandom_range(0, 9'h1FF);

        `uvm_info("UART_DATA", $sformatf("Iteration [%0d/%0d] -> RHS Writing Data" ,   i+1, send_random_data_time), UVM_LOW)
          uart_rhs_write(rand_val);
      end

      // Wait transfer done
      done_transfer_ev.wait_trigger();
      done_transfer_ev.reset();      

      `uvm_info("UART_STATUS", $sformatf("<<< [CASE %0d] Sequence completed successfully.\n", test_case_cnt), UVM_LOW)
      #10us;
    end

    /*=============    TEST END    ===============*/
    
    `uvm_info("TEST DONE", $sformatf("Total unique configurations swept: %0d", test_case_time), UVM_LOW)
    #10us;
    phase.drop_objection(this);
  endtask
endclass