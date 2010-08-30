unless Capistrano::Configuration.respond_to?(:instance)
  abort "Requires Capistrano 2"
end

Dir[File.join(File.dirname(__FILE__), %w{capstrap *.rb})].each do |lib|
  load(lib)
end
