module Spree
  class ProductsController < Spree::StoreController
    before_action :load_product, only: :show
    before_action :load_taxon, only: :index

    rescue_from ActiveRecord::RecordNotFound, :with => :render_404
    helper 'spree/taxons'

    respond_to :html

    def index
      @searcher = build_searcher(params.merge(include_images: true))
      #@products = @searcher.retrieve_products
      @products = [
  {
    :name => "Ruby on Rails Tote",
    :tax_category => clothing,
    :shipping_category => shipping_category,
    :price => 15.99,
    :eur_price => 14,
  },
  {
    :name => "Ruby on Rails Bag",
    :tax_category => clothing,
    :shipping_category => shipping_category,
    :price => 22.99,
    :eur_price => 19,
  },
  {
    :name => "Ruby on Rails Baseball Jersey",
    :tax_category => clothing,
    :shipping_category => shipping_category,
    :price => 19.99,
    :eur_price => 16
  },
  {
    :name => "Ruby on Rails Jr. Spaghetti",
    :tax_category => clothing,
    :shipping_category => shipping_category,
    :price => 19.99,
    :eur_price => 16

  },
  {
    :name => "Ruby on Rails Ringer T-Shirt",
    :shipping_category => shipping_category,
    :tax_category => clothing,
    :price => 19.99,
    :eur_price => 16
  },
  {
    :name => "Ruby Baseball Jersey",
    :tax_category => clothing,
    :shipping_category => shipping_category,
    :price => 19.99,
    :eur_price => 16
  },
  {
    :name => "Apache Baseball Jersey",
    :tax_category => clothing,
    :shipping_category => shipping_category,
    :price => 19.99,
    :eur_price => 16
  },
  {
    :name => "Spree Baseball Jersey",
    :tax_category => clothing,
    :shipping_category => shipping_category,
    :price => 19.99,
    :eur_price => 16
  },
  {
    :name => "Spree Jr. Spaghetti",
    :tax_category => clothing,
    :shipping_category => shipping_category,
    :price => 19.99,
    :eur_price => 16
  },
  {
    :name => "Spree Ringer T-Shirt",
    :tax_category => clothing,
    :shipping_category => shipping_category,
    :price => 19.99,
    :eur_price => 16
  },
  {
    :name => "Spree Tote",
    :tax_category => clothing,
    :shipping_category => shipping_category,
    :price => 15.99,
    :eur_price => 14,
  },
  {
    :name => "Spree Bag",
    :tax_category => clothing,
    :shipping_category => shipping_category,
    :price => 22.99,
    :eur_price => 19
  },
  {
    :name => "Ruby on Rails Mug",
    :shipping_category => shipping_category,
    :price => 13.99,
    :eur_price => 12
  },
  {
    :name => "Ruby on Rails Stein",
    :shipping_category => shipping_category,
    :price => 16.99,
    :eur_price => 14
  },
  {
    :name => "Spree Stein",
    :shipping_category => shipping_category,
    :price => 16.99,
    :eur_price => 14,
  },
  {
    :name => "Spree Mug",
    :shipping_category => shipping_category,
    :price => 13.99,
    :eur_price => 12
  }
]
      @taxonomies = Spree::Taxonomy.includes(root: :children)
    end

    def show
      @variants = @product.variants_including_master.active(current_currency).includes([:option_values, :images])
      @product_properties = @product.product_properties.includes(:property)
      @taxon = Spree::Taxon.find(params[:taxon_id]) if params[:taxon_id]
      redirect_if_legacy_path
    end

    private

      def accurate_title
        if @product
          @product.meta_title.blank? ? @product.name : @product.meta_title
        else
          super
        end
      end

      def load_product
        if try_spree_current_user.try(:has_spree_role?, "admin")
          @products = Product.with_deleted
        else
          @products = Product.active(current_currency)
        end
        @product = @products.friendly.find(params[:id])
      end

      def load_taxon
        @taxon = Spree::Taxon.find(params[:taxon]) if params[:taxon].present?
      end

      def redirect_if_legacy_path
        # If an old id or a numeric id was used to find the record,
        # we should do a 301 redirect that uses the current friendly id.
        if params[:id] != @product.friendly_id
          params.merge!(id: @product.friendly_id)
          return redirect_to url_for(params), status: :moved_permanently
        end
      end
  end
end
