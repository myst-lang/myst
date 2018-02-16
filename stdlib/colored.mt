defmodule Color
  def ansi_from_symbol(sym)
    when sym == :black
      return ANSI_BLACK
    when sym == :red
      return ANSI_RED
    when sym == :green
      return ANSI_GREEN
    when sym == :yellow
      return ANSI_YELLOW
    when sym == :blue
      return ANSI_BLUE
    when sym == :purple
      return ANSI_PURPLE
    when sym == :cyan
      return ANSI_CYAN
    when sym == :white
      return ANSI_WHITE
    else
      raise ":\"<(sym)>\" is not a valid color"
    end
  end

  ANSI_RESET  = "\e[0m"

  ANSI_BLACK  = "\e[0;30m"
  ANSI_RED    = "\e[0;31m"
  ANSI_GREEN  = "\e[0;32m"
  ANSI_YELLOW = "\e[0;33m"
  ANSI_BLUE   = "\e[0;34m"
  ANSI_PURPLE = "\e[0;35m"
  ANSI_CYAN   = "\e[0;36m"
  ANSI_WHITE  = "\e[0;37m"

  def colored(string, sym)
    color = ansi_from_symbol(sym) 
    "<(color)><(string.to_s)><(ANSI_RESET)>"
  end
end
