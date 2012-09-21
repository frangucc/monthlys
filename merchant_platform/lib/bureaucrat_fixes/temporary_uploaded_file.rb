require "bureaucrat/temporary_uploaded_file"

class Bureaucrat::TemporaryUploadedFile
  attr_accessor :size

  alias_method :original_filename, :filename

  def read(*args, &block)
    tempfile.read(*args, &block)
  end
end
