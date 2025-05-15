
`ifndef CLOCK_VIP_COVERAGE_SV
`define CLOCK_VIP_COVERAGE_SV

`uvm_analysis_imp_decl(_cov)

class clock_vip_coverage extends uvm_component;
    `uvm_component_utils(clock_vip_coverage)
    
    uvm_analysis_imp_cov #(clock_vip_transaction, clock_vip_coverage) ap_imp;
    
    // Coverage groups
    covergroup clock_cg;
        period_cp: coverpoint tr.period_ps {
            bins typical[] = {[100:1000]};
            bins fast = {[100:500]};
            bins med = {[501:800]};
            bins slow = {[801:1000]};
        }
        
        duty_cp: coverpoint tr.duty_cycle {
            bins low = {[30:40]};
            bins mid = {[45:55]};
            bins high = {[60:70]};
        }
        
        jitter_cp: coverpoint tr.jitter_ps {
            bins none = {0};
            bins sml = {[1:10]};
            bins med = {[11:50]};
            bins larg = {[51:100]};
        }
        
        period_duty_cross: cross period_cp, duty_cp;
    endgroup
    
    clock_vip_transaction tr;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        clock_cg = new();
        ap_imp = new("ap_imp", this);
    endfunction
    
    function void write_cov(clock_vip_transaction tr);
        this.tr = tr;
        clock_cg.sample();
    endfunction
endclass

`endif //CLOCK_VIP_COVERAGE_SV
