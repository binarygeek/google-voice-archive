namespace :import do
  def parse_text_message(message, sender_id, me_id)
    result = {:date => '', :sender_id => nil, :message => ''}
    temp = message.css('[class="dt"]')
    if temp.length == 1
      result[:date] = temp[0]['title']
    end
    temp = message.css('[class="fn"]')
    if temp.length == 1
      if temp[0].text == 'Me'
        result[:sender_id] = me_id
      else
        result[:sender_id] = sender_id
      end
    end
    temp = message.css('q')
    if temp.length == 1
      result[:message] = temp[0].text
    end
    return result
  end

  desc 'Import exported Google Voice data'
  task :data, [:data_directory] => :environment do |t, args|
    unless args.data_directory.present?
      raise "\nError!!!\n\tNot enough arguments...Usage: rake #{ARGV[0]}['data/directory/']\n\n"
    end
    if args.data_directory[args.data_directory.length-1].chr != '/'
      raise "\nError!!!\n\tThe passed in data directory must have a trailing path seperator: /\n\n"
    end

    call_path = args.data_directory + 'Calls/'
    phone_file = args.data_directory + 'Phones.vcf'
    call_files = Dir.glob("#{call_path}*.html")
    people = []
    user_first_name = nil
    user_last_name = nil
    account_sender = nil
    account_id = nil

    ################
    # Process VCARD
    ################
    card = Vcard.unfold(File.open(phone_file, mode='r')) #Vcard.decode(File.open(phone_file, mode='r'))
    card.each do |line|
      if /X-GTALK:/.match(line)
        vcard_email = line.sub('X-GTALK:', '')
        account_sender = Account[email: vcard_email]
        if account_sender.nil?
          # do create
          shell.say "Creating admin account for #{vcard_email}..."
          user_first_name = shell.ask "What is the FIRST name for #{vcard_email}?"
          user_last_name = shell.ask "What is the LAST name for #{vcard_email}?"
          password   = shell.ask "What PASSWORD do you want to use for #{vcard_email}?"

          if user_first_name.empty? || user_last_name.empty?
            shell.say 'ERROR!!!'
            shell.say "\tA first and last name must be entered!"
          else
            account = Account.create(email: vcard_email, first_name: user_first_name, last_name: user_last_name, password: password, password_confirmation: password, role: 'admin')
            if account.valid?
              account_id = account.id
              account_sender = account
              shell.say '================================================================='
              shell.say 'Account has been successfully created, now you can login with:'
              shell.say '================================================================='
              shell.say "       name: #{user_first_name} #{user_last_name}"
              shell.say "      email: #{vcard_email}"
              shell.say "   password: #{password}"
              shell.say '================================================================='
            else
              shell.say 'Sorry but something went wrong!'
              shell.say ''
              account.errors.full_messages.each { |m| shell.say "   - #{m}" }
            end
          end
          #raise "#{vcard_email} was not found associated to an Account. Make sure an Account is created with the email address associated to the Google Voice Data being imported."
        end
        account_id = account_sender.id
        user_first_name = account_sender.first_name
        user_last_name = account_sender.last_name
      end
      if /item1.TEL:+/.match(line)
        number = line.sub('item1.TEL:+', '')
        account_sender = Contact[number: number]
        if account_sender.nil?
          # do create
          user_first_name = shell.ask "What is the FIRST name of the person's data that is being imported?" unless user_first_name
          user_last_name = shell.ask "What is the LAST name of the person's data that is being imported?" unless user_last_name
          account_sender = Contact.new(account_id: account_id, number: number)
          if user_first_name && user_last_name
            account_sender[:name] = "#{user_first_name} #{user_last_name}"
          else
            account_sender[:name] = user_first_name if user_first_name
            account_sender[:name] = user_last_name if user_last_name
          end
          account_sender.save
        end
      end
    end

    call_files.each do |file_name|
      file = file_name.sub(call_path, '')
      name = /^([a-zA-z\s\d+]+)/.match(file).to_s.strip
      if !name.blank? && !people.include?(name)
        people.push(name)
      end
    end

    # overrides the PEOPLE to process files for!
    # change the array to include names you want to process
    # NOTE: This is useful for when in development and want
    # to test the import process for a few people without
    # it running for the entire data directory
    #people = ['Some Person', 'Another Person']

    people.each do |name|
      parsed_name = name.sub('+', '')
      person = Contact.find_or_create_by_value(parsed_name)
      ########################
      # Process Text Messages
      ########################
      text_files = Dir.glob("#{call_path}#{person.full_name_or_number()} - Text*.html")
      text_files.each do |text_file|
        doc = Nokogiri::HTML(File.open(text_file, mode='r')) do |config|
          config.strict.nonet
        end

        doc.css('div[class="message"]').each do |item|
          result = parse_text_message(item, person.id, account_sender.id)
          #foo = Time.parse(result[:date])
          Message.find_or_create(contact_id: person.id, sender_id: result[:sender_id], sent_at: result[:date], text: result[:message])
        end
      end
    end
  end
end