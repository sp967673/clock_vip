
`ifndef CLOCK_VIP_DRIVER_SV
`define CLOCK_VIP_DRIVER_SV

class clock_vip_driver extends uvm_driver #(clock_vip_transaction);
    `uvm_component_utils(clock_vip_driver)
    
    virtual clock_vip_if.master_mp vif;
    clock_vip_config cfg;
    
    // Internal variables
    realtime current_period;
    realtime current_duty;
    realtime current_jitter;
    bit  current_enable;
    
    // Jitter generation
    realtime jitter_values[$];
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(clock_vip_config)::get(this, "", "cfg", cfg)) begin
            `uvm_fatal("NOCONFIG", "No config object provided")
        end

        if (!uvm_config_db#(virtual clock_vip_if.master_mp)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "No interface provided")
    endfunction
    
    task run_phase(uvm_phase phase);
        begin
            reset_signals();
            fork
                get_and_drive();
                clock_generation();
            join
        end
    endtask
    
    task reset_signals();
        vif.clock_out <= 0;
        vif.clock_active <= 0;
        vif.config_error <= 0;
    endtask
    
    task get_and_drive();
        forever begin
            seq_item_port.get_next_item(req);
            configure_clock(req);
            seq_item_port.item_done();
        end
    endtask
    
    task configure_clock(clock_vip_transaction cfg_tr);
        // Validate configuration
        if(cfg_tr.duty_cycle == 0 || cfg_tr.duty_cycle > 99) begin
            vif.config_error <= 1;
            `uvm_error("CFGERR", $sformatf("Invalid duty cycle: %0d%%", cfg_tr.duty_cycle))
            return;
        end
        
        if(cfg_tr.period_ps < 100) begin
            vif.config_error <= 1;
            `uvm_error("CFGERR", $sformatf("Period too small: %0dps", cfg_tr.period_ps))
            return;
        end
        
        vif.config_error <= 0;
        
        // Update current configuration
        current_enable = cfg_tr.enable;
        current_period = cfg_tr.period_ps;
        current_duty = cfg_tr.duty_cycle / 100.0;
        current_jitter = cfg_tr.jitter_ps;
        
        // Update interface
        vif.enable <= cfg_tr.enable;
        vif.period_ps <= cfg_tr.period_ps;
        vif.duty_cycle <= cfg_tr.duty_cycle;
        vif.jitter_ps <= cfg_tr.jitter_ps;
        vif.clock_active <= cfg_tr.enable;
        
        // Pre-calculate jitter values for next 100 cycles
        generate_jitter_values();
    endtask
    
    function void generate_jitter_values();
        jitter_values.delete();
        for(int i=0; i<100; i++) begin
            realtime jitter, random_jitter_val;
            int current_jitter_int;
            // Generate random jitter within ±jitter_ps/2
            current_jitter_int = int'(current_jitter);
            random_jitter_val = $urandom_range(current_jitter_int, 0);
            jitter = (random_jitter_val - current_jitter/2.0);
            jitter_values.push_back(jitter);
        end
    endfunction
    
    task clock_generation();
        real high_time, low_time;
        real next_edge;
        int jitter_idx = 0;
        
        forever begin
            // Wait for enable
            wait(current_enable);
            
            // Calculate times with jitter
            high_time = current_period * current_duty;
            low_time = current_period * (1.0 - current_duty);

            // Apply jitter (round robin through pre-generated values)
            if(jitter_values.size() > 0) begin
                high_time += jitter_values[jitter_idx]/2.0;
                low_time += jitter_values[jitter_idx]/2.0;
                jitter_idx = (jitter_idx + 1) % jitter_values.size();
            end

            // Generate clock high phase
            vif.clock_out <= 1;
            next_edge = high_time;
            #(next_edge * 1ps);
            
            // Generate clock low phase
            vif.clock_out <= 0;
            next_edge = low_time;
            #(next_edge * 1ps);
            
            // Regenerate jitter values if we've used them all
            if(jitter_idx == 0) begin
                generate_jitter_values();
            end
        end
    endtask
endclass

`endif //CLOCK_VIP_DRIVER_SV
