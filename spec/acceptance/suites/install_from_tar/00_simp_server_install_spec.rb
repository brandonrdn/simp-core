require 'spec_helper_integration'

test_name 'Install SIMP modules and assets via RPMs in a release tarball'

# facts gathered here are executed when the file first loads and
# use the factor gem temporarily installed into system ruby
master = only_host_with_role(hosts, 'master')
majver = fact_on(master, 'operatingsystemmajrelease')
osname = fact_on(master, 'operatingsystem')

describe 'Install SIMP modules and assets via release tarball' do

  context 'all hosts prep' do
    set_up_options = {
      :root_password => test_password,
      :repos         => [
        :epel,
        :simp_deps,
        :puppet
      ]
    }

    hosts.each do |host|
      include_examples 'basic server setup', host, set_up_options
    end
  end

  context 'puppet master prep' do

    it 'should set up SIMP repository from a SIMP release tarball' do
      tarball = find_simp_release_tarball(majver, osname)
      if tarball.nil?
        fail("SIMP release tarball not found")
      else
        set_up_tarball_repo(master, tarball)
      end
    end

    # This has to be done **BEFORE** simp config is run and should
    # be done before the simp RPM is installed
    it 'should install puppetserver' do
      master.install_package('puppetserver')
    end

    it 'should install simp module and asset RPMs and create local Git module repos' do
      master.install_package('simp-adapter')
      master.install_package('simp')
    end
  end

end