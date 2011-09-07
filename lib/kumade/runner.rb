require 'optparse'

module Kumade
  class Runner
    class << self
      attr_reader :environment
    end

    def self.run(args=ARGV, out=StringIO.new)
      @out         = out
      @options     = parse_arguments!(args)
      @environment = args.shift || 'staging'

      swapping_stdout_for(@out) do
        deploy
      end
    end

    def self.deploy
      if pretending?
        puts "==> In Pretend Mode"
      end
      puts "==> Deploying to: #{environment}"
      Deployer.new(environment, pretending?, @options[:cedar]).deploy
      puts "==> Deployed to: #{environment}"
    end

    def self.parse_arguments!(args)
      options = {}
      OptionParser.new do |opts|
        opts.banner = "Usage: kumade <environment> [options]"

        opts.on("-p", "--pretend", "Pretend mode: print what kumade would do") do |p|
          options[:pretend] = p
        end

        opts.on("-c", "--cedar", "Use this if your app is on cedar") do |cedar|
          options[:cedar] = cedar
        end

        opts.on_tail("-v", "--verbose", "Print what kumade is doing") do
          options[:verbose] = true
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

      options
    end

    def self.swapping_stdout_for(io)
      begin
        $real_stdout = $stdout
        $stdout = io unless print_output?
        yield
      rescue Kumade::DeploymentError
        unless print_output?
          io.rewind
          $real_stdout.print(io.read)
        end
      ensure
        $stdout = $real_stdout
      end
    end

    def self.pretending?
      @options[:pretend]
    end
    
    def self.verbose?
      @options[:verbose]
    end
    
    def self.print_output?
      pretending? || verbose?
    end
  end
end
