module Myst
  TBoolean::METHODS["to_s"] = TNativeFunctor.new do |this, _args, _block, _itr|
    TString.new(this.as(TBoolean).value ? "true" : "false")
  end
end
