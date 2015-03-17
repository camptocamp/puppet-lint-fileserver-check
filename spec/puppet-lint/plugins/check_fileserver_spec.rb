require 'spec_helper'

describe 'fileserver' do
  let(:msg) { 'expected file() instead of fileserver' }

  context 'with fix disabled' do
    context 'code using file()' do
      let(:code) {
        <<-EOS
        file { 'foo':
          ensure  => file,
          content => file('foo/bar'),
        }
        EOS
      }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'code using source with file:///' do
      let(:code) {
        <<-EOS
        file { 'foo':
          ensure => file,
          source => 'file:///foo/bar',
        }
        EOS
      }

      it 'should detect a single problem' do
        expect(problems).to have(0).problem
      end
    end

    context 'code using fileserver with puppet:///' do
      let(:code) {
        <<-EOS
        file { 'foo':
          ensure => file,
          source => 'puppet:///modules/foo/bar',
        }
        EOS
      }

      it 'should detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(3).in_column(21)
      end
    end

    context 'code using $module_name' do
      let(:code) {
        <<-EOS
        file { 'foo':
          ensure => file,
          source => "puppet:///modules/${module_name}/bar",
        }
        EOS
      }

      it 'should detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(3).in_column(21)
      end
    end

    context 'when using fileserver in concat::fragment' do
      let(:code) {
        <<-EOS
        concat::fragment { 'foo':
          ensure => present,
          source => 'puppet:///modules/foo/bar',
        }
        EOS
      }

      it 'should detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(3).in_column(21)
      end
    end

    context 'when using fileserver not in file resource' do
      let(:code) {
        <<-EOS
        foo { 'foo':
          file_source => 'puppet:///modules/foo/bar',
        }
        EOS
      }

      it 'should detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(2).in_column(26)
      end
    end

    context 'when using fileserver not in file resource with variables' do
      let(:code) {
        <<-EOS
        foo { 'foo':
          file_source => "puppet:///${module_name}/foo/bar",
        }
        EOS
      }

      it 'should detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(2).in_column(26)
      end
    end
  end

  context 'with fix enabled' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    context 'code using file()' do
      let(:code) {
        <<-EOS
        file { 'foo':
          ensure  => file,
          content => file('foo/bar'),
        }
        EOS
      }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end

      it 'should not modify the manifest' do
        expect(manifest).to eq(code)
      end
    end

    context 'code using source with file:///' do
      let(:code) {
        <<-EOS
        file { 'foo':
          ensure => file,
          source => 'file:///foo/bar',
        }
        EOS
      }

      it 'should detect a single problem' do
        expect(problems).to have(0).problem
      end

      it 'should not modify the manifest' do
        expect(manifest).to eq(code)
      end
    end

    context 'code using fileserver with puppet:///' do
      let(:code) {
        <<-EOS
        file { 'foo':
          ensure => file,
          source => 'puppet:///modules/foo/bar',
        }
        EOS
      }

      it 'should detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the problem' do
        expect(problems).to contain_fixed(msg).on_line(3).in_column(21)
      end

      it 'should add a newline to the end of the manifest' do
        expect(manifest).to eq(
          <<-EOS
        file { 'foo':
          ensure => file,
          content => file('foo/bar'),
        }
        EOS
        )
      end
    end

    context 'code using $module_name' do
      let(:code) {
        <<-EOS
        file { 'foo':
          ensure => file,
          source => "puppet:///modules/${module_name}/bar",
        }
        EOS
      }

      it 'should detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the problem' do
        expect(problems).to contain_fixed(msg).on_line(3).in_column(21)
      end

      it 'should add a newline to the end of the manifest' do
        expect(manifest).to eq(
          <<-EOS
        file { 'foo':
          ensure => file,
          content => file("${module_name}/bar"),
        }
        EOS
        )
      end
    end


    context 'when using fileserver in concat::fragment' do
      let(:code) {
        <<-EOS
        concat::fragment { 'foo':
          ensure => present,
          source => 'puppet:///modules/foo/bar',
        }
        EOS
      }

      it 'should detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the problem' do
        expect(problems).to contain_fixed(msg).on_line(3).in_column(21)
      end

      it 'should fix the code' do
        expect(manifest).to eq(
          <<-EOS
        concat::fragment { 'foo':
          ensure => present,
          content => file('foo/bar'),
        }
        EOS
        )
      end
    end

    context 'code using a variable' do
      let(:code) {
        <<-EOS
        file { 'foo':
          ensure => file,
          source => "puppet:///modules/foo/${bar}",
        }
        EOS
      }

      it 'should detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the problem' do
        expect(problems).to contain_fixed(msg).on_line(3).in_column(21)
      end

      it 'should add a newline to the end of the manifest' do
        expect(manifest).to eq(
          <<-EOS
        file { 'foo':
          ensure => file,
          content => file("foo/${bar}"),
        }
        EOS
        )
      end
    end

    context 'code using two variables' do
      let(:code) {
        <<-EOS
        file { 'foo':
          ensure => file,
          source => "puppet:///modules/${module_name}/${bar}",
        }
        EOS
      }

      it 'should detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the problem' do
        expect(problems).to contain_fixed(msg).on_line(3).in_column(21)
      end

      it 'should add a newline to the end of the manifest' do
        expect(manifest).to eq(
          <<-EOS
        file { 'foo':
          ensure => file,
          content => file("${module_name}/${bar}"),
        }
        EOS
        )
      end
    end

    context 'when using fileserver not in file resource' do
      let(:code) {
        <<-EOS
        foo { 'foo':
          file_source => 'puppet:///modules/foo/bar',
        }
        EOS
      }

      it 'should detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(2).in_column(26)
      end

      it 'should not modify the manifest' do
        expect(manifest).to eq(code)
      end
    end

    context 'when using fileserver not in file resource with variables' do
      let(:code) {
        <<-EOS
        foo { 'foo':
          file_source => "puppet:///${module_name}/foo/bar",
        }
        EOS
      }

      it 'should detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(2).in_column(26)
      end

      it 'should not modify the manifest' do
        expect(manifest).to eq(code)
      end
    end
  end
end
