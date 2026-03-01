`uvm_analysis_imp_decl(_lhs_monitor)
`uvm_analysis_imp_decl(_lhs_driver)
`uvm_analysis_imp_decl(_rhs_driver)

class uart_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(uart_scoreboard)

    uart_transaction lhs_driver_q[$];
    uart_transaction rhs_driver_q[$];
    uart_transaction rx_monitor_q[$];
    uart_transaction tx_monitor_q[$];

    uart_transaction monitor_queue;
    uart_transaction driver_queue;

    uart_transaction rx_trans;
    uart_transaction tx_trans;
  /*Analysis port received transaction from monitor*/
  uart_transaction cloned_trans;
  uvm_analysis_imp_lhs_monitor#(uart_transaction, uart_scoreboard) lhs_monitor_collected_export;
  uvm_analysis_imp_lhs_driver #(uart_transaction, uart_scoreboard) lhs_driver_collected_export;
  uvm_analysis_imp_rhs_driver #(uart_transaction, uart_scoreboard) rhs_driver_collected_export;


  function new(string name=get_type_name(), uvm_component parent);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    lhs_monitor_collected_export = new("lhs_monitor_collected_export", this);
    lhs_driver_collected_export  = new("lhs_driver_collected_export", this);
    rhs_driver_collected_export  = new("rhs_driver_collected_export", this);

    cloned_trans = uart_transaction::type_id::create("cloned_trans", this);
    rx_trans = uart_transaction::type_id::create("rx_trans", this);
    tx_trans = uart_transaction::type_id::create("tx_trans", this);
  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);

  endtask: run_phase



  virtual function void write_lhs_monitor(uart_transaction monitor_trans);
    `uvm_info(get_type_name(),"Received trans from lhs monitor",UVM_HIGH)
    if (uvm_report_enabled(UVM_HIGH)) monitor_trans.print();  
    if(monitor_trans.direction == uart_transaction::WRITE) begin
        $cast(tx_trans, monitor_trans.clone());
        tx_monitor_q.push_front(tx_trans);
        `uvm_info(get_type_name(),"push tx tran to tx queue",UVM_HIGH)
        `uvm_info(get_type_name(),$sformatf("tx_monitor_q size: %d", tx_monitor_q.size()),UVM_HIGH)
        driver_queue  = lhs_driver_q.pop_back();
        monitor_queue = tx_monitor_q.pop_back();

        if(driver_queue.data != monitor_queue.data) 
            `uvm_error(get_type_name(),$sformatf("Tx data not match, rhs_driver.data: %h, monior.data: %h", driver_queue.data, monitor_queue.data))
        else `uvm_info(get_type_name(),$sformatf("Tx data match, rhs_driver.data: %h, monior.data: %h",driver_queue.data, monitor_queue.data),UVM_LOW)            
    end
    else begin
        $cast(rx_trans, monitor_trans.clone());        
        rx_monitor_q.push_front(rx_trans);
        `uvm_info(get_type_name(),"push rx tran to rx queue",UVM_HIGH)
        `uvm_info(get_type_name(),$sformatf("rx_monitor_q size: %d", rx_monitor_q.size()),UVM_HIGH)
        driver_queue  = rhs_driver_q.pop_back();
        monitor_queue = rx_monitor_q.pop_back();
        
        if(driver_queue.data != monitor_queue.data) 
            `uvm_error(get_type_name() ,$sformatf("Rx data not match, rhs_driver.data: %h, monior.data: %h", driver_queue.data, monitor_queue.data))
        else `uvm_info(get_type_name(),$sformatf("Rx data match, rhs_driver.data: %h, monior.data: %h",driver_queue.data, monitor_queue.data),UVM_LOW) 
    end
  endfunction: write_lhs_monitor

  virtual function void write_lhs_driver(uart_transaction driver_trans);
    `uvm_info(get_type_name(),"Received trans from lhs driver",UVM_HIGH)
    if (uvm_report_enabled(UVM_HIGH)) driver_trans.print();  
    $cast(cloned_trans, driver_trans.clone());
    lhs_driver_q.push_front(cloned_trans);
    `uvm_info(get_type_name(),"push lhs tran to lhs queue",UVM_HIGH)
    `uvm_info(get_type_name(),$sformatf("lhs_driver_q size: %d", lhs_driver_q.size()),UVM_HIGH)

  endfunction: write_lhs_driver

  virtual function void write_rhs_driver(uart_transaction driver_trans);
    `uvm_info(get_type_name(),"Received trans from rhs driver",UVM_HIGH)
    if (uvm_report_enabled(UVM_HIGH)) driver_trans.print();  
    $cast(cloned_trans, driver_trans.clone());
    rhs_driver_q.push_front(cloned_trans);
    `uvm_info(get_type_name(),"push rhs tran to lhs queue",UVM_HIGH)
    `uvm_info(get_type_name(),$sformatf("rhs_driver_q size: %d", rhs_driver_q.size()),UVM_HIGH)

  endfunction: write_rhs_driver


endclass: uart_scoreboard
