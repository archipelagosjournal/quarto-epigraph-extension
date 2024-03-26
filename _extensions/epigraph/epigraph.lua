return {
  quarto.log.output("Loading epigraph extension"),

  --renders an epigraph in html within two nested divs (one for the text, 
  -- then inner for the citation, each with appropricate css call)
  -- renders in LaTeX within a blockquote, then citation flushright on next line
  ['epigraph'] = function(args, kwargs, meta)
    quarto.log.output("Running epigraph extension", "args", args, "kwargs", kwargs)

    -- Get the text and citation. Fail if text="" not present
    local text = pandoc.utils.stringify(kwargs["text"])
    if text == nil then
      quarto.log.error("epigraph extension requires text argument")
      return nil
    end
   
    
    
    local citation = pandoc.utils.stringify(kwargs["citation"])
    
    quarto.log.output("epigraph text = '", text, "' citation = '", citation,"'")

    if quarto.doc.is_format("html") then

      -- see if text has ` \\ ` in it. If so, we need to split each line delinitated by ` \\ ` into it's own line and break on <br/>
      if string.find(text, " \\ ") then
        local text_lines = {}
        -- find ` \\ ` and use it as the split token.
        for line in string.gmatch(text, "([^\\]+)") do
          table.insert(text_lines, line)
        end

        text = table.concat(text_lines, "</br>")
      end

      local html = '<blockquote class="epigraph"><div class="epigraph-text">' .. text .. '</div>'
      if citation ~= "" then
        html = html .. '<div class="epigraph-citation"> – ' .. citation .. '</div>'
      end
      html = html .. '</blockquote>'
      return pandoc.RawInline('html', html)
    elseif quarto.doc.is_format("latex") then

      -- we need to replace ` \\ ` with `\n\n` in the text
     local elements = {
        pandoc.RawInline('latex', '\\quotation{'),
        pandoc.Str(text),
        pandoc.RawInline('latex', '}{'),
        pandoc.Str((citation or '')),
        pandoc.RawInline('latex', '}')
      }
      
      return pandoc.Para(elements)
    else
      return pandoc.Str("[" .. text .. (citation ~= "" and " -- " .. citation or "") .. "]")
    end


    -- Additional processing here if needed

    -- return pandoc.Str("Hello from Epigraph!")
  end
}
