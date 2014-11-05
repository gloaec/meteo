class Event < ActiveRecord::Base
  belongs_to :program
  has_many :program_errors, class_name: "ProgramError", foreign_key: 'before_event_id', dependent: :destroy
  has_many :gap_errors, 
    -> { where code: ProgramError::GAP_ERROR..ProgramError::GAP_WARNING }, 
    class_name: 'ProgramError', foreign_key: 'before_event_id'
  has_many :duration_errors, 
    -> { where code: ProgramError::DURATION_ERROR..ProgramError::DURATION_WARNING }, 
    class_name: 'ProgramError', foreign_key: 'before_event_id'
  has_many :other_errors, 
    -> { where "code < ?", 0 }, 
    class_name: 'ProgramError', foreign_key: 'before_event_id'
end
