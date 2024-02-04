class InvoicesController < ApplicationController
  def index
    sort_column = params[:sort] || "created_at"
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"

    @invoices = Invoice.order("#{sort_column} #{sort_direction}").page(params[:page]).per(10)
  end
end
