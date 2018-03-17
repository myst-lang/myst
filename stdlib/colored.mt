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

  def colored(string, sym : Symbol)
    color = ansi_from_symbol(sym)
    "<(color)><(string)><(ANSI_RESET)>"
  end
end
