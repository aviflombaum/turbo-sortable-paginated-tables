class InvoicesController < ApplicationController
  def index
    sort_column = params[:sort] || "created_at"
    sort_direction = params[:direction].presence_in(%w[asc desc]) || "desc"

    @invoices = Invoice.order("#{sort_column} #{sort_direction}").page(params[:page]).per(10)
  end
end
