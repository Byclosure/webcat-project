class WebcatIntent
  attr_accessor :type, :value
  
  def self.ci
    self.basic_config
  end

  def self.single_feature(feature)
    intent = self.basic_config
    intent.value << feature

    intent
  end
  
  def from_json(json_string)
    json = JSON.parse(json_string)
    @type = json['type']
    @value = json['value']
  end

  def to_json
    {"type" => self.type, "value" => self.value }.to_json
  end

  private
  def self.basic_config
    intent = WebcatIntent.new
    intent.type = "features"
    intent.value = []

    intent
  end
end