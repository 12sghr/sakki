class MarkdownProcessor
  class ImgFilter < HTML::Pipeline::Filter
    def call
      doc.search('.//text()').each do |node|
        html = node.to_html.gsub(/(https|http)?:\/\/.+\.(jpg|jpeg|bmp|gif|png)(\?\S+)?/i) do |match|
        %|<img src="#{match}" alt="" class="ui medium bordered image"/>|
        end
        node.replace(html)
      end
      doc
    end
  end
end
