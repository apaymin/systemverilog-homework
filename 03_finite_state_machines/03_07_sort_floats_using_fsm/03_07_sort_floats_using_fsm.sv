//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module sort_floats_using_fsm (
    input                          clk,
    input                          rst,

    input                          valid_in,
    input        [0:2][FLEN - 1:0] unsorted,

    output logic                   valid_out,
    output logic [0:2][FLEN - 1:0] sorted,
    output logic                   err,
    output                         busy,

    // f_less_or_equal interface
    output logic      [FLEN - 1:0] f_le_a,
    output logic      [FLEN - 1:0] f_le_b,
    input                          f_le_res,
    input                          f_le_err
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs them in the increasing order using FSM.
    //
    // Requirements:
    // The solution must have latency equal to the three clock cycles.
    // The solution should use the inputs and outputs to the single "f_less_or_equal" module.
    // The solution should NOT create instances of any modules.
    //
    // Notes:
    // res0 must be less or equal to the res1
    // res1 must be less or equal to the res1
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

    enum logic [1:0] 
    {
        IDLE,
        COMP1,
        COMP2,
        COMP3
    } 
    state, new_state;

    // State transition logic
    always_comb
    begin
        new_state = state;

        // This lint warning is bogus because we assign the default value above
        // verilator lint_off CASEINCOMPLETE

        case (state)
        IDLE  : if( valid_in )  new_state = COMP1;
        COMP1 : if( !f_le_err ) new_state = COMP2;
        COMP2 : if( !f_le_err ) new_state = COMP3;
        COMP3 : if( !f_le_err ) new_state = IDLE ;
        endcase

        // verilator lint_on CASEINCOMPLETE
    end

    // Output logic
    
    logic [0:2][FLEN - 1:0] unsorted_latched;
    always_comb
    begin
        if (valid_in | state == IDLE) begin
        unsorted_latched[0] = unsorted[0];
        unsorted_latched[1] = unsorted[1];
        unsorted_latched[2] = unsorted[2];
        end
    end

    

    logic [2:0] comp_res; // {comp1_res, comp2_res, comp3_res}
    always_comb 
    begin
        case (state)
        IDLE  : 
        begin
            f_le_a = unsorted_latched[0];
            f_le_b = unsorted_latched[1];
            comp_res[2] = f_le_res;
        end
        COMP1 : 
        begin
            f_le_a = unsorted_latched[1];
            f_le_b = unsorted_latched[2];
            comp_res[1] = f_le_res;
        end
        COMP2 :  
        begin
            f_le_a = unsorted_latched[0];
            f_le_b = unsorted_latched[2];
            comp_res[0] = f_le_res;
        end
        endcase    
    end

    always_comb begin : a_b_compare
        case (comp_res)
        3'b000 : sorted = { unsorted [2], unsorted [1], unsorted[0] };
        // 3'b001 : Impossible
        3'b010 : sorted = { unsorted [1], unsorted [2], unsorted[0] };
        3'b011 : sorted = { unsorted [1], unsorted [0], unsorted[2] };
        3'b100 : sorted = { unsorted [2], unsorted [0], unsorted[1] };
        3'b101 : sorted = { unsorted [0], unsorted [2], unsorted[1] };
        // 3'b110 : Impossible
        3'b111 : sorted = unsorted;        
        endcase
    end
    

    assign valid_out = (state == COMP3) | (f_le_err);
    assign err       = f_le_err;
    assign busy      = (state != IDLE);

    // State update
    always_ff @ (posedge clk)
        if (rst | f_le_err)
            state <= IDLE;
        else
            state <= new_state;

endmodule
