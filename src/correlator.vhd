
LIBRARY IEEE;--! standard library IEEE (Institute of Electrical and Electronics Engineers)
USE IEEE.std_logic_1164.ALL;--! standard unresolved logic UX01ZWLH-
USE IEEE.numeric_std.ALL;--! for the signed, unsigned types and arithmetic ops

entity correlator is
PORT (
  refclk : IN STD_LOGIC;--! reference clock expect 250Mhz
  rst    : IN STD_LOGIC;--! sync active high reset. sync -> refclk
  en     : IN STD_LOGIC;

  ref_input   : IN STD_LOGIC_VECTOR(31 downto 0) := (OTHERS => '0');
  signal_input : IN STD_LOGIC_VECTOR(31 downto 0) := (OTHERS => '0');

  valid     : IN  STD_LOGIC;
  ref_addr  : OUT STD_LOGIC_VECTOR(3 downto 0);
  bram_re   : OUT STD_LOGIC := '0';

  fifo_req  : OUT STD_LOGIC := '0';

  result    : OUT STD_LOGIC := '0';
);
end entity correlator;
architecture rtl of correlator is

  signal corr_sum : INTEGER;
  signal ref_sum  : INTEGER;
  variable counter : INTEGER;

  type STATE_T is (idle, working, result); -- for state machine
  signal cur_state, next_state is STATE_T;

  signal load_ended, work_ended, data_ready : BOOLEAN;

  signal data_sig, data_ref : STD_LOGIC_VECTOR(31 downto 0);
begin

  -- resetter
  process(cur_state)
  begin 
    if (cur_state = idle) then
      corr_sum <= 0;
      ref_sum  <= 0;
      counter  := 0;
    end if;
  end process;

  -- state switch
  process(refclk, rst)
  begin
    if (rst = '1') then
      cur_state <= idle;
    elsif (rising_edge(refclk)) then
      cur_state <= next_state;      
    end if;
  end process;  

  -- state machine
  process(refclk)
  begin
    if(rising_edge(refclk)) then
      case(cur_state) is
      
        when idle =>
          if (en) then
            next_state <= loading;
          else
            next_state <= idle;
          end if;
        
        when working =>
          if (work_ended) then 
              next_state <= result;
              work_ended <= false;
          else 
              next_state <= working
          end if;
        
        when result =>
              next_state <= idle;
      
        when others =>
              next_state <= idle;
    
      end case ;
    end if;
  end process;

  -- get data
  process(refclk)
  begin
    if(rising_edge(refclk)) then
      if (counter <= 15 && en && cur_state = working) then
          ref_addr <= std_logic_vector(to_unsigned(counter));
          bram_re <= '1';
          fifo_req <= '1';
          req = false;
          if (valid) then
            data_ready <= true;
            data_ref <= ref_input;
            data_sig <= signal_input;
          else
            data_ready <= false;
          end if;
      end if;
    end if;
  end process;

  -- count summs 
  process(refclk, cur_state)
  signal req : BOOLEAN := true;
  begin
    if (rising_edge(refclk)) then
      if (cur_state = working && data_ready) then
        counter := counter + 1;
        corrsum <= corrsum + to_integer(signed(data_ref)) * to_integer(signed(data_signal));
        refsum  <= refsum + to_integer(signed(data_ref)) * to_integer(signed(data_ref));

        if (counter >= 15) then
          work_ended <= true;
        end if;
      else
          work_ended <= false;
      end if;
    end if;
  end process;

  -- result to output
  process (corr_sum, ref_sum, cur_state, refclk, en)
  begin
    if rising_edge(refclk) then
      if (en)then
        if (state = result) then       -- тут еще обдумать и вероятно разнести условия
          if corr_sum > ref_sum * 8 / 10 then
            result <= '1';
          else
            result <= '0';
          end if;
        end if;
      else
        result <= 'Z';  
      end if;
    
    end if;
  end process;

end architecture rtl;
