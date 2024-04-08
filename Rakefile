require 'middleman-gh-pages'
require 'html-proofer'

ENV["COMMIT_MESSAGE_SUFFIX"] = "[skip ci]"
ENV["BRANCH_NAME"] = "ghpages"

proofer = HTMLProofer.check_directory("./build", 
    { 
        :check_external_hash => false,
        :check_internal_hash => false,
        :ignore_missing_alt => true,
        :ignore_status_codes => [0, 401, 403],
        # Ignore private repo urls as auth with this tool is a nightmare
        :ignore_urls =>  [%r{.*github\.com\/hmcts.*}] 
    })

# Run HTML Proofer against built HTML files
proofer.run