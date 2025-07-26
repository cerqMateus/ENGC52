module TOP (
    input clk,
    input reset,
    output reg ready,
    output [4:0] mem_address,
    output mem_read_enable,
    output mem_write_enable,
    output [15:0] mem_data_in,
    input [15:0] mem_data_out
);
    wire accum_enable, accum_reset;
    wire [15:0] accum_data_out;
    
    FSM fsm_inst (
        .clk(clk),
        .reset(reset),
        .mem_data_out(mem_data_out),
        .ready(ready),
        .mem_address(mem_address),
        .mem_read_enable(mem_read_enable),
        .mem_write_enable(mem_write_enable),
        .accum_enable(accum_enable),
        .accum_reset(accum_reset)
    );
    
    Acumulador accum_inst (
        .clk(clk),
        .reset(accum_reset),
        .enable(accum_enable),
        .data_in(mem_data_out),
        .data_out(accum_data_out)
    );
    
    assign mem_data_in = accum_data_out;
endmodule