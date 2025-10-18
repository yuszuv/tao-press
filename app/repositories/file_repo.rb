# frozen_string_literal: true
require "php_serialize"

module Repositories
  class FileRepo < TaoPress::Repository
    def find(uuid_str)
      return nil unless uuid_str

      bin = Transformations.str_to_bin(uuid_str)

      find_by_bin(bin)
    end

    def find_by_bin(uuid_bin)
      dataset
        .where(uuid: uuid_bin)
        .first
    end

    private

    def dataset
      @dataset ||= db[:tl_files]
    end
  end
end
