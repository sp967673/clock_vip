
`ifndef CLOCK_VIP_SEQUENCE_SV
`define CLOCK_VIP_SEQUENCE_SV

class clock_vip_base_sequence extends uvm_sequence #(clock_vip_transaction);
    `uvm_object_utils(clock_vip_base_sequence)
    
    function new(string name = "clock_vip_base_sequence");
        super.new(name);
    endfunction
    
    task body();
        clock_vip_transaction tr;
        tr = clock_vip_transaction::type_id::create("tr");
        
        start_item(tr);
        assert(tr.randomize());
        finish_item(tr);
    endtask
endclass

class clock_vip_frequency_sweep_sequence extends clock_vip_base_sequence;
    `uvm_object_utils(clock_vip_frequency_sweep_sequence)
    
    int min_period = 100;  // 100ps
    int max_period = 1000; // 1ns
    int steps = 10;
    
    function new(string name = "clock_vip_frequency_sweep_sequence");
        super.new(name);
    endfunction
    
    task body();
        clock_vip_transaction tr;
        int period_step = (max_period - min_period) / steps;
        
        for(int i=0; i<steps; i++) begin
            tr = clock_vip_transaction::type_id::create("tr");
            start_item(tr);
            assert(tr.randomize() with {
                enable == 1;
                period_ps inside {[min_period + i*period_step : min_period + (i+1)*period_step]};
                duty_cycle == 50;
                jitter_ps == 0;
            });
            finish_item(tr);
            
            // Wait for 100 clock cycles
            #1000;
        end
    endtask
endclass

`endif //CLOCK_VIP_SEQUENCE_SV
