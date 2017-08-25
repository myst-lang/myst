require "../spec_helper.cr"

describe "Functor Definition Semantics" do
  describe "when defined with `def`" do
    it "creates a functor entry in the current scope" do
      _, _, intr = run_program %q(
        def func
        end
      )

      intr.symbol_table["func"].should be_a(TFunctor)
    end

    it "allows multiple definitions with the same name" do
      _, _, intr = run_program %q(
        def func
        end

        def func
        end
      )

      intr.symbol_table["func"].should be_a(TFunctor)
    end
  end
end
