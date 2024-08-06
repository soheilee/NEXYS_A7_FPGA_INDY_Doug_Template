//=============================================================================
//               ------->  Revision History  <------
//=============================================================================
//
//   Date     Who   Ver  Changes
//=============================================================================
// 23-Jul-24  SM     1  Initial creation
//=============================================================================

/*
    This module reads in an arbitrary data stream, based the one packet length,
    it switches the outputs into axis_out1 and axis_out2. 
    
*/
module data_switch# (
    parameter DW=128
    )
(
    input                      clk, resetn,
    input [15:0]               PACKET_SIZE,
    input [7:0]                PP_GROUP,

    // The input stream
    input[DW-1:0]              axis_in_tdata,
    input                      axis_in_tvalid,
    output                     axis_in_tready,

    // Our output stream #1
    output  reg   [DW-1:0]     axis_out1_tdata,
    output  reg                axis_out1_tvalid,
    input                      axis_out1_tready,

    // Our output stream #2
    output  reg   [DW-1:0]     axis_out2_tdata,
    output  reg                axis_out2_tvalid,
    input                      axis_out2_tready



);

// The system is always ready to receive packages if not in reset
assign axis_in_tready = (resetn == 1);

// State machine defining when the output should be redirected to each one of the outputs.
// This is defined based on the packet length parameter.
reg output_path;
localparam FSM_OUTPUT_AXIS1 = 1;
localparam FSM_OUTPUT_AXIS2  = 0;
reg [15:0]          counter_ps;  //Counter for the path switch
always @(posedge clk) begin
    if (resetn == 0) begin
        counter_ps <=0;
    end
    else begin
        if(counter_ps==(PP_GROUP*PACKET_SIZE-1)) begin
                counter_ps <=0;
                output_path <= ~output_path;
            end
            else begin
                counter_ps <= counter_ps +1;
            end
    end
end

// The output is set to each output for the packet length defined by the parameters

always @* begin
    if(output_path==FSM_OUTPUT_AXIS1) begin 
        axis_out1_tdata  = axis_in_tdata;
        axis_out1_tvalid = axis_in_tvalid;
        axis_out2_tvalid = 0;   
    end
    else if(output_path==FSM_OUTPUT_AXIS2) begin
        axis_out2_tdata  = axis_in_tdata;
        axis_out2_tvalid = axis_in_tvalid;
        axis_out1_tvalid = 0;
    end
end

endmodule