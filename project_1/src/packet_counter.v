module packet_counter #(
        parameter DW=128
    )
(
    input                      clk, resetn,
    output reg [128:0]          packet_counter,  //Counter for the path switch


    // The input stream #1
    input[DW-1:0]              axis_in_tdata,
    input                      axis_in_tvalid,
    output                     axis_in_tready,


    // Our output stream #1
    output  reg   [DW-1:0]     axis_out_tdata,
    output  reg                axis_out_tvalid,
    input                      axis_out_tready
);

reg [2:0] fsm_state;
assign axis_in_tready = (resetn == 1);



always @(posedge clk) begin
    if (resetn == 0) begin
        fsm_state <= 0;
        packet_counter <=0;
    end
    else begin
        if(axis_in_tvalid) begin
                axis_out_tdata <= axis_in_tdata;
                axis_out_tvalid <= axis_in_tvalid;
                packet_counter <= packet_counter + 1;
        end
    end

end

endmodule