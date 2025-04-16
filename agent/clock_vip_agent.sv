
`ifndef CLOCK_VIP_AGENT_SV
`define CLOCK_VIP_AGENT_SV

class clock_vip_agent extends uvm_agent;
    `uvm_component_utils(clock_vip_agent)
    
    clock_vip_driver driver;
    clock_vip_monitor monitor;
    uvm_sequencer #(clock_vip_transaction) sequencer;
    clock_vip_checker checker;
    clock_vip_coverage coverage;
    clock_vip_config cfg;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        if(!uvm_config_db#(clock_vip_config)::get(this, "", "cfg", cfg)) begin
            `uvm_fatal("NOCONFIG", "No config object provided")
        end
        
        monitor = clock_vip_monitor::type_id::create("monitor", this);
        
        if(cfg.is_master) begin
            sequencer = uvm_sequencer#(clock_vip_transaction)::type_id::create("sequencer", this);
            driver = clock_vip_driver::type_id::create("driver", this);
        end
        
        if(cfg.has_checks) begin
            checker = clock_vip_checker::type_id::create("checker", this);
        end
        
        if(cfg.has_coverage) begin
            coverage = clock_vip_coverage::type_id::create("coverage", this);
        end
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect monitor to checker and coverage
        monitor.ap.connect(checker.ap_imp);
        if(cfg.has_coverage) begin
            monitor.ap.connect(coverage.ap_imp);
        end
        
        // Connect driver if master
        if(cfg.is_master) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction
endclass

`endif //CLOCK_VIP_AGENT_SV
