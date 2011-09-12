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

      Kumade.configuration.pretending  = !!@options[:pretend]
      Kumade.configuration.environment = args.shift || 'staging'
      Kumade.configuration.tests = tests?

      self.class.swapping_stdout_for(out, print_output?) do
        deploy
      end
    end

    def self.swapping_stdout_for(io, print_output = false)
      if print_output
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
      if Kumade.configuration.pretending?
        puts "==> In Pretend Mode"
      end
      puts "==> Deploying to: #{Kumade.configuration.environment}"
      self.class.deployer.new.deploy
      puts "==> Deployed to: #{Kumade.configuration.environment}"
    end

    def parse_arguments!(args)
      OptionParser.new do |opts|
        opts.banner = "Usage: kumade <environment> [options]"

        opts.on("-p", "--pretend", "Pretend mode: print what kumade would do") do |p|
          @options[:pretend] = p
        end

        opts.on_tail('--skip-tests', 'Skip tests') do
          @options[:tests] = false
        end

        opts.on_tail("-v", "--verbose", "Print what kumade is doing") do
          @options[:verbose] = true
        end

        opts.on_tail('--version', 'Show version') do
          puts "kumade #{Kumade::VERSION}"
          exit
        end

        opts.on_tail('-h', '--help', 'Show this message') do
          puts opts
          exit
        end
      end.parse!(args)
    end

    def verbose?
      @options[:verbose]
    end

    def print_output?
      Kumade.configuration.pretending? || verbose?
    end
    
    def tests?
      return true if @options[:tests].nil?
      @options[:tests]
    end
  end
end
