module evm(
    rst, clk,
    cand1, cand2, cand3,      // Pushbutton inputs for candidates 1 to 3
    rcnt1, rcnt2, rcnt3,      // Output vote counts for each candidate
    voting_over               // Signal indicating voting session has ended
);

    input rst, clk;
    input cand1, cand2, cand3;
    input voting_over;

    output reg [31:0] rcnt1, rcnt2, rcnt3; // Final vote counts for each candidate

    reg [1:0] state, next_state;  // Current and next states of the FSM
    reg [3:0] hold_cnt;           // Counter for PAUSE state (debounce/delay)

    // State encoding
    parameter IDLE   = 2'b00;
    parameter VOTE   = 2'b01;
    parameter PAUSE  = 2'b10;
    parameter FINISH = 2'b11;

    // Previous states of button inputs, used for falling edge detection
    reg [31:0] cand1_prev;
    reg [31:0] cand2_prev;
    reg [31:0] cand3_prev;

    // Internal vote counters
    reg [31:0] cnt1;
    reg [31:0] cnt2;
    reg [31:0] cnt3;

    // FSM for vote detection and state control
    always @(posedge clk or posedge rst) begin
        case(state)
            IDLE: if(rst) begin
                // Reset state: initialize all counters
                next_state <= IDLE;
                cnt1 <= 32'b0;
                cnt2 <= 32'b0;
                cnt3 <= 32'b0;
                hold_cnt <= 4'b0;
            end
            else begin
                // Exit IDLE state and start voting
                next_state <= VOTE;
            end

            VOTE: if(voting_over == 1'b1) begin
                // Voting is over, go to FINISH state
                next_state <= FINISH;
            end
            else if(cand1 == 1'b0 && cand1_prev == 1'b1) begin
                // Detect falling edge for cand1 (active low press)
                cnt1 = cnt1 + 1'b1;
                next_state <= PAUSE;
            end
            else if(cand2 == 1'b0 && cand2_prev == 1'b1) begin
                // Falling edge on cand2
                cnt2 = cnt2 + 1'b1;
                next_state <= PAUSE;
            end
            else if(cand3 == 1'b0 && cand3_prev == 1'b1) begin
                // Falling edge on cand3
                cnt3 = cnt3 + 1'b1;
                next_state <= PAUSE;
            end
            else begin
                // No voting activity, stay in VOTE state
                cnt1 <= cnt1;
                cnt2 <= cnt2;
                cnt3 <= cnt3;
                next_state <= VOTE;
            end

            PAUSE: if(voting_over == 1'b1) begin
                // Voting has ended, transition to FINISH
                next_state <= FINISH;
            end
            else begin
                // Wait in PAUSE state to debounce
                if(hold_cnt != 4'b1111)
                    hold_cnt = hold_cnt + 1'b1;
                else
                    next_state <= VOTE;
            end

            FINISH: if(voting_over == 1'b0) begin
                // Reset voting session; go back to IDLE
                next_state <= IDLE;
            end
            else begin
                // Remain in FINISH state until voting_over goes low
                next_state <= FINISH;
            end
        endcase
    end

    // Sequential logic for state transition and output register updates
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            // Reset all outputs and FSM state
            state <= IDLE;
            rcnt1 <= 32'b0;
            rcnt2 <= 32'b0;
            rcnt3 <= 32'b0;
            hold_cnt <= 4'b0000;
        end
        else if(rst == 1'b0 && voting_over == 1'b1) begin
            // When voting is over, transfer internal counts to outputs
            rcnt1 <= cnt1;
            rcnt2 <= cnt2;
            rcnt3 <= cnt3;
        end
        else begin
            // Regular state update
            state <= next_state;
            // Save previous button states for edge detection
            cand1_prev <= cand1;
            cand2_prev <= cand2;
            cand3_prev <= cand3;
        end
    end
endmodule
