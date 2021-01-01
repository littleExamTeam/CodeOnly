module branch_predict (
    input wire clk, rst,
    
    input wire flushD,
    input wire stallD,

    input wire [31:0] pcF,
    input wire [31:0] pcM,

    input wire branchM,         // M�׶��Ƿ��Ƿ�ָ֧��
    input wire actual_takeM,    // ʵ���Ƿ���ת

    input wire [31:0] inst, 
 
    output wire pred_takeD

);

    wire branchD;
    wire pred_takeF;
    reg pred_takeF_r;
    assign branchD = inst[28];  //�ж�����׶��Ƿ��Ƿ�ָ֧��

// �������
    parameter Strongly_not_taken = 2'b00, Weakly_not_taken = 2'b01, Weakly_taken = 2'b11, Strongly_taken = 2'b10;
    parameter PHT_DEPTH = 6;
    parameter BHT_DEPTH = 10;

// 
    reg [5:0] BHT [(1<<BHT_DEPTH)-1 : 0];
    reg [1:0] PHT [(1<<PHT_DEPTH)-1 : 0];
    
    integer i,j;
    wire [(PHT_DEPTH-1):0] PHT_index;
    wire [(BHT_DEPTH-1):0] BHT_index;
    wire [(PHT_DEPTH-1):0] BHR_value;

// ---------------------------------------Ԥ���߼�---------------------------------------

    assign BHT_index = pcF[11:2];     
    assign BHR_value = BHT[BHT_index];  
    assign PHT_index = BHR_value;

    assign pred_takeF = PHT[PHT_index][1];      // ��ȡָ�׶�Ԥ���Ƿ����ת����������ˮ�ߴ��ݸ�����׶Ρ�

        // --------------------------pipeline------------------------------
            always @(posedge clk) begin
                if(rst | flushD) begin
                    pred_takeF_r <= 0;
                end
                else if(~stallD) begin
                    pred_takeF_r <= pred_takeF;
                end
            end
        // --------------------------pipeline------------------------------

// ---------------------------------------Ԥ���߼�---------------------------------------

// ---------------------------------------BHT��ʼ���Լ�����---------------------------------------
    wire [(PHT_DEPTH-1):0] update_PHT_index;
    wire [(BHT_DEPTH-1):0] update_BHT_index;
    wire [(PHT_DEPTH-1):0] update_BHR_value;

    assign update_BHT_index = pcM[11:2];     
    assign update_BHR_value = BHT[update_BHT_index];  
    assign update_PHT_index = update_BHR_value;

    always@(posedge clk) begin
        if(rst) begin
            for(j = 0; j < (1 << BHT_DEPTH); j = j + 1) begin
                BHT[j] <= 0;
            end
        end
        else if(branchM) begin
            // �����߼��Ĵ���
            if(actual_takeM) begin
                BHT[update_BHT_index]<={BHT[update_BHT_index][4:0],1'b1};
            end
            else begin
                BHT[update_BHT_index]<={BHT[update_BHT_index][4:0],1'b0};
            end
        end
    end
// ---------------------------------------BHT��ʼ���Լ�����---------------------------------------


// ---------------------------------------PHT��ʼ���Լ�����---------------------------------------
    always @(posedge clk) begin
        if(rst) begin
            for(i = 0; i < (1 << PHT_DEPTH); i = i + 1) begin
                PHT[i] <= Weakly_taken;
            end
        end
        else begin
            case(PHT[update_PHT_index])
                // �����߼��Ĵ���
                2'b00: begin
                    if(actual_takeM) begin
                        PHT[update_PHT_index] <= Weakly_not_taken;
                    end
                    else begin
                        PHT[update_PHT_index] <= Strongly_not_taken;
                    end
                end
                2'b01: begin
                    if(actual_takeM) begin
                        PHT[update_PHT_index] <= Weakly_taken;
                    end
                    else begin
                        PHT[update_PHT_index] <= Strongly_not_taken;
                    end
                end
                2'b10: begin
                    if(actual_takeM) begin
                        PHT[update_PHT_index] <= Strongly_taken;
                    end
                    else begin
                        PHT[update_PHT_index] <= Weakly_not_taken;
                    end
                end
                2'b11: begin
                    if(actual_takeM) begin
                        PHT[update_PHT_index] <= Strongly_taken;
                    end
                    else begin
                        PHT[update_PHT_index] <= Weakly_taken;
                    end
                end
            endcase 
        end
    end
// ---------------------------------------PHT��ʼ���Լ�����---------------------------------------
    assign pred_takeD = branchD & pred_takeF_r;  
    // ����׶�������յ�Ԥ����  
endmodule