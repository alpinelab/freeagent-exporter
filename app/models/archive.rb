class Archive < ActiveRecord::Base
  belongs_to :bank_account

  validates_presence_of :bank_account, :year
  validates_uniqueness_of :month, scope: :year

  def date
    Date.new(year, month, 01)
  end

end
