#doc Color
#| A library for colorizing terminal output using ANSI control sequences.
#|
#| This library provides a single method, `colored`, which accepts a content
#| object and the name of a color as a symbol, and returns a new String
#| containing ANSI control sequences for setting terminal colors.
#|
#| Note that the ANSI color codes are not absolute. Depending on the user's
#| terminal settings, the actual colors displayed in the terminal when using a
#| given color code may not match the color implied by the name. For example,
#| many dark terminal themes swap the black and white colors to better
#| accomodate most use cases. Keep this in mind when selecting colors to use.
defmodule Color
  ANSI_RESET  = "\e[0m"

  ANSI_BLACK  = "\e[0;30m"
  ANSI_RED    = "\e[0;31m"
  ANSI_GREEN  = "\e[0;32m"
  ANSI_YELLOW = "\e[0;33m"
  ANSI_BLUE   = "\e[0;34m"
  ANSI_PURPLE = "\e[0;35m"
  ANSI_CYAN   = "\e[0;36m"
  ANSI_WHITE  = "\e[0;37m"

  def ansi_from_symbol(sym)
    match sym
      ->(:black)  { ANSI_BLACK }
      ->(:red)    { ANSI_RED }
      ->(:green)  { ANSI_GREEN }
      ->(:yellow) { ANSI_YELLOW }
      ->(:blue)   { ANSI_BLUE }
      ->(:purple) { ANSI_PURPLE }
      ->(:cyan)   { ANSI_CYAN }
      ->(:white)  { ANSI_WHITE }
      ->(sym) { raise ":\"<(sym)>\" is not a valid color" }
    end
  end

  #doc colored(content, color : Symbol) -> string
  #| Returns a new String with the given content wrapped between two ANSI
  #| control sequences for setting the colors of the terminal. The first
  #| sequence sets the terminal to the color specified by `color`, and the
  #| second resets the terminal to its original colors.
  #|
  #| If `content` is not already a String, it will be converted to a String
  #| via interpolation (i.e., by calling `to_s` on it).
  #|
  #| This method may raise an error if `color` is not a valid color name.
  def colored(content, color : Symbol)
    color = ansi_from_symbol(color)
    "<(color)><(content)><(ANSI_RESET)>"
  end
end
