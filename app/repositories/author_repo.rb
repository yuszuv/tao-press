module Repositories
  class AuthorRepo < TaoPress::Repository
    def find(id)
      dataset
        .where(id:)
        .select(:name, :email)
        .first
    end

    private

    def dataset
      @dataset ||= db[:tl_user]
    end
  end
end
