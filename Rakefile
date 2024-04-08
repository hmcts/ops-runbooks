require 'middleman-gh-pages'
require 'html-proofer'

ENV["COMMIT_MESSAGE_SUFFIX"] = "[skip ci]"
ENV["BRANCH_NAME"] = "ghpages"

token = ENV.fetch('GH_TOKEN', nil)
proofer = HTMLProofer.check_directory("./build", 
    { 
        :check_external_hash => false,
        :check_internal_hash => false,
        :ignore_missing_alt => true,
        :ignore_status_codes => [403]
    })


proofer.before_request do |request|
    request.options[:headers]["Authorization"] = "Bearer #{token}" if request.base_url.include?("https://github.com")
end

# Run HTML Proofer against built HTML files
proofer.run