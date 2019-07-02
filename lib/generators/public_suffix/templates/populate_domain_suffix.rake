desc "Reads the Public Suffix list from the data file and store it in database"
task insert_into_db: :environment do
  comment_token = "//".freeze
  private_token = "===BEGIN PRIVATE DOMAINS===".freeze
  section = nil # 1 == ICANN, 2 == PRIVATE
  file_path = File.join(Gem.loaded_specs['public_suffix'].full_gem_path,'data','list.txt')
  File.open(file_path).each do |line|
    # line = line.force_encoding('iso-8859-1').encode('utf-8')
    line.strip!
    case # rubocop:disable Style/EmptyCaseConditio
            
    # skip blank lines
    when line.empty?
      next

    when line.include?(private_token)
      section = 2

    # skip comments
    when line.start_with?(comment_token)
      next

    else
      domainsuffix = DomainSuffix.create(name: line,private: section==2)
      domainsuffix.save
    end
  end
end
