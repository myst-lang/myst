deftype Time
  # Logic taken from Crystal::Time
  defmodule Util
    DAYS_MONTH = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    DAYS_MONTH_LEAP = [0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    
    SECONDS_PER_MINUTE = 60

    SECONDS_PER_HOUR = 60 * SECONDS_PER_MINUTE

    SECONDS_PER_DAY = 24 * SECONDS_PER_HOUR

    NANOSECONDS_PER_MILLISECOND = 1_000_000.0

    NANOSECONDS_PER_SECOND = 1_000_000_000.0

    NANOSECONDS_PER_MINUTE = NANOSECONDS_PER_SECOND * 60

    DAYS_PER_400_YEARS = 365 * 400 + 97

    DAYS_PER_100_YEARS = 365 * 100 + 24

    DAYS_PER_4_YEARS = 365 * 4 + 1

    def leap_year?(year)
      (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
    end

    def absolute_days(year, month, day)
      days = when leap_year?(year)
                DAYS_MONTH_LEAP
              else
                DAYS_MONTH
              end

      temp = 0
      m = 1
      while m < month
        temp += days[m]
        m += 1
      end
  
      (day - 1) + temp + (365*(year - 1)) + ((year - 1)/4) - ((year - 1)/100) + ((year - 1)/400)
    end

    def year_month_day_day_year(seconds)
      m = 1
  
      days = DAYS_MONTH
      total_days = seconds / SECONDS_PER_DAY
  
      num400 = total_days / DAYS_PER_400_YEARS
      total_days -= num400 * DAYS_PER_400_YEARS
  
      num100 = total_days / DAYS_PER_100_YEARS
      when num100 == 4 # leap
        num100 = 3
      end
      total_days -= num100 * DAYS_PER_100_YEARS
  
      num4 = total_days / DAYS_PER_4_YEARS
      total_days -= num4 * DAYS_PER_4_YEARS
  
      num_years = total_days / 365
  
      when num_years == 4 # leap
        num_years = 3
      end
  
      year = num400 * 400 + num100 * 100 + num4 * 4 + num_years + 1
  
      total_days -= num_years * 365
      day_year = total_days + 1
  
      dec_31_leap = num100 == 3 || num4 != 24
      when num_years == 3 && dec_31_leap # 31 dec leapyear
        days = DAYS_MONTH_LEAP
      end
  
      while total_days >= days[m]
        total_days -= days[m]
        m += 1
      end
  
      month = m
      day = total_days + 1
  
      [year, month, day, day_year]
    end

    def convert_to_seconds(year, month, day, hour, minute, second)
      days = absolute_days(year, month, day)
      seconds = 1 *
                SECONDS_PER_DAY * days +
                SECONDS_PER_HOUR * hour +
                SECONDS_PER_MINUTE * minute +
                second
    end

    def days_in_month(year, month)
      when leap_year?(year)
        days = DAYS_MONTH_LEAP
      else
        days = DAYS_MONTH
      end

      days[month]
    end
  end

  def initialize(seconds, nanoseconds)
    unless 0 <= nanoseconds && nanoseconds <= Util.NANOSECONDS_PER_SECOND
      raise "Invalid time: invalid nanoseconds"
    end
    @seconds = seconds
    @nanoseconds = nanoseconds
  end

  def initialize(year, month, day)
    validate(year, month, day, 0, 0, 0, 0)
    @seconds = Util.convert_to_seconds(year, month, day, 0, 0, 0)
    @nanoseconds = 0
  end

  def initialize(year, month, day, hour)
    validate(year, month, day, hour, 0, 0, 0)
    @seconds = Util.convert_to_seconds(year, month, day, hour, 0, 0)
    @nanoseconds = 0
  end

  def initialize(year, month, day, hour, minute)
    validate(year, month, day, hour, minute, 0, 0)
    @seconds = Util.convert_to_seconds(year, month, day, hour, minute, 0)
    @nanoseconds = 0
  end

  def initialize(year, month, day, hour, minute, second)
    validate(year, month, day, hour, minute, second, 0)
    @seconds = Util.convert_to_seconds(year, month, day, hour, minute, second)
    @nanoseconds = 0
  end

  def initialize(year, month, day, hour, minute, second, nanosecond)
    validate(year, month, day, hour, minute, second, nanosecond)
    @seconds = Util.convert_to_seconds(year, month, day, hour, minute, second)
    @nanoseconds = nanosecond
  end

  def validate(year, month, day, hour, minute, second, nanosecond)
    unless 1 <= year && year <= 9999 &&
      1 <= month && month <= 12 &&
      1 <= day && day <= Util.days_in_month(year, month) &&
      0 <= hour && hour <= 23 &&
      0 <= minute && minute <= 59 &&
      0 <= second && second <= 59 &&
      0 <= nanosecond && nanosecond <= Util.NANOSECONDS_PER_SECOND
      raise "Invalid time"
    end
  end

  # Only getters since a given Time is immutable
  def seconds; @seconds; end
  def nanoseconds; @nanoseconds; end

  def year
    @year ||= Util.year_month_day_day_year(@seconds)[0]
  end

  def month
    @month ||= Util.year_month_day_day_year(@seconds)[1]
  end

  def day
    @day ||= Util.year_month_day_day_year(@seconds)[2]
  end

  def hour
    @hour ||= (@seconds % Util.SECONDS_PER_DAY) / Util.SECONDS_PER_HOUR
  end

  def minute
    @minute ||= (@seconds % Util.SECONDS_PER_HOUR) / Util.SECONDS_PER_MINUTE
  end

  def second
    @second ||= @seconds % Util.SECONDS_PER_MINUTE
  end

  def millisecond
    @millisecond ||= @nanoseconds / Util.NANOSECONDS_PER_MILLISECOND
  end

  def nanosecond
    @nanoseconds
  end

  def -(other : Time)
    new_seconds = seconds - other.seconds
    new_nanoseconds = nanoseconds - other.nanoseconds
    new_seconds + (new_nanoseconds / Util.NANOSECONDS_PER_SECOND)
  end

  def -(other)
    raise "Invalid Argument for Time#-: <(other.type)>"
  end
end
