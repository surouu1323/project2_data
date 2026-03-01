class uart_base_test extends uvm_test;
  `uvm_component_utils(uart_base_test)

  virtual uart_if lhs_vif;
  virtual uart_if rhs_vif;

  uart_configuration uart_lhs_cfg;
  uart_configuration uart_rhs_cfg;

  uart_environment uart_env;
  uart_write_sequence m_write_seq;

  uart_error_catcher err_catcher;

  function new(string name="uart_base_test", uvm_component parent);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("build_phase","Entered...",UVM_HIGH)

    //virtual interface received through the config db
    if(!uvm_config_db#(virtual uart_if)::get(this,"","lhs_vif",lhs_vif))
      `uvm_fatal(get_type_name(),$sformatf("failed to get uart_lhs_vif from uvm_config_db. please check!"))
    
    if(!uvm_config_db#(virtual uart_if)::get(this,"","rhs_vif",rhs_vif))
      `uvm_fatal(get_type_name(),$sformatf("failed to get uart_rhs_vif from uvm_config_db. please check!"))

    uvm_config_db#(virtual uart_if)::set(this,"uart_env","lhs_vif",lhs_vif);
    uvm_config_db#(virtual uart_if)::set(this,"uart_env","rhs_vif",rhs_vif);

    uart_env = uart_environment::type_id::create("uart_env",this);

    uart_lhs_cfg = uart_configuration::type_id::create("uart_lhs_cfg",this);
    
    uart_lhs_cfg.baud_rate    = uart_configuration::B_9600;
    uart_lhs_cfg.parity_mode  = uart_configuration::ODD;
    uart_lhs_cfg.data_width   = uart_configuration::D_8b;
    uart_lhs_cfg.stop_bit     = uart_configuration::STOP_2BIT;
    
    `uvm_info(get_type_name(), "uart_lhs_config successed",UVM_HIGH)

    uart_rhs_cfg = uart_configuration::type_id::create("uart_rhs_cfg",this);

    uart_rhs_cfg.baud_rate    = uart_configuration::B_9600;
    uart_rhs_cfg.parity_mode  = uart_configuration::ODD;
    uart_rhs_cfg.data_width   = uart_configuration::D_8b;
    uart_rhs_cfg.stop_bit     = uart_configuration::STOP_2BIT;

    `uvm_info(get_type_name(), "uart_rhs_config successed",UVM_HIGH)

    // uvm_config_db#(uart_configuration)::set(this,"uart_env","uart_lhs_cfg",uart_lhs_cfg);
    // uvm_config_db#(uart_configuration)::set(this,"uart_env","uart_rhs_cfg",uart_rhs_cfg);

    uvm_config_db#(uart_configuration)::set(this,"uart_env*","uart_lhs_cfg",uart_lhs_cfg);
    uvm_config_db#(uart_configuration)::set(this,"uart_env*","uart_rhs_cfg",uart_rhs_cfg);
    
    err_catcher = uart_error_catcher::type_id::create("error_catcher");
    uvm_report_cb::add(null, err_catcher);

    `uvm_info("build_phase","Exiting...",UVM_HIGH)
  endfunction: build_phase
  
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    `uvm_info("end_of_elaboration_phase","Entered...",UVM_HIGH)

    if (get_report_verbosity_level() >= UVM_HIGH) begin // Only print verbosity is set to HIGH or above for deep debugging
        uvm_top.print_topology();
    end else begin
        uvm_top.enable_print_topology = 0; // Disable the automatic topology print to ensure a clean log
    end
    `uvm_info("end_of_elaboration_phase","Exiting...",UVM_HIGH)
  endfunction


  virtual task uart_lhs_write (input logic[8:0] data);
    int bits = get_num_bits(uart_lhs_cfg.data_width);
    logic[8:0] masked_data = data & ((1 << bits) - 1);

    `uvm_info("UART_WRITE", $sformatf("LHS Side: Sending Data=0x%0h (Width=%0d bits)", 
              masked_data, bits), UVM_LOW)

    m_write_seq = new();
    m_write_seq.data = masked_data;
    m_write_seq.direction = uart_transaction::WRITE;
    m_write_seq.start(uart_env.uart_lhs_agt.sequencer);
  endtask: uart_lhs_write

  virtual task uart_rhs_write (input logic[8:0] data);
    int bits = get_num_bits(uart_rhs_cfg.data_width);
    logic[8:0] masked_data = data & ((1 << bits) - 1);

    `uvm_info("UART_WRITE", $sformatf("RHS Side: Sending Data=0x%0h (Width=%0d bits)", 
              masked_data, bits), UVM_LOW)

    m_write_seq = new();
    m_write_seq.data = masked_data;
    m_write_seq.direction = uart_transaction::READ;
    m_write_seq.start(uart_env.uart_rhs_agt.sequencer);
  endtask: uart_rhs_write

  virtual function void final_phase(uvm_phase phase);
    uvm_report_server svr;
    super.final_phase(phase);
    `uvm_info("final_phase","Entered...", UVM_HIGH)
    svr = uvm_report_server::get_server();
    if(svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(UVM_ERROR) > 0)begin
      $display("\n===================================================");
      $display("            #### Status: TEST FAILED ####            ");
      $display("===================================================\n");
    end
    else begin
      $display("\n===================================================");
      $display("            #### Status: TEST PASSED ####            ");
      $display("===================================================\n");
    end
    `uvm_info("final_phase", "Exiting...", UVM_HIGH)

  endfunction: final_phase

  local function int get_num_bits(uart_configuration::data_width_enum dw);
    case(dw)
        uart_configuration::D_5b: return 5;
        uart_configuration::D_6b: return 6;
        uart_configuration::D_7b: return 7;
        uart_configuration::D_8b: return 8;
        uart_configuration::D_9b: return 9;
        default: return 8;
    endcase
  endfunction

endclass


