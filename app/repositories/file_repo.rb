# frozen_string_literal: true
require "php_serialize"

module Repositories
  class FileRepo < TaoPress::Repository
    def find(uuid)
      # uuid = extract_uuids(blob).first

      dataset
        .where(uuid: uuid)
        .first
    end

    def extract_uuids(blob)
      blob ? PHP.unserialize(blob) : []
    end

    # Aus Binär(16) die Dateipfad ermitteln
    def path_for_uuid_bin(bin_uuid)
      return nil unless bin_uuid
      @files.where(uuid: Sequel.blob(bin_uuid)).get(:path)
    end

    # Aus String-UUID (z.B. aus {{file::...}}) die Dateipfad ermitteln
    def path_for_uuid_str(uuid_str)
      return nil unless uuid_str
      bin = App::Support::UUID.str_to_bin(uuid_str)
      path_for_uuid_bin(bin)
    end

    private

    def dataset
      @dataset ||= db[:tl_files]
    end
  end
end
