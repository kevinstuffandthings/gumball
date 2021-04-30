# frozen_string_literal: true

module Gumball
  describe Dispenser do
    def now = Time.now.to_i

    let(:ttl) { 5 }
    let(:logger) { nil }
    let(:subject) { described_class.new(ttl, logger: logger) { now }.on_change { |_, nv| @about = {new_value: nv, now: now} } }

    it "lives for a bit, and then refreshes" do
      subject.item # this "primes" it

      n = now
      5.times { expect(subject.item).to be <= n }
      expect(@about).to be nil

      sleep ttl - 1
      5.times { expect(subject.item).to be <= n }
      expect(@about).to be nil

      sleep 2
      5.times { expect(subject.item).to be > n }
      expect(@about[:new_value]).to eq subject.item
      expect(@about[:now]).to be > n
    end

    context "with logger" do
      let(:log) { StringIO.new }
      let(:logger) { Logger.new(log) }
      let(:log_lines) { log.string.lines }

      it "lives for a bit, and then refreshes" do
        subject.item # this "primes" it

        n = now
        5.times { expect(subject.item).to be <= n }
        expect(@about).to be nil

        sleep ttl - 1
        5.times { expect(subject.item).to be <= n }
        expect(@about).to be nil

        sleep 2
        5.times { expect(subject.item).to be > n }
        expect(@about[:new_value]).to eq subject.item
        expect(@about[:now]).to be > n

        expect(log_lines.length).to eq 3
        expect(log_lines[0]).to include("INFO", described_class.to_s, "refreshed, new_value=")
        expect(log_lines[1]).to include("INFO", described_class.to_s, "refreshed, new_value=")
        expect(log_lines[2]).to include("DEBUG", described_class.to_s, "executing on_change")
      end
    end
  end
end
