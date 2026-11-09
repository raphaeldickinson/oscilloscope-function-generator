// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2026.1 (win64) Build 6511674 Tue Jun 16 11:02:23 MDT 2026
// Date        : Sun Nov  8 18:50:29 2026
// Host        : R-Zenbook running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ blk_mem_gen_0_sim_netlist.v
// Design      : blk_mem_gen_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "blk_mem_gen_0,blk_mem_gen_v8_4_13,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_13,Vivado 2026.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (clka,
    ena,
    wea,
    addra,
    dina,
    clkb,
    enb,
    addrb,
    doutb);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_mode = "slave BRAM_PORTA" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [9:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [15:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_mode = "slave BRAM_PORTB" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *) input enb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [9:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [15:0]doutb;

  wire [9:0]addra;
  wire [9:0]addrb;
  wire clka;
  wire clkb;
  wire [15:0]dina;
  wire [15:0]doutb;
  wire ena;
  wire enb;
  wire [0:0]wea;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [15:0]NLW_U0_douta_UNCONNECTED;
  wire [9:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [9:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [15:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "10" *) 
  (* C_ADDRB_WIDTH = "10" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "1" *) 
  (* C_COUNT_36K_BRAM = "0" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     2.7261 mW" *) 
  (* C_FAMILY = "zynq" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "1" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "1" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "blk_mem_gen_0.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEMORY_OPTIMIZATION = "1" *) 
  (* C_MEM_TYPE = "1" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "1024" *) 
  (* C_READ_DEPTH_B = "1024" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "16" *) 
  (* C_READ_WIDTH_B = "16" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "0" *) 
  (* C_USE_BYTE_WEB = "0" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "1024" *) 
  (* C_WRITE_DEPTH_B = "1024" *) 
  (* C_WRITE_MODE_A = "NO_CHANGE" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "16" *) 
  (* C_WRITE_WIDTH_B = "16" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_blk_mem_gen_v8_4_13 U0
       (.addra(addra),
        .addrb(addrb),
        .clka(clka),
        .clkb(clkb),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(NLW_U0_douta_UNCONNECTED[15:0]),
        .doutb(doutb),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(enb),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[9:0]),
        .regcea(1'b1),
        .regceb(1'b1),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[9:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[15:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(wea),
        .web(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2026.1"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
kZgFhM2d/jlaPzxpf6XHBAvY3udA2n90sVrL5ios3dCU6DHMG01BptGv7AEkMGv1nBWc9wOv8Ao5
MO+RYUWfJloAgvE9oz3EJHrmhQHk1oDdQ/EpnejIRbEZCjmfHUEI21gyKS6oLdkyx2gHs3HX+wks
75MnE8jDP5XEe0wRk70=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
CotVlRfEkpF8whBUKgocdcjhKyrcMEGPZvHkGVHISj+GCXwa3Gdeme07eFJpz/ZotBRm0H+nvk9U
c+cu76zAYcGZA4BB8k5S5CN9te+cdcMud4cLzxM3NWHdGuMLRnzIf+YH7ADhhyN/3GRT3GlBC9un
8gg46/rnawNHyJnmhY8sUwhYJFSC6Zp+YpCreJEMMsSSR0D4CM0VZx3eT8IWhFsOz6ekLOhifcRk
JdWdOdywGnTqpOq97/LmRPbfEGBiYB5YDEex+rP8S+WkdfZSRXRcMfIMDifCL2F9vyvALaXXU/HK
kczWE+R+OoMRMGX7ipHLpx7Q08Lk2uu9pJiE9Q==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
tZnJNN2Qmv8npxJcsUh1oNo5AcwWv4Go3b6+WqtB8cYERd3tAiuYpzM9E8x0/NSOgU2lO+XGGWqL
PXOFRGE6+vT9Uw+MMZ7IhiFhNUxakIUv/kmA/Kpo9+5Y8aWN581krtWN9KT8/ccdMg7//qZ5aT8D
c323EB+407vCn2c62Ug=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
KKZGVVr56cxydgpa10+BIppw9vsPylE78OMiTW7WTk1ML6QnGGk6Ufm83Q5BYCGjf79wKt+EDVr2
Faz5O4p7NqDjYc+6UH+r3tYhzg8ax3QQ/lL0h4ROXjjznYZN4GT3jpmEVd5M9uz0VZRUklNggvzs
aHgFve9gt7F5cG1cwxr+CFWUfKcsH6XCTrNM3UP1/Ye33LxT6qzhZVuCb4w1zybXO9K1HZRARNeE
XmaMeB1MHLiswqCVSWCi3ahqMoTIL8Nkwb7LISvYxN88qxMca/sR/Y59W48DrGDRBBzZ48hIpVXK
9wpPb6wF5zA03FsVqRSc5JxQzfKhTSxAnXSVMA==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
ywVnQUL8hRlFZUGP9Kpsx7UfX2m6K2oMp1dIrzsl1e7ahG0jDMr0uZjciYiQvVpl++f7jBR3qTGo
/E63+MEs3aH3oSmrd0H/Etz+j2FU3ASZNwvS98uACXUBPzAeEwFUuJ9/8jqLJsiNybXigf8spDDy
xB/JnUfJl4/mmyClxySXyscK3aOnErzAZ9B9i8PeHPttmRn6onzR+wukt29Z0ETtVcyKKb9JQeO5
4ipDn79/o1IPYLzFyyiP5/oKUP/4zmX/6pbiO6bdzi2kdrhBtRE6ztlUGTI0WBHPOO+nZcIlF5S4
jckQo17l4fcqBJC8p6S7fb4eyfp+IU8PFj6wDQ==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2026.1-2030.x", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
GUQu/hEzrCx6whrKX9cnRKGYwu/EkGwKC+5ZIAahvY/upngQfvNVWyz4hLS5Q+jQdoupTTPWruY8
5QnccTfRLO/UNkPmbg8atB4asCjrKgLIhzPG1pqhoH9BtKKby74jLu4vyRH0Hk9XOXkAXLos7eBX
Nudw/vzxy74RzWXjstE5NRhMqfXi+jrP7VLV+NT9AN7PZQ8SsVifNwD2P2HwGzqQT/beYW8LvNbr
bRbtDAwcCcJomfkUvNb4pYE7MuJK22aox2ar8nUAviLnxnmy/ASVSGou0mCxgkZKW88UP70HDIhl
aueFj0IyK2H6IPJM9GCgGAwEeA0w0rzI7faPlg==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
YHSFaIRKyhIVU+ZO/EyZESP/nTM928AcWJGbKx6Nxkm8PEl7yBr3z8S8G0MbToKUpAO14Ei843y2
QSES26grec+g5bQHTjG1w5mR0gi3IRbGAT8ctIbI6qe8HxLmMViuDiYNb2JRHPBhpGjx1o9s0K53
1FVtSLcIMPdvZ6vGzYYlswxXiOA7D0qdnIFeJXb/6BzeYM/ZSO3kXFNYZVuhaNU0AcFxQzxAe/sK
lx5QdNGpyfexd+UnTCdHIul+eFr91+gTUaOVHDR7qvAiX+c3k+nbn4d1gBOExbPG5xXxO9QzpWZH
pkGcv5/2mmPVGGa6bx1rd+/wxxqJYs2r4GBQhQ==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
SuOFRD2tIt83R5vOz6fwY9Uj1WJom9jlw00FrgpAa9zzHh8NDaN1pvHliEpw0RI/EXGai+RqFTtv
ODI2Qchq2R+Ohalo8v9B//WzHrQEoZOqY8ExEpKNbhp2IJiwsZKz4enjUze+QgFiZFFBQSuEtvRx
6PvI0tTjXp4d4nJZP6HbKHFzj2SEggoTEvkYm2QqrEIRu3HQ9cXOaM9B77eWbQvHHj8yGYRw4A5u
Grwq5j0VzH8/eaysSLlB32jy65hpz1XiigFMnu01jNTA/Fh2qkMYpJeiiityiftiHDGBeEi78AUU
DCNlSbHo0NgXbyxwgV82OqxM0bTJUXK6Gh6/8xgla6TEAub1vTzQH5Uche+S6QnV24o6ll5HwYyV
RoBr27Aj0mceN3MNqSTnsoEMthFh1MLmp0imxgG/6NjNFKABJTDuaGPLE9XjU59knvKP1VKk9Fp5
rI7Y3IvGFhu0bHKEhV60LLTosXWr9gzS3uKCMCb0T38cAx5GX6FcChb0

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
WC3gV9hDsJlJGDWXD9/OXXBzEn6vsr7+oOdKz7gm4Rk/FFR50y93jhYmcWd1K2InGg42AOhIHo2Z
TvhSjky9Smc6kaftDv0qbAD/y3awUgVWMhvanfJnlEuAZfoFEJGwGr9jYg55AvfvuX1rQTtKoUFi
ACZ7pJVaLnkCKFVPNuhRAQxCs7KLW7cG1ALcdtOdnRrcG3bh4dHzct2JzL2/VK03C8gPKr3uM6DE
9O0lltoTf/AzP3jfV2LZekZChJx+UY4WWMhnVCiQKoa9voReSAKbrxHl/hqJvWQiYa6CFpABdUpX
fjEHVkVIdpnVpslTz0sOxXMvpxX7F8T6O5KvOA==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Iqc6J3NDm5J0Ukvjev1H/S4Q4RmJahnBq0A8nClyXeu33t4xanh+aGq3+WcR0KQRtSZvQDrbXWvy
VpRaHzQu/lgwraB5780gv5qhqt1D3uYyerl5fx6fl2ozWlr8yZKs/qaDlktEWGF0MPUsJuYE6ZcM
72yOpO5/ynMUgwJs9FVcK5pRasgkXgOUeN1tA6mmLAiYCor4CtxoB2CGVa0z1Xsrai6cNrXCDd8I
D1f10kYi4ICIsU7uhC3hLMQ66OSpgzGDdHUq52hVB7ESc7B/fk4nrcm0mSK0cPc0un7O8vvvykdb
kA7qDovHJqWd0VWle0m3J0DvA2pKJUU4AmG51A==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Y+N5GKAwdOuN9nS/lU52Y4ZNhFpP5Eg6jiLvP1rQk7jt7v332HLd3dDgIcKOvTZ+cT2qc/fEH3km
qRW6R6MDwiTEv5NDgR96180FbWhHKmyQ/AZmvgAhcSnKARj27eDEkTFcUfN+RgRNycooCPjQ2LvE
RAHSYS+ob7G8GxymUfgoG2pJ1BZF8n98Yv+Aj+fx3pPWyFx63XYQu0VIla5KV1WkhDxakW9v4pJh
kWzHMGwdhrs9q2KAQjFgZaDXVv5oFd/wcJWXkvkbsRdm3Ok9s3OwuaW9LsKnBGReVg6ii5BR+7Za
9w0kFZHcWjmf5ns8L/rFEzHcIGqE15ZlLKYekg==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 19952)
`pragma protect data_block
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
VaI=
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
