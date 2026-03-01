class uart_full_duplex_test extends uart_base_test;
  `uvm_component_utils(uart_full_duplex_test)

  function new(string name="uart_full_duplex_test", uvm_component parent);
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


      // Loop to send multiple random data packets per configuration
      /*=============  START LOOP  ===============*/
      fork
        for (int i = 0; i < 1; i++) begin
          int rand_val; 
          rand_val = $urandom_range(0, 9'h1FF);

          `uvm_info("UART_DATA", $sformatf("LHS Writing Data"), UVM_LOW)
            uart_lhs_write(rand_val);
        end
        #1;
        for (int i = 0; i < 1; i++) begin
          int rand_val; 
          rand_val = $urandom_range(0, 9'h1FF);

          `uvm_info("UART_DATA", $sformatf("RHS Writing Data"), UVM_LOW)
            uart_rhs_write(rand_val);
        end
      join
      /*=============   END LOOP   ===============*/

      // Wait transfer done
      done_transfer_ev.wait_trigger();
      done_transfer_ev.reset();      

      #10us;

    /*=============    TEST END    ===============*/
    
    #10us;
    phase.drop_objection(this);
  endtask
endclass
