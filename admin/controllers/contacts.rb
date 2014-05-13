GoogleVoiceArchive::Admin.controllers :contacts do
  get :index do
    @title = "Contacts"
    @contacts = Contact.where(account_id: nil) # only show contacts that are NOT associated to the Account
    render 'contacts/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'contact')
    @contact = Contact.new
    render 'contacts/new'
  end

  post :create do
    @contact = Contact.new(params[:contact])
    if (@contact.save rescue false)
      @title = pat(:create_title, :model => "contact #{@contact.id}")
      flash[:success] = pat(:create_success, :model => 'Contact')
      params[:save_and_continue] ? redirect(url(:contacts, :index)) : redirect(url(:contacts, :edit, :id => @contact.id))
    else
      @title = pat(:create_title, :model => 'contact')
      flash.now[:error] = pat(:create_error, :model => 'contact')
      render 'contacts/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "contact #{params[:id]}")
    @contact = Contact[params[:id]]
    if @contact
      render 'contacts/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'contact', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "contact #{params[:id]}")
    @contact = Contact[params[:id]]
    if @contact
      if @contact.modified! && @contact.update(params[:contact])
        flash[:success] = pat(:update_success, :model => 'Contact', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:contacts, :index)) :
          redirect(url(:contacts, :edit, :id => @contact.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'contact')
        render 'contacts/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'contact', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Contacts"
    contact = Contact[params[:id]]
    if contact
      if contact.destroy
        flash[:success] = pat(:delete_success, :model => 'Contact', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'contact')
      end
      redirect url(:contacts, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'contact', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Contacts"
    unless params[:contact_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'contact')
      redirect(url(:contacts, :index))
    end
    ids = params[:contact_ids].split(',').map(&:strip)
    contacts = Contact.where(:id => ids)
    
    if contacts.destroy
    
      flash[:success] = pat(:destroy_many_success, :model => 'Contacts', :ids => "#{ids.to_sentence}")
    end
    redirect url(:contacts, :index)
  end
end