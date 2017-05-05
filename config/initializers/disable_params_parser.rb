# We're doing our own JSON parsing, and error handling.
# If this is in place it causes several problems:
#
# Firstly, it pollutes the params hash with data from the json request, which
# leads to confusion when there is a param in the routes and in the json.
#
# Secondly, when given invalid json, it blows up before even reaching the
# application, preventing us from handling invalid json gracefully.
#
# Thirdly, empty arrays are converted to nil, which is not compatible with
# validation against the schema - we want to require a given key, but allow the
# value to be an empty array.
Rails.application.config.middleware.delete ActionDispatch::ParamsParser
