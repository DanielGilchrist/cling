module CLI
  abstract class Command
    @application : Application
    property name : String?
    property usage : Array(String)
    property description : String?
    property short_help : String?
    property arguments : Hash(String, Argument)
    property options : Array(Option)

    def initialize(@application)
      @usage = [] of String
      @arguments = {} of String => Argument
      @options = [] of Option

      setup
    end

    def add_argument(name : String, desc : String? = nil, required : Bool = false,
                     kind : ValueKind = :none) : Nil
      @arguments[name] = Argument.new(name, desc, required, kind)
    end

    def add_option(long : String, *, short : String? = nil, desc : String? = nil,
                   required : Bool = false, kind : ValueKind = :none, default : String? = nil) : Nil
      @options << Option.new(long, short, desc, required, kind, default)
    end

    def setup : Nil
      raise "A name must be set for the command" unless @name
    end

    abstract def execute(args, options) : Nil

    def on_invalid_arguments(args : Array(String)) : NoReturn
      raise "Invalid arguments: #{args.join(", ")}"
    end

    def on_invalid_options(options : Array(String)) : NoReturn
      raise "Invalid options: #{options.join(", ")}"
    end

    def on_missing_arguments(args : Array(Argument)) : NoReturn
      raise "Missing required arguments: '#{args.join(", ")}'"
    end

    def on_missing_options(options : Array(Option)) : NoReturn
      raise "Missing required options: '#{options.join(", ")}'"
    end

    def on_error(ex : Exception) : NoReturn
      raise ex
    end

    def help_template : String
      @help_template || generate_help_template
    end

    def help_template=(@help_template : String?)
    end

    private def generate_help_template : String
      template = String.build do |str|
        if header = @application.header
          str << header << "\n\n"
        end

        if desc = @description
          str << desc << "\n\n"
        end

        str << "Usage:"
        if @usage.empty?
          str << "\n\t" << @name
          unless @arguments.empty?
            if @arguments.values.any? &.required?
              str << " <arguments>"
            else
              str << " [arguments]"
            end
          end

          str << " [options]" unless @options.empty?
          str << "\n\n"
        else
          @usage.each do |use|
            str << "\n\t" << use
          end
        end

        unless @arguments.empty?
          str << "Arguments:"
          max_space = @arguments.keys.sum(2) { |n| n.size }

          @arguments.each do |name, arg|
            str << "\n\t" << name
            str << " " * (max_space - name.size)
            str << arg.description
          end

          str << "\n\n"
        end

        unless @options.empty?
          str << "Options:"
          max_space = @options.sum(2) do |option|
            option.long.size + ((s = option.short) ? s.size : 0)
          end

          @options.each do |option|
            delim = @application.option_delimiter
            name_size = option.long.size + ((s = option.short) ? s.size : 0)

            str << "\n\t"
            if short = option.short
              str << delim << short << ' '
            end

            str << (delim.to_s * 2) << option.long
            str << " " * (max_space - name_size)
            str << option.description

            if option.has_default? && (default = option.value)
              str << " (default: " << default << ')'
            end
          end

          str << '\n'
        end

        if footer = @application.footer
          str << footer
        end
      end

      template
    end
  end
end
