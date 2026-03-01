class uart_environment extends uvm_env;
  `uvm_component_utils(uart_environment)

  virtual uart_if lhs_vif;
  virtual uart_if rhs_vif;

  uart_configuration uart_lhs_cfg;
  uart_configuration uart_rhs_cfg;

  uart_scoreboard uart_sb;

  uart_agent      uart_lhs_agt;
  uart_agent      uart_rhs_agt;

  function new(string name="uart_environment", uvm_component parent);
    super.new(name,parent);
  endfunction: new

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("connect_phase","Entered...",UVM_HIGH)

    /*Connect to scoreboard*/
  uart_lhs_agt.monitor.item_observed_port.connect(uart_sb.lhs_monitor_collected_export);
  uart_lhs_agt.driver.item_observed_port.connect (uart_sb.lhs_driver_collected_export);
  uart_rhs_agt.driver.item_observed_port.connect (uart_sb.rhs_driver_collected_export);

    `uvm_info("connect_phase","Exiting...",UVM_HIGH)

  endfunction: connect_phase


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("build_phase","Entered...",UVM_HIGH)

    //virtual interface received through the config db
    if(!uvm_config_db#(virtual uart_if)::get(this,"","lhs_vif",lhs_vif))
      `uvm_fatal(get_type_name(),$sformatf("failed to get uart_lhs_vif from uvm_config_db. please check!"))
    
    if(!uvm_config_db#(virtual uart_if)::get(this,"","rhs_vif",rhs_vif))
      `uvm_fatal(get_type_name(),$sformatf("failed to get uart_rhs_vif from uvm_config_db. please check!"))


    uvm_config_db#(virtual uart_if)::set(this,"uart_rhs_agt","uart_vif" ,rhs_vif);
    uvm_config_db#(virtual uart_if)::set(this,"uart_lhs_agt","uart_vif" ,lhs_vif);


    //uart configuration received through the config db
    if(!uvm_config_db#(uart_configuration)::get(this,"","uart_lhs_cfg",uart_lhs_cfg))
      `uvm_fatal(get_type_name(),$sformatf("failed to get uart_lhs_cfg from uvm_config_db. please check!"))
    
    if(!uvm_config_db#(uart_configuration)::get(this,"","uart_rhs_cfg",uart_rhs_cfg))
      `uvm_fatal(get_type_name(),$sformatf("failed to get uart_rhs_cfg from uvm_config_db. please check!"))


    uvm_config_db#(uart_configuration)::set(this,"uart_rhs_agt","uart_cfg" ,uart_rhs_cfg);
    uvm_config_db#(uart_configuration)::set(this,"uart_lhs_agt","uart_cfg" ,uart_lhs_cfg);


    uart_rhs_agt = uart_agent::type_id::create("uart_rhs_agt", this);
    uart_lhs_agt = uart_agent::type_id::create("uart_lhs_agt", this);


    uart_sb = uart_scoreboard::type_id::create("uart_sb", this);

    `uvm_info("build_phase","Exiting...",UVM_HIGH)
  endfunction: build_phase

endclass: uart_environment
