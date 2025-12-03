# frozen_string_literal: true
module Repositories
  class ContentRepo < TaoPress::Repository
    def for_news(news_id)
      dataset
        .where(ptable: "tl_news", pid: news_id)
        .order(:sorting)
        .all
    end

    def for_event(event_id)
      dataset
        .where(ptable: "tl_calendar_events", pid: event_id)
        .order(:sorting)
        .all
    end

    private

    def dataset
      @dataset ||= db[:tl_content]
    end

  end
end
