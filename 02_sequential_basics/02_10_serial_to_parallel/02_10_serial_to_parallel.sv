//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_to_parallel
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,

    input                      serial_valid,
    input                      serial_data,

    output logic               parallel_valid,
    output logic [width - 1:0] parallel_data
);
    // Task:
    // Implement a module that converts serial data to the parallel multibit value.
    //
    // The module should accept one-bit values with valid interface in a serial manner.
    // After accumulating 'width' bits, the module should assert the parallel_valid
    // output and set the data.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.

    logic [width - 1:0]     parallel_reg;
    logic [$clog2(width):0] bit_count;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            parallel_reg   <= '0;
            bit_count      <= '0;
            parallel_valid <= '0;
        end else begin
            parallel_valid <= '0;

            if (serial_valid) begin
                bit_count               <= bit_count + 1;
                parallel_reg[bit_count] <= serial_data;

                if (bit_count == (width - 1)) 
                begin
                    parallel_valid <= 1'b1;
                    bit_count      <= '0; 
                end
            end
        end
    end

    always_comb
    if (parallel_valid)
        parallel_data  <= parallel_reg;
    else
        parallel_data  <= '0;

endmodule
