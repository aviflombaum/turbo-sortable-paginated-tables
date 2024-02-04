class CreateInvoices < ActiveRecord::Migration[7.2]
  def change
    create_table :invoices do |t|
      t.string :status
      t.integer :amount

      t.timestamps
    end
  end
end
