class Awesome
  def self.call(env)
    [200, {
          "Content-Type"   => "text/html"
        }, [body] ]
  end

  def self.body
    %q{<img src="http://www.somnambulance.net/images/wood_paneling.png">}
  end
end

use Rack::ShowExceptions
run Awesome
