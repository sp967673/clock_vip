
`ifndef CLOCK_VIP_CHECKER_SV
`define CLOCK_VIP_CHECKER_SV

class clock_vip_checker extends uvm_component;
    `uvm_component_utils(clock_vip_checker)
    
    uvm_analysis_imp #(clock_vip_transaction, clock_vip_checker) ap_imp;
    clock_vip_config cfg;
    
    // Configuration from DUT
    int unsigned expected_period;
    int unsigned expected_duty;
    int unsigned expected_jitter;
    bit expected_enable;
    
    // Tolerance settings
    real period_tolerance = 0.01;  // 1%
    real duty_tolerance = 1.0;     // 1%
    real jitter_tolerance = 1.1;   // 10% margin
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap_imp = new("ap_imp", this);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(clock_vip_config)::get(this, "", "cfg", cfg)) begin
            `uvm_fatal("NOCONFIG", "No config object provided")
        end
    endfunction
    
    function void write(clock_vip_transaction tr);
        // Get expected values from interface
        expected_period = cfg.vif.period_ps;
        expected_duty = cfg.vif.duty_cycle;
        expected_jitter = cfg.vif.jitter_ps;
        expected_enable = cfg.vif.enable;
        
        // Check if clock should be active
        if(expected_enable != tr.enable) begin
            `uvm_error("CHKERR", $sformatf("Clock enable mismatch. Expected: %0d, Measured: %0d", 
                         expected_enable, tr.enable))
        end
        
        // Check period
        check_within_tolerance("Period", tr.period_ps, expected_period, period_tolerance);
        
        // Check duty cycle
        check_within_tolerance("Duty cycle", tr.duty_cycle, expected_duty, duty_tolerance);
        
        // Note: Jitter checking would require statistical analysis over many cycles
        // This is simplified here
        if(tr.jitter_ps > expected_jitter * jitter_tolerance) begin
            `uvm_warning("CHKERR", $sformatf("Possible excessive jitter. Configured: %0dps, Observed: %0dps",
                         expected_jitter, tr.jitter_ps))
        end
    endfunction
    
    function void check_within_tolerance(string name, real measured, real expected, real tolerance);
        real lower_bound = expected * (1 - tolerance);
        real upper_bound = expected * (1 + tolerance);
        
        if(measured < lower_bound || measured > upper_bound) begin
            `uvm_error("CHKERR", $sformatf("%s out of bounds. Expected: %0d, Measured: %0d (Tolerance: ±%0.1f%%)",
                       name, expected, measured, tolerance*100))
        end
        else begin
            `uvm_info("CHKOK", $sformatf("%s within bounds. Expected: %0d, Measured: %0d", 
                      name, expected, measured), UVM_HIGH)
        end
    endfunction
endclass

`endif //CLOCK_VIP_CHECKER_SV
