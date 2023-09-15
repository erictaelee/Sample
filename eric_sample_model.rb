# frozen_string_literal: true

# It is a model to represent applications and processes for the GB to detect and shutdown
class Sample < ApplicationRecord
  enum os_name: %i(win32 darwin)
  validates :os_name, presence: true
  validates :unpermitted_application, presence: true

  scope :order_by_name, -> { order('LOWER(unpermitted_application)') }

  def self.application_denylist
    result = select(:os_name, :unpermitted_application, :one_time_shutdown).
             pluck(:os_name, :unpermitted_application, :one_time_shutdown)

    result.each_with_object({}) do |entry, denylist|
      os_name = entry[0]
      application = entry[1]
      one_time_shutdown = entry[2]

      denylist[os_name] ||= []
      denylist[os_name] << {
        application:       application,
        one_time_shutdown: one_time_shutdown,
      }
    end
  end
end
