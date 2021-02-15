module Slave(
    input wire CS, clk, SDI,
    output wire SDO
);
reg[7:0] memory;
reg[7:0] command;//read:00000001,write:00000010,replace:00000011
reg[3:0] done;//to keep track of 8-bit communication(differ between commands and data)
initial begin
    memory=8'b11001000;
    command=0;
    done=0;
end
always @(posedge clk) begin
    if(!CS) begin
        if(!done[3])
            command<={command[6:0],SDI};
        else begin
            command<=command;
            if(command==8'b00000001)//read slave's memory and put it in the mater memory
                memory<={memory[6:0],memory[7]};
            if(command==8'b00000010)//write slave's memory without changing master data
                memory<={memory[6:0],SDI};
            if(command==8'b00000011)//replace slave memory with master memory and master memory with slave memory at the same time (full duplex)
                memory<={memory[6:0],SDI};
        end
        done=done+1;//counter to triger the 8 cycles for 8-bit comunication
    end        
    else begin
        memory<=memory;
    end
end
assign SDO=!CS ? memory[7] : 1'bZ;
endmodule