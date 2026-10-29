library ieee;
use ieee.std_logic_1164.all;

entity seg7_letters is
    port (
        ch       : in  std_logic_vector(2 downto 0);
        segments : out std_logic_vector(7 downto 0)
    );
end entity seg7_letters;

architecture bhv of seg7_letters is
begin
    process(ch)
    begin
        case ch is
            when "000" => segments <= "11111010"; -- a
            when "001" => segments <= "00111110"; -- b
            when "010" => segments <= "00011010"; -- c
            when "011" => segments <= "01111010"; -- d
            when "100" => segments <= "10001110"; -- f
            when "101" => segments <= "11110110"; -- g
            when others => segments <= "00000000";
        end case;
    end process;
end architecture bhv;
