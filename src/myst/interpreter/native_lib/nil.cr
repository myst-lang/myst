module Myst
  TNil::METHODS["to_s"] = TNativeFunctor.new do |_this, _args, _block, _itr|
    TString.new("nil")
  end
end
