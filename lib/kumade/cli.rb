require 'optparse'
require 'stringio'

module Kumade
  class CLI
    class << self
      attr_writer :deployer

      def deployer
        @deployer || Kumade::Deployer
      end
    end

    def initialize(args = ARGV, out = StringIO.new)
      @options     = {}
      parse_arguments!(args)
      @environment = args.shift || 'staging'

      self.class.swapping_stdout_for(out, pretending?) do
        deploy
      end
    end

    def self.swapping_stdout_for(io, pretending = false)
      if pretending
        yield
      else
        begin
          real_stdout = $stdout
          $stdout     = io
          yield
        rescue Kumade::DeploymentError
          io.rewind
          real_stdout.print(io.read)
        ensure
          $stdout = real_stdout
        end
      end
    end

    private

    def deploy
      if pretending?
        puts "==> In Pretend Mode"
      end
      puts "==> Deploying to: #{@environment}"
      self.class.deployer.new(@environment, pretending?).deploy
      puts "==> Deployed to: #{@environment}"
    end

    def parse_arguments!(args)
      OptionParser.new do |opts|
        opts.banner = "Usage: kumade <environment> [options]"

        opts.on("-p", "--pretend", "Pretend mode: print what kumade would do") do |p|
          @options[:pretend] = p
        end

        opts.on_tail('-v', '--version', 'Show version') do
          puts "kumade #{Kumade::VERSION}"
          exit
        end

        opts.on_tail('-h', '--help', 'Show this message') do
          puts opts
          exit
        end
      end.parse!(args)
    end

    def pretending?
      !!@options[:pretend]
    end
  end
end
