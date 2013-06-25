module Forem
  module Admin
    class CategoriesController < BaseController
      before_filter :find_category, :only => [:edit, :update, :destroy]
      before_filter :find_categories, :only => :index

      def new
        @category =  Forem::Category.new
      end

      def create
        if @category = Forem::Category.create(params[:category])
          create_successful
        else
          create_failed
        end
      end

      def update
        if @category.update_attributes(params[:category])
          update_successful
        else
          update_failed
        end
      end

      def destroy
        @category.destroy
        destroy_successful
      end

      private
      def find_category
        @category = Forem::Category.find(params[:id])
      end

      def find_categories
        @categories = Forem::Category.all
      end

      def create_successful
        flash[:notice] = t("forem.admin.category.created")
        redirect_to admin_categories_path
      end

      def create_failed
        flash.now.alert = t("forem.admin.category.not_created")
        render :action => "new"
      end

      def destroy_successful
        flash[:notice] = t("forem.admin.category.deleted")
        redirect_to admin_categories_path
      end

      def update_successful
        flash[:notice] = t("forem.admin.category.updated")
        redirect_to admin_categories_path
      end

      def update_failed
        flash.now.alert = t("forem.admin.category.not_updated")
        render :action => "edit"
      end

    end
  end
end
