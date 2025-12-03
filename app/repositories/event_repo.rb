# frozen_string_literal: true
module Repositories
  class EventRepo < TaoPress::Repository
    def listing(limit: nil)
      ds = dataset
        .reverse_order(:tstamp)

      ds = ds.limit(limit) if limit
      result = ds.all

      result
    end

    def find(id)
      dataset.where(id: id).first
    end

    private

    def dataset
      @dataset ||= db[:tl_calendar_events]
    end
  end
end

