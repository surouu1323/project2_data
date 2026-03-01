class uart_multi_rx_test extends uart_base_test;
  `uvm_component_utils(uart_multi_rx_test)

  int send_random_data_time = 10;

  function new(string name="uart_multi_rx_test", uvm_component parent);
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
    `uvm_info("UART_CFG", $sformatf(">>> Applying Config: Baud=%s, Width=%s, Stop=%s, Parity=%s", 
        uart_lhs_cfg.baud_rate.name(), 
        uart_lhs_cfg.data_width.name(),
        uart_lhs_cfg.stop_bit.name(),
        uart_lhs_cfg.parity_mode.name()), UVM_LOW)

    /*=============  TEST START  ===============*/
    
      for (int i = 0; i < send_random_data_time; i++) begin
        int rand_val; 
        rand_val = $urandom_range(0, 9'h1FF);

        `uvm_info("UART_DATA", $sformatf("Iteration [%0d/%0d] -> RHS Writing Data", i+1, send_random_data_time), UVM_LOW)
        uart_rhs_write(rand_val);
      end   

    /*=============   TEST END   ===============*/

    done_transfer_ev.wait_trigger();

    #10us;
    phase.drop_objection(this);
  endtask

endclass

