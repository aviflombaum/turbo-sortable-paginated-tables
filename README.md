# Turbo Sortable Paginated Table

[Read the Full Article](https://code.avi.nyc/turbo-sortable-paginated-tables)

We're going to build a common UI pattern: a sortable, paginated table using the power of Ruby on Rails and Turbo Frames.

## Sortable Table Headers

The first step is to create the sortable table headers as simple links. I wrote a few helper methods in Ruby to make this easier.

```ruby
module ApplicationHelper
  def sortable_table_header(title, column, path_method, **)
    content_tag(:th, class: "invoices__th") do
      sortable_column(title, column, path_method)
    end
  end

  def sortable_column(title, column, path_method, **)
    direction = (column.to_s == params[:sort].to_s && params[:direction] == "asc") ? "desc" : "asc"

    query_params = request.query_parameters.merge(sort: column, direction: direction)

    path = send(path_method, query_params)
    link_to(path, class: "flex items-center", **) do
      concat title
      concat sort_icon(column)
    end
  end

  def sort_icon(column)
    return unless params[:sort].to_s == column.to_s

    if params[:direction] == "asc"
      svg_icon("M5 15l7-7 7 7")
    else
      svg_icon("M19 9l-7 7-7-7")
    end
  end

  def svg_icon(path_d)
    content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", class: "ml-1 inline w-4 h-4", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do
      "<path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='#{path_d}'></path>".html_safe
    end
  end
end
```

The important one is `sortable_column` which creates the link to with the sort and direction query parameters. With that method, we can make each table header a link to sort the table by that column, alternating between ascending and descending order. In our main view, we can use it like this:

```erb
<thead class="invoices__thead">
  <tr>
    <%= sortable_table_header 'ID', :id, :invoices_path, class: 'invoices__row--header' %>
    <%= sortable_table_header 'Amount', :amount, :invoices_path, class: 'invoices__row--header' %>
    <%= sortable_table_header 'Status', :status, :invoices_path, class: 'invoices__row--header' %>
    <%= sortable_table_header 'Created At', :created_at, :invoices_path, class: 'invoices__row--header' %>
  </tr>
</thead>
```

Now when you click on a column header, the table will be sorted by that column by making a full request to the server and redrawing the entire page, you know, the way links work out of the box. We'd also have to update our controller code to support the sort and direction params, so let's do that.

```ruby
class InvoicesController < ApplicationController
  def index
    sort_column = params[:sort] || "created_at"
    sort_direction = params[:direction].presence_in(%w[asc desc]) || "desc"

    @invoices = Invoice.order("#{sort_column} #{sort_direction}").page(params[:page]).per(10)
  end
end
```

I'm using the [kaminari](https://github.com/kaminari/kaminari) gem for pagination, so I'm using the `page` and `per` methods to paginate the results. The `order` method is used to sort the results by the column and direction specified in the query parameters. It works pretty well out of the box.

![Sortable Table](https://img.avi.nyc/JDjTfTkq+)

This is the nice, classic, beauty of Ruby on Rails. Clean backend code written in Ruby to do the heavy lifting, and simple, clean HTML to render the table. 

The only issue is that as you can see, every time we click on a column header, the browser is redrawing the entire page. Notice the `html`, `head`, and `body` tag being updated? 

That means that any other content on the page that won't need to be updated from the new request is redrawn anyway. 

In the spirit of reactive applications, we want to alter the dom as little as possible to keep the user experience smooth and fast and only redraw the updated part of the page, the table. That's where Turbo Frames come in.

## Turbo Frame Table

We're going to wrap the entire table in a turbo frame. A turbo frame is a container that can be updated without a full page reload. It's a way to make a part of the page reactive, but without the complexity of a frontend framework or even any change to our backend at all.

```erb
<%= turbo_frame_tag "invoices" do %>
  <div class="flow-root mt-8">
    <div class="-mx-4 -my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
      <div class="inline-block min-w-full py-2 align-middle sm:px-6 lg:px-8">
        <div class="invoices__table--shadow">
          <table class="invoices__table">
            <thead class="invoices__thead">
              <tr>
                <%= sortable_table_header 'ID', :id, :invoices_path, class: 'invoices__row--header' %>
                <%= sortable_table_header 'Amount', :amount, :invoices_path, class: 'invoices__row--header' %>
                <%= sortable_table_header 'Status', :status, :invoices_path, class: 'invoices__row--header' %>
                <%= sortable_table_header 'Created At', :created_at, :invoices_path, class: 'invoices__row--header' %>
              </tr>
            </thead>
            <tbody class="invoices__tbody">
              <% @invoices.each do |invoice| %>
                <tr>
                  <td class="invoices__row invoices__row--id">
                    <%= invoice.id %>
                  </td>
                  <td class="invoices__row invoices__row--amount">
                    <%= number_to_currency(invoice.amount) %>
                  </td>
                  <td class="invoices__row invoices__row--status">
                    <%= status_badge(invoice.status) %>
                  </td>
                  <td class="invoices__row invoices__row--created-at">
                    <%= invoice.created_at.strftime('%m/%d/%Y') %>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <%= paginate @invoices %>
  </div>
<% end %>
```

The cool thing is that any link within the turbo frame when clicked will automatically change the source property of its parent frame to the href of the link. This means that when we click on a sortable column header, the turbo frame will automatically update itself with the new sorted table. No need to write any JavaScript or even any additional backend code. It just works.

![Turbo Frame Table](https://img.avi.nyc/4Xf8SQpw+)

With the update, the browser is no longer redrawing the entire page. It's only redrawing the turbo frame, which is the table. This makes the user experience much smoother and faster and means any other content on the page will be maintained and not rerendered or anything. It's just way less work for the browser.

That's really it. The only issue is that clicking on a column header doesn't change the URL, so you can't share the state of the sorted table with anyone. But fixing that is easy with Turbo. By adding a [`data-turbo-action="advance"`](https://turbo.hotwired.dev/handbook/frames#promoting-a-frame-navigation-to-a-page-visit) attribute to the link, we can change the URL without a full page reload, essentially advancing the page state to the new sorted table URL, but only redrawing the turbo frame.

I updated the `sortable_column` method to include the `data-turbo-action` attribute.

```ruby
def sortable_column(title, column, path_method, **)
  direction = (column.to_s == params[:sort].to_s && params[:direction] == "asc") ? "desc" : "asc"

  query_params = request.query_parameters.merge(sort: column, direction: direction)

  path = send(path_method, query_params)
  link_to(path, data: {turbo_action: "advance"}, class: "flex items-center", **) do
    concat title
    concat sort_icon(column)
  end
end
```

With that we can see that the URL changes when we click on a column header, but only the table is redrawn.

![Turbo Frame Table with URL](https://img.avi.nyc/svsXFjlN+)

Now you can share the state of the sort with people.

## Conclusion

I wish there was more to say about implementing this feature, it's just so simple and easy to do with Turbo and Rails. I also updated the pagination links to use the `data-turbo-action="advance"` attribute so that the URL changes when you click on a page number, but only the table is redrawn.

The rest of the code in the application is worth exploring for some nice `BEM` and `Tailwind` patterns, but the main feature is the sortable, paginated table. Checkout the final source:

- [Sortable Table Helper](https://github.com/aviflombaum/turbo-sortable-paginated-tables/blob/main/app/helpers/application_helper.rb)
- [Sortable Table View](https://github.com/aviflombaum/turbo-sortable-paginated-tables/blob/main/app/views/invoices/index.html.erb)
- [Sortable Table Controller](https://github.com/aviflombaum/turbo-sortable-paginated-tables/blob/main/app/controllers/invoices_controller.rb)
- [Kaminari Pagination for Tailwind](https://github.com/aviflombaum/turbo-sortable-paginated-tables/tree/main/app/views/kaminari)
- [BEM Style Tailwind CSS Tables](https://github.com/aviflombaum/turbo-sortable-paginated-tables/blob/main/app/assets/stylesheets/application.tailwind.css#L79-L116)

You can checkout the full source code [Github](https://github.com/aviflombaum/turbo-sortable-paginated-tables) and play with it at [Turbo Sortable Paginated Tables](https://avi.nyc/turbo-sortable-paginated-tables).

If you have any questions or comments or just liked the demo, feel free to reach out to me on [X](https://twitter.com/aviflombaum).
