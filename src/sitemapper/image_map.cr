module Sitemapper
  record ImageMap,
      loc : String,
      caption : String? = nil,
      geo_location : String? = nil,
      title : String? = nil,
      license : String? = nil do
  
    def render_xml(xml : XML::Builder)
      xml.element("image:image") do
        xml.element("image:loc") { xml.text(loc) }
        xml.element("image:caption") { xml.text(caption.as(String)) } unless caption.nil?
        xml.element("image:geo_location") { xml.text(geo_location.as(String)) } unless geo_location.nil?
        xml.element("image:title") { xml.text(title.as(String)) } unless title.nil?
        xml.element("image:license") { xml.text(license.as(String)) } unless license.nil?
      end
    end
  end
end
