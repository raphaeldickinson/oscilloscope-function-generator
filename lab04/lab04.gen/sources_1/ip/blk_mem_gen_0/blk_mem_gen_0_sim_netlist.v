// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2026.1 (win64) Build 6511674 Tue Jun 16 11:02:23 MDT 2026
// Date        : Sun Nov  8 18:50:31 2026
// Host        : R-Zenbook running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Users/maitr/Documents/EENG484/lab04/lab04.gen/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0_sim_netlist.v
// Design      : blk_mem_gen_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "blk_mem_gen_0,blk_mem_gen_v8_4_13,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_13,Vivado 2026.1" *) 
(* NotValidForBitStream *)
module blk_mem_gen_0
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
  blk_mem_gen_0_blk_mem_gen_v8_4_13 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 19920)
`pragma protect data_block
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
AWfCoPmZj2CzEfJ6nxJ5t0Qt8V/YZNRANf+p
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
