require 'cgi'
require_relative "markdown_processor/mention_filter"
require_relative "markdown_processor/img_filter"
class MarkdownProcessor
  FILTERS = [
    HTML::Pipeline::MarkdownFilter,
    HTML::Pipeline::AutolinkFilter,
    MentionFilter,
    ImgFilter
  ]

  def self.call(text, options = {})
    new(options).call(text)
  end

  def initialize(options = {})
    @options = options
  end

  def call(text)
    pipeline = HTML::Pipeline.new(FILTERS, @options)
    text = CGI.escapeHTML(text)
    pipeline.call(text)
  end
end
