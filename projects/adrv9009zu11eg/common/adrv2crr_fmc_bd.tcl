
create_bd_port -dir O -type clk i2s_mclk
create_bd_intf_port -mode Master -vlnv analog.com:interface:i2s_rtl:1.0 i2s

create_bd_port -dir I axi_fan_tacho_i
create_bd_port -dir O axi_fan_pwm_o

create_bd_port -dir I -from 7 -to 0 pcie_rx_n
create_bd_port -dir I -from 7 -to 0 pcie_rx_p
create_bd_port -dir O -from 7 -to 0 pcie_tx_n
create_bd_port -dir O -from 7 -to 0 pcie_tx_p

create_bd_port -dir I -type clk pcie_ref_clk
create_bd_port -dir I -type clk pcie_ref_clk2

create_bd_port -dir I -from 2 -to 0 pcie_gpio_i
create_bd_port -dir O -from 2 -to 0 pcie_gpio_o

create_bd_port -dir I pcie_soft_reset_n
create_bd_port -dir O pcie_phy_ready
create_bd_port -dir O pcie_user_lnk_up

create_bd_port -dir I pcie_perstn

# pcie

ad_ip_instance qdma pcie_qdma

ad_ip_parameter pcie_qdma CONFIG.PCIE_BLK_LOCN {X1Y0}
ad_ip_parameter pcie_qdma CONFIG.pl_link_cap_max_link_width {X8}
ad_ip_parameter pcie_qdma CONFIG.AXI_DATA_WIDTH {256_bit}
ad_ip_parameter pcie_qdma CONFIG.pf0_device_id {9038}
ad_ip_parameter pcie_qdma CONFIG.pf2_device_id {9238}
ad_ip_parameter pcie_qdma CONFIG.pf3_device_id {9338}
ad_ip_parameter pcie_qdma CONFIG.PF0_SRIOV_VF_DEVICE_ID {A038}
ad_ip_parameter pcie_qdma CONFIG.PF1_SRIOV_VF_DEVICE_ID {A138}
ad_ip_parameter pcie_qdma CONFIG.PF2_SRIOV_VF_DEVICE_ID {A238}
ad_ip_parameter pcie_qdma CONFIG.PF3_SRIOV_VF_DEVICE_ID {A338}

ad_connect pcie_ref_clk pcie_qdma/sys_clk_gt
ad_connect pcie_ref_clk2 pcie_qdma/sys_clk
ad_connect qdma_axi_clk pcie_qdma/axi_aclk
ad_connect pcie_perstn pcie_qdma/sys_rst_n

ad_connect pcie_rx_n pcie_qdma/pci_exp_rxn
ad_connect pcie_rx_p pcie_qdma/pci_exp_rxp
ad_connect pcie_tx_n pcie_qdma/pci_exp_txn
ad_connect pcie_tx_p pcie_qdma/pci_exp_txp

ad_ip_instance axi_gpio pcie_gpio
ad_ip_parameter pcie_gpio CONFIG.C_GPIO_WIDTH 3
ad_connect pcie_gpio_o pcie_gpio/gpio_io_o
ad_connect pcie_gpio_i pcie_gpio/gpio_io_i
ad_connect pcie_phy_ready pcie_qdma/phy_ready
ad_connect pcie_user_lnk_up pcie_qdma/user_lnk_up

ad_ip_instance proc_sys_reset qdma_rstgen
ad_ip_parameter qdma_rstgen CONFIG.C_EXT_RST_WIDTH 1
ad_connect qdma_rstgen/slowest_sync_clk pcie_qdma/axi_aclk
ad_connect qdma_rstgen/peripheral_aresetn pcie_qdma/soft_reset_n
ad_connect pcie_soft_reset_n qdma_rstgen/ext_reset_in


# i2s ip

ad_ip_instance axi_i2s_adi axi_i2s_adi
ad_ip_parameter axi_i2s_adi CONFIG.DMA_TYPE 0
ad_ip_parameter axi_i2s_adi CONFIG.S_AXI_ADDRESS_WIDTH 32

# dma

ad_ip_instance axi_dmac i2s_tx_dma
ad_ip_parameter i2s_tx_dma CONFIG.DMA_TYPE_SRC 0
ad_ip_parameter i2s_tx_dma CONFIG.DMA_TYPE_DEST 1
ad_ip_parameter i2s_tx_dma CONFIG.CYCLIC 1
ad_ip_parameter i2s_tx_dma CONFIG.AXI_SLICE_SRC 0
ad_ip_parameter i2s_tx_dma CONFIG.AXI_SLICE_DEST 0
ad_ip_parameter i2s_tx_dma CONFIG.ASYNC_CLK_DEST_REQ 0
ad_ip_parameter i2s_tx_dma CONFIG.ASYNC_CLK_SRC_DEST 0
ad_ip_parameter i2s_tx_dma CONFIG.ASYNC_CLK_REQ_SRC 0
ad_ip_parameter i2s_tx_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter i2s_tx_dma CONFIG.DMA_DATA_WIDTH_DEST 32
ad_ip_parameter i2s_tx_dma CONFIG.DMA_DATA_WIDTH_SRC 64

ad_ip_instance axi_dmac i2s_rx_dma
ad_ip_parameter i2s_rx_dma CONFIG.DMA_TYPE_SRC 1
ad_ip_parameter i2s_rx_dma CONFIG.DMA_TYPE_DEST 0
ad_ip_parameter i2s_rx_dma CONFIG.CYCLIC 1
ad_ip_parameter i2s_rx_dma CONFIG.AXI_SLICE_SRC 0
ad_ip_parameter i2s_rx_dma CONFIG.AXI_SLICE_DEST 0
ad_ip_parameter i2s_rx_dma CONFIG.ASYNC_CLK_DEST_REQ 0
ad_ip_parameter i2s_rx_dma CONFIG.ASYNC_CLK_SRC_DEST 0
ad_ip_parameter i2s_rx_dma CONFIG.ASYNC_CLK_REQ_SRC 0
ad_ip_parameter i2s_rx_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter i2s_rx_dma CONFIG.DMA_DATA_WIDTH_DEST 64
ad_ip_parameter i2s_rx_dma CONFIG.DMA_DATA_WIDTH_SRC 32

# i2s connections

ad_connect sys_cpu_clk axi_i2s_adi/s_axi_aclk
ad_connect sys_cpu_clk axi_i2s_adi/s_axis_aclk
ad_connect sys_cpu_clk axi_i2s_adi/m_axis_aclk
ad_connect sys_cpu_resetn axi_i2s_adi/s_axi_aresetn
ad_connect sys_cpu_resetn axi_i2s_adi/s_axis_aresetn
ad_connect i2s_tx_dma/m_axis axi_i2s_adi/s_axis

# not connecting tlast

ad_connect i2s_rx_dma/s_axis_data axi_i2s_adi/m_axis_tdata
ad_connect i2s_rx_dma/s_axis_valid axi_i2s_adi/m_axis_tvalid
ad_connect i2s_rx_dma/s_axis_ready axi_i2s_adi/m_axis_tready
ad_connect i2s axi_i2s_adi/I2S
ad_connect i2s_m_clk axi_i2s_adi/data_clk_i
ad_connect i2s_m_clk i2s_mclk

ad_connect sys_cpu_clk i2s_tx_dma/s_axi_aclk
ad_connect sys_cpu_clk i2s_tx_dma/m_src_axi_aclk
ad_connect sys_cpu_clk i2s_tx_dma/m_axis_aclk
ad_connect sys_cpu_resetn i2s_tx_dma/s_axi_aresetn
ad_connect sys_cpu_resetn i2s_tx_dma/m_src_axi_aresetn

ad_connect sys_cpu_clk i2s_rx_dma/s_axi_aclk
ad_connect sys_cpu_clk i2s_rx_dma/m_dest_axi_aclk
ad_connect sys_cpu_clk i2s_rx_dma/s_axis_aclk
ad_connect sys_cpu_resetn i2s_rx_dma/s_axi_aresetn
ad_connect sys_cpu_resetn i2s_rx_dma/m_dest_axi_aresetn

# fan control

ad_ip_instance axi_fan_control axi_fan_control_0
ad_ip_parameter axi_fan_control_0 CONFIG.ID 1
ad_ip_parameter axi_fan_control_0 CONFIG.PWM_FREQUENCY_HZ 1000
ad_ip_parameter axi_fan_control_0 CONFIG.INTERNAL_SYSMONE 1

ad_ip_instance xlconstant const_gnd_0
ad_ip_parameter const_gnd_0 CONFIG.CONST_WIDTH {10}
ad_ip_parameter const_gnd_0 CONFIG.CONST_VAL {0}

ad_connect axi_fan_tacho_i axi_fan_control_0/tacho
ad_connect axi_fan_pwm_o axi_fan_control_0/pwm
ad_connect const_gnd_0/dout axi_fan_control_0/temp_in

# interconnect

ad_cpu_interconnect 0x40000000 axi_fan_control_0
ad_cpu_interconnect 0x41000000 i2s_rx_dma
ad_cpu_interconnect 0x41001000 i2s_tx_dma
ad_cpu_interconnect 0x42000000 axi_i2s_adi
ad_cpu_interconnect 0x42100000 pcie_gpio

ad_mem_hp0_interconnect sys_cpu_clk i2s_tx_dma/m_src_axi
ad_mem_hp0_interconnect sys_cpu_clk i2s_rx_dma/m_dest_axi
ad_mem_hp0_interconnect qdma_axi_clk pcie_qdma/M_AXI
ad_mem_hp0_interconnect qdma_axi_clk pcie_qdma/M_AXI_LITE

# interrupts

ad_cpu_interrupt ps-6 mb-6 i2s_tx_dma/irq
ad_cpu_interrupt ps-7 mb-7 i2s_rx_dma/irq
ad_cpu_interrupt ps-14 mb-14 axi_fan_control_0/irq
