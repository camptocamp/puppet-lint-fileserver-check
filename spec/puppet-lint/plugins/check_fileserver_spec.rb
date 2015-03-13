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

    context 'code using fileserver' do
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
        expect(problems).to contain_warning(msg).on_line(3).in_column(11)
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
        expect(problems).to contain_warning(msg).on_line(3).in_column(11)
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

    context 'code using fileserver' do
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
        pending 'Throw errors...'
        expect(problems).to contain_fixed(msg).on_line(1).in_column(11)
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
        pending 'Throw errors...'
        expect(problems).to contain_fixed(msg).on_line(1).in_column(11)
      end

      it 'should add a newline to the end of the manifest' do
        pending 'Need work'
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
  end
end
