module InvoicesHelper
  def status_badge(status)
    case status
    when "Cancelled"
      content_tag(:span, "Cancelled", class: "inline-flex px-2 text-xs font-semibold leading-5 text-red-800 bg-red-100 rounded-full")
    when "Refunded"
      content_tag(:span, "Refunded", class: "inline-flex px-2 text-xs font-semibold leading-5 text-yellow-800 bg-yellow-100 rounded-full")
    when "Completed"
      content_tag(:span, "Completed", class: "inline-flex px-2 text-xs font-semibold leading-5 text-green-800 bg-green-100 rounded-full")
    else
      content_tag(:span, status, class: "inline-flex px-2 text-xs font-semibold leading-5 text-gray-800 bg-gray-100 rounded-full")
    end
  end
end
