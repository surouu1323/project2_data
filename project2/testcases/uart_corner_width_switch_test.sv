class uart_corner_width_switch_test extends uart_base_test;
  `uvm_component_utils(uart_corner_width_switch_test)

  int send_random_data_time = 10; // Number of data packets to send per test
  int test_case_cnt = 10;         // set number of test

  function new(string name="uart_corner_width_switch_test", uvm_component parent);
    super.new(name,parent);
  endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

      // Initial LHS configuration 
      if(uvm_config_db#(uart_configuration)::get(this, "uart_env*", "uart_lhs_cfg", uart_lhs_cfg)) begin
        uart_lhs_cfg.baud_rate    = uart_configuration::B_9600;
        uart_lhs_cfg.parity_mode  = uart_configuration::NONE;
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
    // err_catcher.add_error_catcher_msg("Parity Mismatch!");
    #10us;

    // LOG: Report current test case configuration
    `uvm_info("UART_CFG", $sformatf(">>> [CASE %0d] Applying Config: Baud=%s, Width=%s, Stop=%s, Parity=%s", 
        test_case_cnt,
        uart_lhs_cfg.baud_rate.name(), 
        uart_lhs_cfg.data_width.name(),
        uart_lhs_cfg.stop_bit.name(),
        uart_lhs_cfg.parity_mode.name()), UVM_LOW)

    /*=============  TEST START  ===============*/
    
      for (int i = 0; i< test_case_cnt; i++) begin

        if(i%2) uart_lhs_cfg.data_width   = uart_configuration::D_5b;
        else uart_lhs_cfg.data_width   = uart_configuration::D_9b;

        uart_rhs_cfg.copy(uart_lhs_cfg); // sync RHS config

        // LOG: Report current test case configuration
        `uvm_info("UART_CFG", $sformatf(">>> [CASE %0d] Applying Config: Baud=%s, Width=%s, Stop=%s, Parity=%s", 
            test_case_cnt,
            uart_lhs_cfg.baud_rate.name(), 
            uart_lhs_cfg.data_width.name(),
            uart_lhs_cfg.stop_bit.name(),
            uart_lhs_cfg.parity_mode.name()), UVM_LOW)

        for (int j = 0; j < send_random_data_time; j++) begin
          int rand_val; 
          rand_val = $urandom_range(0, 9'h1FF);
          `uvm_info("UART_DATA", $sformatf("Iteration [%0d/%0d] -> LHS Writing Data", j+1, send_random_data_time), UVM_LOW)
          uart_lhs_write(rand_val);
        end  

          // Wait for the monitor to trigger completion of the transfer sequence
          done_transfer_ev.wait_trigger();
          done_transfer_ev.reset();
          
          `uvm_info("UART_STATUS", $sformatf("<<< [CASE %0d] Sequence completed successfully.\n", test_case_cnt), UVM_LOW)
          #10us;
      end 

    /*=============   TEST END   ===============*/
    `uvm_info("TEST DONE", $sformatf("Total unique configurations swept: %0d", test_case_cnt), UVM_LOW)
    #10us;
    phase.drop_objection(this);
  endtask

endclass

