# frozen_string_literal: true

require "nummy/member_enumerable"

module Fixtures
  module MemberEnumerable
    Empty = Data.define { include Nummy::MemberEnumerable }

    ValueCollection =
      Data.define(:foo, :bar, :baz) { include Nummy::MemberEnumerable }
  end
end
