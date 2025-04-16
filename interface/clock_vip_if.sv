
`ifndef CLOCK_VIP_IF_SV
`define CLOCK_VIP_IF_SV

interface clock_vip_if(input logic clk);
    // Clock signals
    logic clock_out;       // Master drives this
    logic clock_in;        // Slave monitors this
    
    // Control signals
    logic enable;
    logic [31:0] period_ps;
    logic [7:0]  duty_cycle; // percentage (0-100)
    logic [31:0] jitter_ps; // peak-to-peak jitter
    
    // Status signals
    logic clock_active;
    logic config_error;
    
    // Modports
    modport master_mp (
        output clock_out,
        input enable, period_ps, duty_cycle, jitter_ps,
        output clock_active, config_error
    );
    
    modport slave_mp (
        input clock_in,
        input enable, period_ps, duty_cycle, jitter_ps,
        output clock_active, config_error
    );
    
    modport monitor_mp (
        input clock_in, clock_out,
        input enable, period_ps, duty_cycle, jitter_clock_active,
        input config_error
    );
endinterface

`endif //CLOCK_VIP_IF_SV
