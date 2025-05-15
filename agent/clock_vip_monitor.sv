
`ifndef CLOCK_VIP_MONITOR_SV
`define CLOCK_VIP_MONITOR_SV

class clock_vip_monitor extends uvm_monitor;
    `uvm_component_utils(clock_vip_monitor)
    
    virtual clock_vip_if.monitor_mp vif;
    clock_vip_config cfg;
    uvm_analysis_port #(clock_vip_transaction) ap;
    
    // Measurement variables
    real last_rise_time;
    real last_fall_time;
    real measured_period;
    real measured_duty;
    
    function new(string name="clock_vip_monitor", uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(clock_vip_config)::get(this, "", "cfg", cfg)) begin
            `uvm_fatal("NOCONFIG", "No config object provided")
        end

        if (!uvm_config_db#(virtual clock_vip_if.monitor_mp)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "No interface provided")
    endfunction
    
    task run_phase(uvm_phase phase);
        fork
            monitor_clock();
        join
    endtask
    
    task monitor_clock();
        clock_vip_transaction tr;
        
        forever begin
            // Wait for rising edge
            @(posedge vif.clock_in);
            last_rise_time = $realtime();
            
            // Calculate period if we have previous falling edge
            if(last_fall_time > 0) begin
                measured_period = (last_rise_time - last_fall_time) / 1ps;
            end
            
            // Wait for falling edge
            @(negedge vif.clock_in);
            last_fall_time = $realtime();

            // Calculate duty cycle
            if(last_rise_time > 0) begin
                real high_time = (last_fall_time - last_rise_time) / 1ps;
                measured_duty = (high_time / (measured_period+high_time)) * 100;
                measured_period = (high_time + measured_period);

                // Create transaction for analysis
                tr = clock_vip_transaction::type_id::create("tr");
                tr.enable = vif.enable;
                tr.period_ps = measured_period;
                tr.duty_cycle = measured_duty;
                tr.jitter_ps = vif.jitter_ps;
                ap.write(tr);
            end
        end
    endtask
endclass

`endif //CLOCK_VIP_MONITOR_SV
