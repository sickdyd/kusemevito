if ENV['CLUSTER_SERVICE_ACCOUNT_TOKEN'].nil? || ENV['CLUSTER_SERVICE_ACCOUNT_TOKEN'].empty?
  raise 'Environment variable CLUSTER_SERVICE_ACCOUNT_TOKEN is not set or empty'
end
