# encoding: utf-8

class FileUploader < CarrierWave::Uploader::Base
  storage :fog

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  #def default_url
  #  "/assets/default/" + [model.class.to_s.underscore, mounted_as.to_s + ".png"].compact.join('-')
  #end
end

