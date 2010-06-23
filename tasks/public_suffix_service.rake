task :download_definitions do
  require "net/http"

  DEFINITION_URL = "http://mxr.mozilla.org/mozilla-central/source/netwerk/dns/src/effective_tld_names.dat?raw=1"

  File.open("lib/public_suffix_service/definitions.dat", "w+") do |f|
    response = Net::HTTP.get_response(URI.parse(DEFINITION_URL))
    f.write(response.body)
  end
end