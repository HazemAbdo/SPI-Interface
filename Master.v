module Master(
    input wire MISO,
    output reg clk, CS1, CS2, CS3,
    output wire MOSI
);
reg[7:0] memory;
reg[7:0] command;
reg[3:0] done;//to keep track of 8-bit communication(differ between commands and data)
initial begin
    memory=8'b01001101;
    command=8'b00000010;//write to slave1
    done=0;
    clk=0;
end
always
    #1 clk=~clk;
always @(posedge clk) begin
    if(!CS1||!CS2||!CS3) begin
        if(!done[3])
            command<={command[6:0],command[7]};
        else begin
            if(command==8'b00000001)//read slave's memory and put it in the mater memory
                memory<={memory[6:0],MISO};
            if(command==8'b00000010)//write slave's memory without changing master data
                memory<={memory[6:0],memory[7]};
            if(command==8'b00000011)//replace slave memory with master memory and master memory with slave memory at the same time (full duplex)
                memory<={memory[6:0],MISO};
        end
        done=done+1;//counter to triger the 8 cycles for 8-bit comunication
    end
    else begin
        memory<=memory;
    end
end
assign MOSI =done[3] ? memory[7]:command[7];
endmodule