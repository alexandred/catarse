require 'money'
class CharityDecorator < Draper::Decorator
  decorates :project
  include Draper::LazyHelpers

  def display_image(version = 'project_thumb' )
    if source.uploaded_image.present?
      source.uploaded_image.send(version).url
    elsif source.video_thumbnail.url.present?
      source.video_thumbnail.send(version).url
    elsif source.video
      source.video.thumbnail_large
    end
  end

  def display_video_embed_url
    if source.video_embed_url
      "#{source.video_embed_url}?title=0&byline=0&portrait=0&autoplay=0"
    end
  end
  
  def currency_symbol
    currency.symbol
  end
  
  def currency_delimiter
    currency.delimiter
  end
  
  def currency
    ::Money::Currency.new(source.currency)
  end
end

