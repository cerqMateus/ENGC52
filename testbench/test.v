`timescale 1ns/1ns
module TOP_tb;
    reg clk, reset;
    wire ready;
    wire [4:0] mem_address;
    wire mem_read_enable, mem_write_enable;
    wire [15:0] mem_data_in;
    reg [15:0] mem_data_out;
    
    integer i;
    
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
    end
    
    initial begin
        for (i = 0; i < 32; i = i + 1) 
            memory[i] = i;
        
        reset = 1;
        #40 reset = 0;  
        
        wait(ready === 1);
        @(negedge ready);  
        
        #40;  
        
        if (memory[4] !== 6)  $error("Erro: Soma1 != 6 (obtido %0d)", memory[4]);
        if (memory[9] !== 26) $error("Erro: Soma2 != 26 (obtido %0d)", memory[9]);
        if (memory[14] !== 46) $error("Erro: Soma3 != 46 (obtido %0d)", memory[14]);
        if (memory[19] !== 66) $error("Erro: Soma4 != 66 (obtido %0d)", memory[19]);
        if (memory[24] !== 86) $error("Erro: Soma5 != 86 (obtido %0d)", memory[24]);
        if (memory[31] !== 230) $error("Erro: Total != 230 (obtido %0d)", memory[31]);
        
        $display("==================================");
        $display("Teste concluído com sucesso!");
        $display("Resultados:");
        $display("Addr 4: %0d (esperado 6)", memory[4]);
        $display("Addr 9: %0d (esperado 26)", memory[9]);
        $display("Addr 14: %0d (esperado 46)", memory[14]);
        $display("Addr 19: %0d (esperado 66)", memory[19]);
        $display("Addr 24: %0d (esperado 86)", memory[24]);
        $display("Addr 31: %0d (esperado 230)", memory[31]);
        $display("==================================");
        $finish;
    end
endmodule