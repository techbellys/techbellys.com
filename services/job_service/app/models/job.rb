class Job < ApplicationRecord
end


class Job < ApplicationRecord
  # If you don't have a full User model in this service, use optional: true
  belongs_to :user, optional: true

  # Optional validations
  validates :title, :description, :company, :location, presence: true
end
