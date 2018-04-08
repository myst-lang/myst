require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - Doc" do
  it "creates a new entry in the doc table" do
    itr = parse_and_interpret %q(
      #doc foo -> nil
      #| Some documentation.
    )

    entry = itr.doc_table["foo"]
    entry.reference.should eq("foo")
    entry.returns.should eq("nil")
    entry.content.should eq("Some documentation.")
  end

  it "handles reference paths for nested entries" do
    itr = parse_and_interpret %q(
      #doc List#foo -> nil
      #| Some documentation.
    )

    entry = itr.doc_table["List#foo"]
    entry.reference.should eq("List#foo")
    entry.returns.should eq("nil")
    entry.content.should eq("Some documentation.")
  end

  it "expands basic references to absolute static references" do
    itr = parse_and_interpret %q(
      defmodule Foo
        #doc foo -> nil
        #| Some documentation.
      end
    )

    entry = itr.doc_table["Foo.foo"]
    entry.reference.should eq("Foo.foo")
    entry.returns.should eq("nil")
    entry.content.should eq("Some documentation.")
  end

  it "expands relative instance references to absolute references" do
    itr = parse_and_interpret %q(
      deftype Foo
        #doc #foo -> nil
        #| Some documentation.
      end
    )

    entry = itr.doc_table["Foo#foo"]
    entry.reference.should eq("Foo#foo")
    entry.returns.should eq("nil")
    entry.content.should eq("Some documentation.")
  end

  it "expands relative static references to absolute references" do
    itr = parse_and_interpret %q(
      deftype Foo
        #doc .foo -> nil
        #| Some documentation.
      end
    )

    entry = itr.doc_table["Foo.foo"]
    entry.reference.should eq("Foo.foo")
    entry.returns.should eq("nil")
    entry.content.should eq("Some documentation.")
  end

  it "expands relative references based on the self stack" do
    itr = parse_and_interpret %q(
      defmodule Foo
        deftype Bar
          defmodule Baz
            #doc .foo -> nil
            #| Some documentation.
          end
        end
      end
    )

    entry = itr.doc_table["Foo.Bar.Baz.foo"]
    entry.reference.should eq("Foo.Bar.Baz.foo")
    entry.returns.should eq("nil")
    entry.content.should eq("Some documentation.")
  end


  it "properly expands reference paths based on the self stack" do
    itr = parse_and_interpret %q(
      defmodule Foo
        deftype Bar
        end

        #doc Bar.Baz#foo -> nil
        #| Some documentation.
      end
    )

    entry = itr.doc_table["Foo.Bar.Baz#foo"]
    entry.reference.should eq("Foo.Bar.Baz#foo")
    entry.returns.should eq("nil")
    entry.content.should eq("Some documentation.")
  end
end
