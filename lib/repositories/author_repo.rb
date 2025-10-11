module Repositories
  class AuthorRepo
    include Import[
      'db'
    ]

    def find(id)
      dataset
        .where(id: id)
        .select(:name, :email)
        .first
    end

    private

    def dataset
      @dataset ||= db[:tl_user]
    end
  end
end
