GoogleVoiceArchive::Admin.controllers :messages do

  get :show, :with => :id do
    @contact = Contact[params[:id]]
    @title = "Messages for #{@contact.full_name_or_number()}"
    if @contact
      @messages = @contact.messages
      render 'messages/index'
    else
      flash[:warning] = pat(:create_error, :model => 'contact', :id => "#{params[:id]}")
      halt 404
    end
  end

  get :index do
    #redirect_url(:messages, :show, :id => params[:id])
  end

  get :new do
    #@title = pat(:new_title, :model => 'contact')
    @messsage = Message.new
    render 'messages/new'
  end

  get :edit, :with => :id do
    @message = Message[params[:id]]
    render 'messages/edit'
  end

  put :update, :with => :id do
    #@title = pat(:update_title, :model => "contact #{params[:id]}")
    @messsage = Message[params[:id]]
    if @messsage
      if @messsage.modified! && @messsage.update(params[:message])
        flash[:success] = pat(:update_success, :model => 'Message', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
            redirect(url(:messages, :index)) :
            redirect(url(:messages, :edit, :id => @messsage.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'message')
        render 'messages/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'message', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    logger.debug("Do Something...")
  end
end