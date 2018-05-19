module Sitemapper
  # https://developers.google.com/webmasters/videosearch/sitemaps
  record VideoMap, 
      thumbnail_loc : String,
      title : String,
      description : String,
      content_loc : String? = nil,
      player_loc : String? = nil,
      duration : Int32? = nil,
      expiration_date : String? = nil,
      rating : Float64? = nil,
      view_count : Int32? = nil,
      publication_date : String? = nil,
      family_friendly : String = "yes",      # "yes" or "no"
      tag : String? = nil,
      category : String? = nil,
      restriction : String? = nil,
      gallery_loc : String? = nil,
      price : String? = nil,
      requires_subscription : String = "no", # "yes" or "no"
      uploader : String? = nil,
      platform : Tuple(String, String)? = nil,     # {"allow", "web mobile"} or {"deny", "mobile tv"}
      live : String = "no" do                # "yes" or "no"
    
    def render_xml(xml : XML::Builder)
      xml.element("video:video") do
        xml.element("video:thumbnail_loc") { xml.text(thumbnail_loc) }
        xml.element("video:title") { xml.text(title) }
        xml.element("video:description") { xml.text(description) }
        xml.element("video:content_loc") { xml.text(content_loc.as(String)) } unless content_loc.nil?
        xml.element("video:player_loc") { xml.text(player_loc.as(String)) } if content_loc.nil? && !player_loc.nil?
        xml.element("video:duration") { xml.text(duration.as(Int32).to_s) } unless duration.nil?
        xml.element("video:expiration_date") { xml.text(expiration_date.as(String)) } unless expiration_date.nil?
        xml.element("video:rating") { xml.text(rating.as(Float64).to_s) } unless rating.nil?
        xml.element("video:view_count") { xml.text(view_count.as(Int32).to_s) } unless view_count.nil?
        xml.element("video:publication_date") { xml.text(publication_date.as(String)) } unless publication_date.nil?
        xml.element("video:family_friendly") { xml.text(family_friendly) }
        xml.element("video:tag") { xml.text(tag.as(String)) } unless tag.nil?
        xml.element("video:category") { xml.text(category.as(String)) } unless category.nil?
        xml.element("video:restriction") { xml.text(restriction.as(String)) } unless restriction.nil?
        xml.element("video:gallery_loc") { xml.text(gallery_loc.as(String)) } unless gallery_loc.nil?
        xml.element("video:price") { xml.text(price.as(String)) } unless price.nil?
        xml.element("video:requires_subscription") { xml.text(requires_subscription) }
        xml.element("video:uploader") { xml.text(uploader.as(String)) } unless uploader.nil?
        unless platform.nil?
          plat = platform.as(Tuple(String, String))
          xml.element("video:platform", relationship: plat[0].to_s) { xml.text(plat[1].to_s) }
        end
        xml.element("video:live") { xml.text(live) }
      end
    end
  end
end
