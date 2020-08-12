# frozen_string_literal: true
module Gumball
  describe Dispenser do
    def now
      Time.now.to_i
    end

    it "lives for a bit, and then refreshes" do
      ttl = 5
      data = described_class.new(ttl) { now }.on_change { |_, nv| @about = {new_value: nv, now: now} }
      data.item # this "primes" it

      n = now
      5.times { expect(data.item).to be <= n }
      expect(@about).to be nil

      sleep ttl - 1
      5.times { expect(data.item).to be <= n }
      expect(@about).to be nil

      sleep 2
      5.times { expect(data.item).to be > n }
      expect(@about[:new_value]).to eq data.item
      expect(@about[:now]).to be > n
    end
  end
end
