axi_clock_monitor is used to measure clocks in the system.
It can measure up to 16 clocks(default param set to 8 clk).

Regmap:

0x000 - pcore_version
0x004 - ID
0x00C - Number of clock
0x010 - Control the out reset signal

0x040 - Measured clock 0
0x044 - Measured clock 1
0x048 - Measured clock 2
0x04c - Measured clock 3
0x050 - Measured clock 4
0x054 - Measured clock 5
0x058 - Measured clock 6
0x05c - Measured clock 7
0x060 - Measured clock 8
0x064 - Measured clock 9
0x068 - Measured clock 10
0x06c - Measured clock 11
0x070 - Measured clock 12
0x074 - Measured clock 13
0x078 - Measured clock 14
0x07c - Measured clock 15

HDL instantiation/connection

Intel

  add_instance axi_clock_monitor_0 axi_clock_monitor 1.0
  set_instance_parameter_value axi_clock_monitor_0 {NUM_OF_CLOCKS} {6}

  add_connection sys_clk.clk axi_clock_monitor_0.s_axi_clock clock
  add_connection sys_clk.clk_reset axi_clock_monitor_0.s_axi_reset reset

  add_connection ad9250_jesd204.link_clk axi_clock_monitor_0.if_clock_0 clock
  add_connection ad9250_jesd204.link_clk axi_clock_monitor_0.if_clock_1 clock

  ad_cpu_interconnect 0x0020000 axi_clock_monitor.s_axi


Interpreting measured clock value C example:



void clock_monitor_info (uint32_t core_base_addr, uint32_t axi_clock_speed_mhz)
{

	uint32_t clock_ratio = 0;
	uint32_t clk1_addr = 0x40;
	uint32_t n_clocks = 0;
	uint32_t info_var = 0;
	uint8_t n = 0;

	info_var = ad_reg_read(core_base_addr);
	printf("PCORE_VERSION = %d\n", info_var);

	info_var = ad_reg_read(core_base_addr + 4);
	printf("ID = %d\n", info_var);

	n_clocks = ad_reg_read((core_base_addr + 12));
	printf("n clocks = %d\n", n_clocks);

	info_var = ad_reg_read(core_base_addr + 16);
	printf("RESET OUT = %d\n", info_var);

	while (n < n_clocks & n < 16) {
		clock_ratio = ad_reg_read((core_base_addr + clk1_addr + 4*n));

		if (clock_ratio == 0) {
			ad_printf("Measured clock_%d: off\n", n);
		} else {
			ad_printf("Measured clock_%d: %d MHz\n", n,
				(clock_ratio * axi_clock_speed_mhz + 0x7fff) >> 16);
		}
		n++;
	}
}

clock_monitor_info(0x00080000, 100);



