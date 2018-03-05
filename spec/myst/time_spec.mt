require "stdlib/spec.mt"

describe("Time#initialize") do
  it("instantiates second, nanosecond") do
    t = %Time{63618825600, 10}
    assert(t.year).equals(2017)
    assert(t.month).equals(1)
    assert(t.day).equals(1)
    assert(t.hour).equals(0)
    assert(t.minute).equals(0)
    assert(t.second).equals(0)
    assert(t.nanosecond).equals(10)
  end

  it("instantiates year, month, day") do
    t = %Time{2017, 1, 2}
    assert(t.year).equals(2017)
    assert(t.month).equals(1)
    assert(t.day).equals(2)
    assert(t.hour).equals(0)
    assert(t.minute).equals(0)
    assert(t.second).equals(0)
    assert(t.nanosecond).equals(0)
  end

  it("instantiates year, month, day, hour") do
    t = %Time{2017, 1, 2, 3}
    assert(t.year).equals(2017)
    assert(t.month).equals(1)
    assert(t.day).equals(2)
    assert(t.hour).equals(3)
    assert(t.minute).equals(0)
    assert(t.second).equals(0)
    assert(t.nanosecond).equals(0)
  end

  it("instantiates year, month, day, hour, minute") do
    t = %Time{2017, 1, 2, 3, 4}
    assert(t.year).equals(2017)
    assert(t.month).equals(1)
    assert(t.day).equals(2)
    assert(t.hour).equals(3)
    assert(t.minute).equals(4)
    assert(t.second).equals(0)
    assert(t.nanosecond).equals(0)
  end

  it("instantiates year, month, day, hour, minute, second") do
    t = %Time{2017, 1, 2, 3, 4, 5}
    assert(t.year).equals(2017)
    assert(t.month).equals(1)
    assert(t.day).equals(2)
    assert(t.hour).equals(3)
    assert(t.minute).equals(4)
    assert(t.second).equals(5)
    assert(t.nanosecond).equals(0)
  end

  it("instantiates year, month, day, hour, minute, second, nanosecond") do
    t = %Time{2017, 1, 2, 3, 4, 5, 6}
    assert(t.year).equals(2017)
    assert(t.month).equals(1)
    assert(t.day).equals(2)
    assert(t.hour).equals(3)
    assert(t.minute).equals(4)
    assert(t.second).equals(5)
    assert(t.nanosecond).equals(6)
  end

  it("raises invalid time") do
    assert{ %Time{5, 10000000000} }.raises
    assert{ %Time{100000, 10, 1} }.raises
    assert{ %Time{2017, 15, 1} }.raises
    assert{ %Time{2017, 10, 40} }.raises
    assert{ %Time{2017, 10, 15, 600} }.raises
    assert{ %Time{2017, 10, 15, 12, 65} }.raises
    assert{ %Time{2017, 10, 15, 12, 59, 61} }.raises
    assert{ %Time{2017, 10, 15, 12, 59, 59, -1} }.raises
  end
end

describe("Time#to_s") do
  it("outputs the time") do
    t = %Time{2017, 10, 30, 21, 18, 13}
    assert(t.to_s).equals("2017-10-30 21:18:13")

    t = %Time{2017, 1, 30, 21, 18, 13}
    assert(t.to_s).equals("2017-01-30 21:18:13")

    t = %Time{2017, 10, 1, 21, 18, 13}
    assert(t.to_s).equals("2017-10-01 21:18:13")

    t = %Time{2017, 10, 30, 1, 18, 13}
    assert(t.to_s).equals("2017-10-30 01:18:13")

    t = %Time{2017, 10, 30, 21, 1, 13}
    assert(t.to_s).equals("2017-10-30 21:01:13")

    t = %Time{2017, 10, 30, 21, 18, 1}
    assert(t.to_s).equals("2017-10-30 21:18:01")
  end

  it("formats") do
    t = %Time{2017, 1, 2, 3, 4, 5}

    assert(t.to_s("%Y")).equals("2017")
    assert(t.to_s("%C")).equals("20")
    assert(t.to_s("%y")).equals("17")
    assert(t.to_s("%m")).equals("01")
    assert(t.to_s("%_m")).equals(" 1")
    assert(t.to_s("%_%_m2")).equals("%_ 12")
    assert(t.to_s("%-m")).equals("1")
    assert(t.to_s("%-%-m2")).equals("%-12")
    assert(t.to_s("%B")).equals("January")
    assert(t.to_s("%^B")).equals("JANUARY")
    assert(t.to_s("%^%^B2")).equals("%^JANUARY2")
    assert(t.to_s("%b")).equals("Jan")
    assert(t.to_s("%^b")).equals("JAN")
    assert(t.to_s("%h")).equals("Jan")
    assert(t.to_s("%^h")).equals("JAN")
    assert(t.to_s("%d")).equals("02")
    assert(t.to_s("%-d")).equals("2")
    assert(t.to_s("%e")).equals(" 2")
    assert(t.to_s("%j")).equals("002")
    assert(t.to_s("%H")).equals("03")
  end
end

describe("Time#-") do
  it("gives the difference between two times in seconds") do
    t1 = %Time{2017, 1, 2, 3, 4, 5}
    t2 = %Time{2017, 1, 2, 3, 4, 6}

    assert(t2 - t1).equals(1.0)
  end

  it("gives the difference between two times in seconds, negative") do
    t1 = %Time{2017, 1, 2, 3, 4, 5}
    t2 = %Time{2017, 1, 2, 3, 4, 6}

    assert(t1 - t2).equals(-1.0)
  end

  it("gives fractional seconds") do
    t1 = %Time{2017, 1, 2, 3, 4, 5, 7}
    t2 = %Time{2017, 1, 2, 3, 4, 6, 8}
    assert(t2 - t1).equals(1.000000001)
  end

  it("raises if a non Time type is passed") do
    t1 = %Time{2017, 1, 2, 3, 4, 5}
    assert{ t1 - nil }.raises
  end
end

describe("Time#year") do
  it("returns the year") do
    t = %Time{2017, 1, 2, 3, 4, 5}
    assert(t.year).equals(2017)
  end
end

describe("Time#month") do
  it("returns the month") do
    t = %Time{2017, 1, 2, 3, 4, 5}
    assert(t.month).equals(1)
  end
end

describe("Time#day") do
  it("returns the day") do
    t = %Time{2017, 1, 2, 3, 4, 5}
    assert(t.day).equals(2)
  end
end

describe("Time#hour") do
  it("returns the hour") do
    t = %Time{2017, 1, 2, 3, 4, 5}
    assert(t.hour).equals(3)
  end
end

describe("Time#minute") do
  it("returns the minute") do
    t = %Time{2017, 1, 2, 3, 4, 5}
    assert(t.minute).equals(4)
  end
end

describe("Time#second") do
  it("returns the second") do
    t = %Time{2017, 1, 2, 3, 4, 5}
    assert(t.second).equals(5)
  end
end

describe("Time#millisecond") do
  it("returns 0 when no nanoseconds") do
    t = %Time{2017, 1, 2, 3, 4, 5}
    assert(t.millisecond).equals(0)
  end

  it("returns the millisecond") do
    t = %Time{2017, 1, 2, 3, 4, 5, 6000000}
    assert(t.millisecond).equals(6)
  end
end

describe("Time#nanosecond") do
  it("returns the nanosecond") do
    t = %Time{2017, 1, 2, 3, 4, 5, 6}
    assert(t.nanosecond).equals(6)
  end
end
