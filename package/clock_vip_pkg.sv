
`ifndef CLOCK_VIP_PKG_SV
`define CLOCK_VIP_PKG_SV

package clock_vip_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    // Configuration object
    `include "clock_vip_config.sv"
    
    // Transaction item
    class clock_vip_transaction extends uvm_sequence_item;
        rand bit enable;
        rand int unsigned period_ps;
        rand int unsigned duty_cycle; // 0-100%
        rand int unsigned jitter_ps;  // peak-to-peak
        
        // Constraints
        constraint valid_duty { duty_cycle inside {[1:99]}; }
        constraint valid_period { period_ps inside {[100:1000000]}; } // 100ps to 1us
        
        `uvm_object_utils_begin(clock_vip_transaction)
            `uvm_field_int(enable, UVM_DEFAULT)
            `uvm_field_int(period_ps, UVM_DEFAULT)
            `uvm_field_int(duty_cycle, UVM_DEFAULT)
            `uvm_field_int(jitter_ps, UVM_DEFAULT)
        `uvm_object_utils_end
        
        function new(string name = "clock_vip_transaction");
            super.new(name);
        endfunction
    endclass
    
    // Include other components
    `include "clock_vip_driver.sv"
    `include "clock_vip_monitor.sv"
    `include "clock_vip_agent.sv"
    `include "clock_vip_sequence.sv"
    `include "clock_vip_coverage.sv"
    `include "clock_vip_checker.sv"
endpackage

`endif //CLOCK_VIP_PKG_SV
