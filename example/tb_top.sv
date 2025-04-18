module tb;
    import uvm_pkg::*;
    import clock_vip_pkg::*;
    
    // Instantiate interface
    clock_vip_if clk_if();
    
    // DUT instance would go here
    
    initial begin
        // Configure and start test
        uvm_config_db#(virtual clock_vip_if)::set(null, "uvm_test_top.env.clock_agent*", "vif", clk_if);
        
        clock_vip_config cfg = new("cfg");
        cfg.is_master = 1; // Set as master
        cfg.has_coverage = 1;
        cfg.has_checks = 1;
        cfg.vif = clk_if;
        
        uvm_config_db#(clock_vip_config)::set(null, "uvm_test_top.env.clock_agent", "cfg", cfg);
        
        run_test();
    end
endmodule
