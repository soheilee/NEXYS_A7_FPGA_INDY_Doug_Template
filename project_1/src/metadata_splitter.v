module metadata_splitter #(
    parameter DW = 128
)(
    input                      clk,
    input                      resetn,

    // The input stream
    input      [DW-1:0]        axis_in_tdata,
    input                      axis_in_tvalid,
    output                     axis_in_tready,

    // Our output stream #1
    output reg [DW-1:0]        axis_out1_tdata,
    output reg                 axis_out1_tvalid,
    input                      axis_out1_tready,

    // Our output stream #2
    output reg [DW-1:0]        axis_out2_tdata,
    output reg                 axis_out2_tvalid,
    input                      axis_out2_tready
);

assign axis_in_tready = resetn && axis_out1_tready && axis_out2_tready;

always @* begin
    if (resetn) begin
        axis_out1_tvalid = axis_in_tvalid && axis_out1_tready && axis_out2_tready;
        axis_out2_tvalid = axis_in_tvalid && axis_out1_tready && axis_out2_tready;
        axis_out1_tdata = axis_in_tdata;
        axis_out2_tdata = axis_in_tdata;
    end else begin
        axis_out1_tvalid = 0;
        axis_out2_tvalid = 0;
        axis_out1_tdata = 0;
        axis_out2_tdata = 0;
    end
end

endmodule
