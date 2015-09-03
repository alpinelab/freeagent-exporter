module ApplicationHelper
  def flash_class(level)
    case level
      when "notice"  then "info"
      when "success" then "positive"
      when "alert"   then "warning"
      when "error"   then "negative"
    end
  end
end
