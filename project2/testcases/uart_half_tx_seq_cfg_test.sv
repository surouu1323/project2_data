class uart_half_tx_seq_cfg_test extends uart_base_test;
  `uvm_component_utils(uart_half_tx_seq_cfg_test)

  int send_random_data_time = 10; // Number of data packets to send per test
  int test_case_cnt = 10;         // set number of test

  // Type definitions for easier access to enums
  typedef uart_configuration::baud_rate_enum   baud_rate_enum;
  typedef uart_configuration::parity_mode_enum parity_mode_enum;
  typedef uart_configuration::stop_bit_enum    stop_bit_enum;
  typedef uart_configuration::data_width_enum  data_width_enum;

  // Define lists of all possible configurations with explicit scope
  baud_rate_enum   baud_list  [5] = '{uart_configuration::B_4800, 
                                      uart_configuration::B_9600, 
                                      uart_configuration::B_19200, 
                                      uart_configuration::B_57600, 
                                      uart_configuration::B_115200};
                                      
  parity_mode_enum parity_list[3] = '{uart_configuration::ODD, 
                                      uart_configuration::EVEN, 
                                      uart_configuration::NONE};
                                      
  stop_bit_enum    stop_list  [2] = '{uart_configuration::STOP_1BIT, 
                                      uart_configuration::STOP_2BIT};
                                      
  data_width_enum  width_list [5] = '{uart_configuration::D_5b, 
                                      uart_configuration::D_6b, 
                                      uart_configuration::D_7b, 
                                      uart_configuration::D_8b, 
                                      uart_configuration::D_9b};

  function new(string name="uart_half_tx_seq_cfg_test", uvm_component parent);
    super.new(name, parent);
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

    /*=============  TEST START  ===============*/

    foreach (baud_list[b]) begin
      foreach (width_list[w]) begin
        foreach (stop_list[s]) begin
          foreach (parity_list[p]) begin

            // Check for 9-bit data requires Parity to be NONE
            if (width_list[w] == uart_configuration::D_9b && parity_list[p] != uart_configuration::NONE)
              continue;
            
            // Apply new configuration to LHS agent
            uart_lhs_cfg.baud_rate   = baud_list[b];
            uart_lhs_cfg.data_width  = width_list[w];
            uart_lhs_cfg.stop_bit    = stop_list[s];
            uart_lhs_cfg.parity_mode = parity_list[p];
            
            // Synchronize RHS configuration with LHS
            uart_rhs_cfg.copy(uart_lhs_cfg);

            test_case_cnt++;
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

              `uvm_info("UART_DATA", $sformatf("Iteration [%0d/%0d] -> LHS Writing Data" ,   i+1, send_random_data_time), UVM_LOW)
                uart_lhs_write(rand_val);
            end

            // Wait for the monitor to trigger completion of the transfer sequence
            done_transfer_ev.wait_trigger();
            done_transfer_ev.reset();
            
            `uvm_info("UART_STATUS", $sformatf("<<< [CASE %0d] Sequence completed successfully.\n", test_case_cnt), UVM_LOW)
            #10us;
          end
        end
      end
    end

    /*=============    TEST END    ===============*/
    
    `uvm_info("TEST DONE", $sformatf("Total unique configurations swept: %0d", test_case_cnt), UVM_LOW)
    #10us;
    phase.drop_objection(this);
  endtask
endclass