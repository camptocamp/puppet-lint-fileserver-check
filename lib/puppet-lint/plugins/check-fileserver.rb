PuppetLint.new_check(:fileserver) do
  def check
    resource_indexes.each do |resource|
      attr = resource[:tokens].select do |t|
        t.prev_code_token && t.prev_code_token.type == :FARROW && t.value =~ %r{^puppet:///}
      end
      next if attr.empty?
      notify :warning, {
        :message  => 'expected file() instead of fileserver',
        :line     => attr[0].line,
        :column   => attr[0].column,
        :token    => attr[0],
        :resource => resource,
      }
    end
  end

  def fix(problem)
    if problem[:resource][:type].value == 'file' && problem[:token].type == :SSTRING
      problem[:token].prev_code_token.prev_code_token.value = 'content'
      problem[:token].value.sub!(%r{^puppet:///modules/(.*)}, "file('\\1')")
      problem[:token].type = :NAME
    else
      raise PuppetLint::NoFix, "Not fixing"
    end
  end
end
