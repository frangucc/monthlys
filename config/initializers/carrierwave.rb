CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: 'AWS',
    aws_access_key_id: Monthly::Config::S3_KEY,
    aws_secret_access_key: Monthly::Config::S3_SECRET,
    region: 'us-east-1' # optional, defaults to 'us-east-1'
  }
  config.fog_directory  =  Monthly::Config::S3_BUCKET
  # config.fog_host       = 'https://assets.example.com'            # optional, defaults to nil
  # config.fog_public     = false                                   # optional, defaults to true
  # config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end
