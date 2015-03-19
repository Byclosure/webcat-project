module SummaryHelper
  def self.subTypeToString(subtype)
    ScenarioCategories.subTypeToString(subtype)
  end

  def self.typeToString(type)
    ScenarioCategories.typeToString(type)
  end
end
