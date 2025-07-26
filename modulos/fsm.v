module FSM (
    input clk,
    input reset,
    input [15:0] mem_data_out,
    output reg ready,
    output reg [4:0] mem_address,
    output reg mem_read_enable,
    output reg mem_write_enable,
    output reg accum_enable,
    output reg accum_reset
);
    localparam [3:0]
        IDLE                = 0,
        RESET_ACCUM         = 1,
        SET_ADDR_READ       = 2,
        WAIT_READ           = 3,
        WRITE_RESULT        = 4,
        NEXT_SET            = 5,
        RESET_ACCUM_FINAL   = 6,
        SET_ADDR_READ_RESULT= 7,
        WAIT_READ_RESULT    = 8,
        WRITE_TOTAL         = 9,
        READY1              = 10,
        READY2              = 11;
    
    reg [3:0] state, next_state;
    reg [2:0] set_counter;     
    reg [1:0] read_counter;    
    reg [2:0] result_counter;  
    
  
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            set_counter <= 0;
            read_counter <= 0;
            result_counter <= 0;
        end else begin
            state <= next_state;
            
            case (state)
                WAIT_READ: 
                    if (read_counter < 3) read_counter <= read_counter + 1;
                NEXT_SET: begin
                    if (set_counter < 4) set_counter <= set_counter + 1;
                    read_counter <= 0;
                end
                WAIT_READ_RESULT: 
                    if (result_counter < 4) result_counter <= result_counter + 1;
                READY2: begin
                    set_counter <= 0;
                    result_counter <= 0;
                end
            endcase
        end
    end
    
    
    always @(*) begin
        next_state = state;
        ready = 0;
        mem_read_enable = 0;
        mem_write_enable = 0;
        accum_enable = 0;
        accum_reset = 0;
        mem_address = 5'b0;
        
        case (state)
            IDLE: next_state = RESET_ACCUM;
            
            RESET_ACCUM: begin
                accum_reset = 1;
                next_state = SET_ADDR_READ;
            end
            
            SET_ADDR_READ: begin
                mem_address = set_counter * 5 + read_counter; 
                mem_read_enable = 1;
                next_state = WAIT_READ;
            end
            
            WAIT_READ: begin
                accum_enable = 1;
                next_state = (read_counter == 3) ? WRITE_RESULT : SET_ADDR_READ;
            end
            
            WRITE_RESULT: begin
                mem_address = set_counter * 5 + 4; 
                mem_write_enable = 1;
                next_state = NEXT_SET;
            end
            
            NEXT_SET: 
                next_state = (set_counter == 4) ? RESET_ACCUM_FINAL : RESET_ACCUM;
            
            RESET_ACCUM_FINAL: begin
                accum_reset = 1;
                next_state = SET_ADDR_READ_RESULT;
            end
            
            SET_ADDR_READ_RESULT: begin
                mem_address = 4 + result_counter * 5;
                mem_read_enable = 1;
                next_state = WAIT_READ_RESULT;
            end
            
            WAIT_READ_RESULT: begin
                accum_enable = 1;
                next_state = (result_counter == 4) ? WRITE_TOTAL : SET_ADDR_READ_RESULT;
            end
            
            WRITE_TOTAL: begin
                mem_address = 31; 
                mem_write_enable = 1;
                next_state = READY1;
            end
            
            READY1: begin
                ready = 1;
                next_state = READY2;
            end
            
            READY2: begin
                ready = 1;
                next_state = IDLE; 
            end
        endcase
    end
endmodule