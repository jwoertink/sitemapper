struct AwsStorageConfig
  getter region : String
  getter key : String
  getter secret : String
  getter endpoint : String? = nil

  def initialize(@region : String, @key : String, @secret : String, @endpoint : String? = nil)
  end
end
