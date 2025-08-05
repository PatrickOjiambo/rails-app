module ApplicationHelper
    def status_color(status)
  case status
  when 'pending' then 'text-yellow-600'
  when 'processing' then 'text-blue-600'
  when 'complete' then 'text-green-600'
  when 'failed' then 'text-red-600'
  else 'text-gray-600'
  end
end
end
