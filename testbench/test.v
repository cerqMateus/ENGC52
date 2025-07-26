`timescale 1ns/1ns
module TOP_tb;
    reg clk, reset;
    wire ready;
    wire [4:0] mem_address;
    wire mem_read_enable, mem_write_enable;
    wire [15:0] mem_data_in;
    reg [15:0] mem_data_out;
    
    TOP uut (
        .clk(clk),
        .reset(reset),
        .ready(ready),
        .mem_address(mem_address),
        .mem_read_enable(mem_read_enable),
        .mem_write_enable(mem_write_enable),
        .mem_data_in(mem_data_in),
        .mem_data_out(mem_data_out)
    );
    
    reg [15:0] memory [0:31];
    always @(posedge clk) begin
        if (mem_read_enable) 
            mem_data_out <= memory[mem_address];
        else 
            mem_data_out <= 16'bz;
            
        if (mem_write_enable) 
            memory[mem_address] <= mem_data_in;
    end
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        for (integer i = 0; i < 32; i++) 
            memory[i] = i;
        
        reset = 1;
        #20 reset = 0;
        
        @(posedge ready);
        @(posedge ready);
        
        if (memory[4] !== 6)  $error("Erro: Soma1 != 6");
        if (memory[9] !== 26) $error("Erro: Soma2 != 26");
        if (memory[14] !== 46) $error("Erro: Soma3 != 46");
        if (memory[19] !== 66) $error("Erro: Soma4 != 66");
        if (memory[24] !== 86) $error("Erro: Soma5 != 86");
        if (memory[31] !== 230) $error("Erro: Total != 230");
        
        $display("Teste concluído com sucesso!");
        $finish;
    end
endmodule