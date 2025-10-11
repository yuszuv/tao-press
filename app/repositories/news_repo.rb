# frozen_string_literal: true
module Repositories
  class NewsRepo < Repository
    # veröffentlichte News (Contao-Logik: published + start/stop)
    def listing(limit: nil)
      ds = dataset
        # .where(published: 1)
        # .where(Sequel.lit("(start = 0 OR start <= UNIX_TIMESTAMP())"))
        # .where(Sequel.lit("(stop = 0 OR stop  > UNIX_TIMESTAMP())"))
        .reverse_order(:date)

      ds = ds.limit(limit) if limit
      ds.all
    rescue Sequel::Error => e
      raise Application::Error.new(:db_error, error: e)
    end

    def find(id)
      dataset.where(id: id).first
    rescue Sequel::Error => e
      raise Application::Error.new(:db_error, error: e)
    end

    private

    def dataset
      @dataset ||= db[:tl_news]
    end
  end
end
