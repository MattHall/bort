class Admin::<%= controller_class_name %>Controller < ApplicationController
  before_filter :load_<%= file_name %>, :login_required
  layout 'admin'
  
  def index
    @<%= table_name %> = <%= class_name %>.paginate(
      :per_page => 20,
      :page => params[:page])
  end

  def new
    @<%= file_name %> = <%= class_name %>.new
  end

  def edit

  end

  def create
    @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>])

    if @<%= file_name %>.save
      flash[:notice] = '<%= class_name %> was successfully created.'
      redirect_to admin_<%= table_name %>_url
    else
      render :action => :new
    end
  end

  def update
    if @<%= file_name %>.update_attributes(params[:<%= file_name %>])
      flash[:notice] = '<%= class_name %> was successfully updated.'
      redirect_to edit_admin_<%= file_name %>_path(@<%= file_name %>)
    else
      render :action => :edit
    end
  end

  def destroy
    @<%= file_name %>.destroy
    flash[:notice] = '<%= class_name %> has been deleted.'
    redirect_to admin_<%= table_name %>_url
  end
  
  protected
  
  def load_<%= file_name %>
    @<%= file_name %> = <%= class_name %>.find(params[:id]) if params[:id]
  end
end
