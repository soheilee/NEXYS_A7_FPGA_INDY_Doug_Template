module header_adder #(
    parameter DW=128,
    parameter META_DATA_LENGTH = 1
)
(
    input                      clk, resetn,
    input [128:0]          packet_counter,  //Counter for the path switch
    input [31:0]            FRAME_SIZE,
    input [15:0]            PACKET_SIZE,

    // The input stream
    input[DW-1:0]              axis_in_tdata,
    input                      axis_in_tvalid,
    output                     axis_in_tready,

    // The input stream meta data
    input[DW-1:0]              axis_in_meta_tdata,
    input                      axis_in_meta_tvalid,
    output                     axis_in_meta_tready,

    // Our output stream
    output  reg   [DW-1:0]     axis_out_tdata,
    output  reg                axis_out_tvalid,
    input                      axis_out_tready,
    output reg                 axis_out_tlast,
    output reg    [DW/8-1:0]   axis_out_tkeep
);

assign axis_in_tready = (resetn == 1);
assign axis_in_meta_tready = (resetn == 1);

reg  [2:0]       fsm_state;
reg [128:0]      counter;
reg [2:0]       counter_md;
localparam PINGPONG_DATAFRAME = 0;
localparam META_DATA = 1;
localparam FRAME_COUNTER = 2;


always @(posedge clk) begin
    if (resetn == 0) begin
        counter <=0;
        counter_md <= 0;
        fsm_state <=0;
    end
    else case(fsm_state)


        PINGPONG_DATAFRAME: if (counter == FRAME_SIZE/PACKET_SIZE) begin
                                    counter <= 0;
                                    counter_md <=0;
                                    fsm_state <=META_DATA;
                                end
                                else begin
                                    counter <= counter +1;
                                end
        META_DATA:          if (counter_md == META_DATA_LENGTH) begin
                                counter_md <= 0;
                                fsm_state <=FRAME_COUNTER;
                            end
                            else begin
                                counter_md <= counter_md +1;
                            end
        
        FRAME_COUNTER:      begin
                                fsm_state <=PINGPONG_DATAFRAME;
                            end

    endcase
end

always @* begin
    // Default assignments to avoid latches
    axis_out_tdata = 0;
    axis_out_tvalid = 0;

    case (fsm_state)
        PINGPONG_DATAFRAME: begin
                                if (axis_in_tvalid) begin
                                    axis_out_tdata = axis_in_tdata;
                                    axis_out_tvalid = axis_in_tvalid;
                                end
                            end

        META_DATA:          begin
                                if (axis_in_meta_tvalid) begin
                                    axis_out_tdata = axis_in_meta_tdata;
                                    axis_out_tvalid = axis_in_meta_tvalid;
                                end
                            end

        FRAME_COUNTER:      begin
                                    axis_out_tdata = packet_counter;
                                    axis_out_tvalid = 1;
                            end

        default:            begin
                                axis_out_tdata = 0;
                                axis_out_tvalid = 0;
                            end
    endcase
end

endmodule