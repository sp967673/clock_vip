
`ifndef CLOCK_VIP_CONFIG_SV
`define CLOCK_VIP_CONFIG_SV

class clock_vip_config extends uvm_object;
    // Agent configuration
    bit is_master = 1;  // 1 for master, 0 for slave
    bit has_coverage = 1;
    bit has_checks = 1;
    
    // Virtual interface
    virtual clock_vip_if vif;
    
    `uvm_object_utils_begin(clock_vip_config)
        `uvm_field_int(is_master, UVM_DEFAULT)
        `uvm_field_int(has_coverage, UVM_DEFAULT)
        `uvm_field_int(has_checks, UVM_DEFAULT)
    `uvm_object_utils_end
    
    function new(string name = "clock_vip_config");
        super.new(name);
    endfunction

endclass

`endif //CLOCK_VIP_CONFIG_SV
