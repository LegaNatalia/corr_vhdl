LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

entity AXI_master is
  generic (
    axi_data_width_log2b    :   natural range 5 to 255 := 6;
    axi_address_width_log2b :   natural range 5 to 255 := 5
   );
PORT (
  refclk                     : IN STD_LOGIC;--! reference clock expect 250Mhz
  rst                        : IN STD_LOGIC;--! sync active high reset. sync -> refclk
 --сигналы для соединения с планировщиком и правильной работы (наверное :)
  read_data                  :   out STD_LOGIC_VECTOR(31 downto 0); --!эти данные мы записываем в буффер
  read_start                 :   in  STD_LOGIC;  --! это соединяется с axi_enable от планировщика
  read_complete              :   out STD_LOGIC;
  read_result                :   out STD_LOGIC_VECTOR(1 downto 0);
  read_addr                  : IN STD_LOGIC_VECTOR(31 downto 0); 
  flag                       : IN STD_LOGIC;
  corr_enable                : IN STD_LOGIC
 -- Global Signals
  M_AXI_ACLK          :   out STD_LOGIC;
 --  Read address channel signals
  M_AXI_ARID          :   out STD_LOGIC_VECTOR(2 downto 0);
  M_AXI_ARADDR        :   out STD_LOGIC_VECTOR(2**axi_address_width_log2b - 1 downto 0);
  M_AXI_ARLEN         :   out STD_LOGIC_VECTOR(3 downto 0);
  M_AXI_ARSIZE        :   out STD_LOGIC_VECTOR(2 downto 0);
  M_AXI_ARBURST       :   out STD_LOGIC_VECTOR(1 downto 0);
  M_AXI_ARLOCK        :   out STD_LOGIC_VECTOR(1 downto 0);
  M_AXI_ARCACHE       :   out STD_LOGIC_VECTOR(3 downto 0);
  M_AXI_ARPROT        :   out STD_LOGIC_VECTOR(2 downto 0);
  M_AXI_ARQOS         :   out STD_LOGIC_VECTOR(3 downto 0);
  M_AXI_ARUSER        :   out STD_LOGIC_VECTOR(4 downto 0);
  M_AXI_ARVALID       :   out STD_LOGIC;
  M_AXI_ARREADY       :   in  STD_LOGIC;
 -- Read data channel signals
  M_AXI_RID           :   in  STD_LOGIC_VECTOR(2 downto 0);
  M_AXI_RDATA         :   in  STD_LOGIC_VECTOR(2**axi_data_width_log2b - 1 downto 0);
  M_AXI_RRESP         :   in  STD_LOGIC_VECTOR(1 downto 0);
  M_AXI_RLAST         :   in  STD_LOGIC;
  M_AXI_RVALID        :   in  STD_LOGIC;
  M_AXI_RREADY        :   out STD_LOGIC;

);
end entity AXI_master;

architecture master of AXI_master is
begin
  --нашла на просторах инета (мб как-то иначе надо)
  M_AXI_ACLK   <= refclk;
  M_AXI_ARQOS  <= (others => '0');
  M_AXI_ARLOCK <= (others => '0');
  M_AXI_ARPROT <= (others => '0');
  M_AXI_ARID   <= (others => '0');

  --ТУТ возможно надо что-то добавить (запись в буфер принятых данных, ответ планировщику ?)

 -- reader
 reader : entity work.reader
 generic map (
     axi_data_width_log2b    => axi_data_width_log2b,
     axi_address_width_log2b => axi_address_width_log2b
 )
 port map (
     refclk                  => refclk,
     rst                     => rst,
     read_addr               => read_addr,
     read_data               => read_data,
     read_start              => read_start,
     read_complete           => read_complete,
     read_result             => read_result,
     M_AXI_ARADDR            => M_AXI_ARADDR,
     M_AXI_ARLEN             => M_AXI_ARLEN,
     M_AXI_ARSIZE            => M_AXI_ARSIZE,
     M_AXI_ARBURST           => M_AXI_ARBURST,
     M_AXI_ARCACHE           => M_AXI_ARCACHE,
     M_AXI_ARUSER            => M_AXI_ARUSER,
     M_AXI_ARVALID           => M_AXI_ARVALID,
     M_AXI_ARREADY           => M_AXI_ARREADY,
     M_AXI_RDATA             => M_AXI_RDATA,
     M_AXI_RRESP             => M_AXI_RRESP,
     M_AXI_RLAST             => M_AXI_RLAST,
     M_AXI_RVALID            => M_AXI_RVALID,
     M_AXI_RREADY            => M_AXI_RREADY
 );


end architecture master;