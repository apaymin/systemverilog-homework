//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module float_discriminant (
    input                     clk,
    input                     rst,

    input                     arg_vld,
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,
    input        [FLEN - 1:0] c,

    output logic              res_vld,
    output logic [FLEN - 1:0] res,
    output logic              res_negative,
    output logic              err,

    output logic              busy
);

    // Task:
    // Implement a module that a_times_ccepts three Floating-Point numbers and outputs their discriminant.
    // The resulting value res should be calculated as a discriminant of the quadratic polynomial.
    // That is, res = b^2 - 4a_times_c == b*b - 4*a*c
    //
    // Note:
    // If any argument is not a valid number, that is NaN or Inf, the "err" flag should be set.
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

    localparam [FLEN - 1:0] four = 64'h4010_0000_0000_0000;

    logic [FLEN - 1:0] b_squared, a_times_c, four_times_ac;
    logic [2:0] down_valid;
    logic [3:0] int_busy;
    logic [3:0] int_err;

    f_mult i_mult_bb (
        .clk(clk),
        .rst(rst),
        .a(b),
        .b(b),
        .up_valid(arg_vld),
        .res(b_squared),
        .down_valid(down_valid[0]),
        .busy(int_busy[0]),
        .error(int_err[0])
    );

    f_mult i_mult_ac (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(c),
        .up_valid(arg_vld),
        .res(a_times_c),
        .down_valid(down_valid[1]),
        .busy(int_busy[1]),
        .error(int_err[1])
    );

    f_mult i_mult_4ac (
        .clk(clk),
        .rst(rst),
        .a(four),
        .b(a_times_c),
        .up_valid(down_valid[1]),
        .res(four_times_ac),
        .down_valid(down_valid[2]),
        .busy(int_busy[2]),
        .error(int_err[2])
    );

    f_sub i_sub (
        .clk(clk),
        .rst(rst),
        .a(b_squared),
        .b(four_times_ac),
        .up_valid(down_valid[2]),
        .res(res),
        .down_valid(res_vld),
        .busy(int_busy[3]),
        .error(int_err[3])
    );

    assign busy = | int_busy;
    assign err  = | int_err;

endmodule
