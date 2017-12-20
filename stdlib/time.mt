deftype Time
  def initialize(year, month, day, hour, minute, second)
    @year = year
    @month = month
    @day = day
    @hour = hour
    @minute = minute
    @second = second
  end

  # Only getters since a given Time is immutable
  def year; @year; end
  def month; @month; end
  def day; @day; end
  def hour; @hour; end
  def minute; @minute; end
  def second; @second; end
end
