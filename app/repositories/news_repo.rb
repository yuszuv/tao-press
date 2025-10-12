# frozen_string_literal: true
module Repositories
  class NewsRepo < TaoPress::Repository
    # veröffentlichte News (Contao-Logik: published + start/stop)
    def listing(limit: nil)
      ds = dataset
        # .where(published: 1)
        # .where(Sequel.lit("(start = 0 OR start <= UNIX_TIMESTAMP())"))
        # .where(Sequel.lit("(stop = 0 OR stop  > UNIX_TIMESTAMP())"))
        .reverse_order(:date)

      ds = ds.limit(limit) if limit
      result = ds.all

      result
    end

    def find(id)
      dataset.where(id: id).first
    # rescue Sequel::Error => e
    #   logger.error("Database error in news_repo.find", error: e.message, id: id)
    #   raise Application::Error.new(:db_error, error: e)
    end

    private

    def dataset
      @dataset ||= db[:tl_news]
    end
  end
end
