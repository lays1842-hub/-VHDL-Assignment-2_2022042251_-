library ieee;
use ieee.std_logic_1164.all;

entity mux8_1 is
    port (
        a, b, c, d, e, f, g, h : in std_logic;
        ch                   : in std_logic_vector(2 downto 0);
        data_out             : out std_logic
    );
end entity mux8_1;

architecture bhv of mux8_1 is
begin
    process(a, b, c, d, e, f, g, h, ch)
    begin
        case ch is
            when "000" => data_out <= a;
            when "001" => data_out <= b;
            when "010" => data_out <= c;
            when "011" => data_out <= d;
            when "100" => data_out <= e;
            when "101" => data_out <= f;
            when "110" => data_out <= g;
            when "111" => data_out <= h;
            when others => data_out <= '0';
        end case;
    end process;
end architecture bhv;
