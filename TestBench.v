`timescale 1ns/100ps
//data flow:dataOut<-[1010001100010011]<-dataIn
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
    CS1=0;
    CS2=1;
    CS3=1;
    done=0;
    clk=0;
    #32
        if(memory==8'b01001101)
            $display("Pass maser test1");
        else
            $display("Fail maser test1");
    command=8'b00000001;//read from slave2
    CS1=1;
    CS2=0;
    CS3=1;
    #32
        if(memory==8'b11001000)
            $display("Pass maser test2");
        else
            $display("Fail maser test2");
    command=8'b00000011;//replace master memory with slave3 memory
    memory=8'b11100001;
    CS1=1;
    CS2=1;
    CS3=0;
    #32
        if(memory==8'b11001000)
            $display("Pass maser test3");
        else
            $display("Fail maser test3");
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
    #32
    if(!CS) begin
        if(memory==8'b01001101)
            $display("Pass slaves test1");
        else
            $display("Fail slaves test1");
    end
    #32
    if(!CS) begin
        if(memory==8'b11001000)
            $display("Pass slaves test2");
        else
            $display("Fail slaves test2");
    end    
    #32
    if(!CS) begin
        if(memory==8'b11100001)
            $display("Pass slaves test3");
        else
            $display("Fail slaves test3");
    end
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

module MasterSlave();//Conections and Test Bench is integrated with modules (Run this for Test Bench)
wire clk, CS1, CS2, CS3, MOSI, MISO;
Master M(MISO,clk,CS1,CS2,CS3,MOSI);
Slave S1(CS1,clk,MOSI,MISO);
Slave S2(CS2,clk,MOSI,MISO);
Slave S3(CS3,clk,MOSI,MISO);
endmodule