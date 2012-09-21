require 'strscan'

module Fiasco
  class TemplateCompiler
    OPENERS = /(.*?)(^[ \t]*%|\{%-?|\{\{-?|\{#-?|\z)/m
    DEFAULT_DISPLAY_VALUE = lambda{|outvar, literal| "#{outvar} << (#{literal}).to_s"}
    DEFAULT_DISPLAY_TEXT = lambda{|text| text.dump}

    def initialize(options = {})
      @output_var = options.fetch(:output_var, '@render_output')
      @display_value = options.fetch(:display_value, DEFAULT_DISPLAY_VALUE)
      @display_text = options.fetch(:display_text, DEFAULT_DISPLAY_TEXT)
    end

    def closer_for(tag)
      case tag
      when /\{%-?/ then /(.*?)(-?%\}|\z)/m
      when /\{\{-?/ then /(.*?)(-?}\}|\z)/m
      when /\{#-?/ then /(.*?)(-?#\}|\z)/m
      when '%' then /(.*?)($)/
      end
    end

    def scan(body)
      scanner = StringScanner.new(body)
      open_tag = nil

      until scanner.eos?
        if open_tag
          scanner.scan(closer_for(open_tag))
          inner, close_tag = scanner[1], scanner[2]

          case open_tag
          when '{{', '{{-' then yield [:display,   inner]
          when '{%', '{%-' then yield [:code,      inner]
          when '{#', '{#-' then yield [:comment,   inner]
          when '%'         then yield [:code_line, inner]
          end

          open_tag = nil
        else
          scanner.scan(OPENERS)
          before, open_tag = scanner[1], scanner[2]
          open_tag.lstrip! # for % which captures preceeding whitespace

          text = before
          text = text.lstrip if close_tag && close_tag[0] == '-'
          text = text.rstrip if open_tag[-1] == '-'

          yield [:text, text]
          yield [:newlines, before.count("\n")]
        end
      end
    end

    def compile(body)
      src = []

      scan(body) do |command, data|
        case command
        when :newlines
          src << "\n" * data unless data == 0
        when :text
          src << "#{@output_var} << #{@display_text.(data)}" unless data.empty?
        when :code, :code_line
          src << data
        when :display
          src << @display_value.(@output_var, data)
        when :comment
          # skip
        end
      end

      src.join(';')
    end
  end
end
