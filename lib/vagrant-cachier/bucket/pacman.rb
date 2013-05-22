module Vagrant
  module Cachier
    class Bucket
      class Pacman < Bucket
        def self.capability
          :pacman_cache_dir
        end

        def install
          machine = @env[:machine]
          guest   = machine.guest

          if guest.capability?(:pacman_cache_dir)
            guest_path = guest.capability(:pacman_cache_dir)

            @env[:cache_dirs] << guest_path

            machine.communicate.tap do |comm|
              comm.execute("mkdir -p /tmp/vagrant-cache/#{@name}")
              unless comm.test("test -L #{guest_path}")
                comm.sudo("rm -rf #{guest_path}")
                comm.sudo("mkdir -p `dirname #{guest_path}`")
                comm.sudo("ln -s /tmp/vagrant-cache/#{@name} #{guest_path}")
              end
            end
          else
            # TODO: Raise a better error
            raise "You've configured a Pacman cache for a guest machine that does not support it!"
          end
        end
      end
    end
  end
end
