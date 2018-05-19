module Sitemapper
  record ImageMap,
      loc : String,
      caption : String? = nil,
      geo_location : String? = nil,
      title : String? = nil,
      license : String? = nil do
  
    def render_xml(xml : XML::Builder)
      xml.element("image:image") do

      end
    end
  end
end
